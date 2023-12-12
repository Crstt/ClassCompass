//
//  AddViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/26/23.
//

import UIKit

/**
 `AddViewController` is a UIViewController subclass that manages and displays the interface for adding new assignments.

 It has the following properties:
 - `courses`: An array of Course objects that represent all the courses.
 - `coursesFiltered`: An array of Course objects that represent the filtered courses based on certain criteria.
 - `canvasClient`: A CanvasAPIClient object that is used to interact with the Canvas API.
 - `db`: A Database object that is used to interact with the database.
 - `selectedCourse`: A Course object that represents the currently selected course.
 - `selectedAssignment`: An Assignment object that represents the currently selected assignment.
 - `onClose`: A closure that is called when the view controller is closed.

 In `viewDidLoad`, it filters the courses for active ones and assigns the result to `coursesFiltered`. It also filters assignments based on the state of a switch control. It sets up the delegates and data sources for the class picker and assignment picker, and sets up the initial selections.

 The `ClassPicker`, `AssignmentPicker`, `DueDatePicker`, `DueOnDatePicker`, and `overdueSwitch` are all IBOutlets connected to controls in the interface.
 */
class AddViewController: UIViewController {
    
    var courses: [Course] = []
    var coursesFiltered: [Course] = []
    var canvasClient: CanvasAPIClient!
    var db: Database!
    var selectedCourse: Course?
    var selectedAssignment: Assignment?
    
    /// A closure that will be called when the view controller is closed.
    var onClose: (() -> Void)?
    
    /**
        This method is called after the view controller's view is loaded into memory.
        It sets up the initial state of the view and assigns delegates and data sources to the pickers.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coursesFiltered = filterForActiveCourses()
        filterAssignmentsForSwitchState()
        
        ClassPicker.delegate = self
        ClassPicker.dataSource = self
        
        AssignmentPicker.delegate = self
        AssignmentPicker.dataSource = self
        
        setupInitialSelections()
    }
    
    @IBOutlet weak var ClassPicker: UIPickerView!
    @IBOutlet weak var AssignmentPicker: UIPickerView!
    @IBOutlet weak var DueDatePicker: UIDatePicker!
    @IBOutlet weak var DueOnDatePicker: UIDatePicker!
    @IBOutlet weak var overdueSwitch: UISwitch!
    
    /**
     Handles the action when the overdue switch is toggled.
     Once the toggle is one the assignments are filtered to show all assignments regardless of due date.
     
     - Parameter sender: The object that triggered the action.
     */
    @IBAction func overdueSwitched(_ sender: Any) {
        filterAssignmentsForSwitchState()
        
        AssignmentPicker.reloadAllComponents()
        if let firstAssignment = selectedCourse?.assignments.first{
            if let dueDate = firstAssignment.dueDate {
                setDatePickers(dueDate)
            }
        }
    }
    
    /// Filters the courses based on their start and end dates, returning only the active courses.
    /// - Returns: An array of `Course` objects representing the active courses.
    func filterForActiveCourses() -> [Course] {
        let today = Date()
        
        let filteredCourses = courses.compactMap { course in
            if today >= course.startDate && today <= course.endDate {
                // Create a deep copy of the course object
                return Course(id: course.id, name: course.name, code: course.code, startDate: course.startDate, endDate: course.endDate, assignments: course.assignments)
            }
            return nil
        }
        
        return filteredCourses
    }
    
    /**
     Filters the given array of courses and returns a new array containing only the courses that have assignments.

     - Parameter courses: An array of courses to be filtered.
     - Returns: An array of courses that have assignments.
     */
    func filterCoursesWithAssignments(_ courses: [Course]) -> [Course] {
        let filteredCourses = courses.filter { course in
            return course.assignments.count > 0
        }
        return filteredCourses
    }
    
    
    /**
     Filters the assignments based on the state of the overdueSwitch.
     
     If the overdueSwitch is on, all assignments are shown regardless of due date.
     If the overdueSwitch is off, assignments are filtered to show only those with due dates not past today.
     
     - Note: This function modifies the `coursesFiltered` array by filtering the assignments.
     - Note: This function also reloads the `ClassPicker` and `AssignmentPicker` components and sets up initial selections.
     */
    func filterAssignmentsForSwitchState() {
        
        coursesFiltered = coursesFiltered.map { course in
            var filteredCourse = course
            filteredCourse.assignments = course.assignments.filter { assignment in
                
                if assignment.dueOnDate == nil {
                    // Keep assignments where dueOnDate is not yet set
                    return true
                }
                
                return false
            }
            return filteredCourse
        }
        
        if overdueSwitch.isOn {
            // Show all assignments regardless of dueDate
            coursesFiltered = filterForActiveCourses()
        } else {
            // Filter assignments to show only those with dueDate not past today
            let today = Date()
            coursesFiltered = coursesFiltered.map { course in
                let filteredCourse = course
                filteredCourse.assignments = course.assignments.filter { assignment in
                    guard let dueDate = assignment.dueDate else { return false }
                    return dueDate >= today
                }
                return filteredCourse
            }
        }
        
        coursesFiltered = filterCoursesWithAssignments(coursesFiltered)
        
        ClassPicker.reloadAllComponents()
        AssignmentPicker.reloadAllComponents()
        setupInitialSelections()
    }
    
    /**
     This method is called when the "Set" button is tapped in the AddViewController.
     It updates the due date of the selected assignment and updates the UI accordingly.
     */
    @IBAction func Set(_ sender: Any) {
        /*print(selectedCourse?.code as Any)
         print(selectedAssignment?.name as Any)
         print(DueDatePicker.date)
         print(DueOnDatePicker.date)*/
        
        if let assignmentId = selectedAssignment?.id {
            // Check if a selected assignment exists
            
            if let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: DueOnDatePicker.date) {
                // Set the time of the DueOnDatePicker to 00:00:00
                
                let dueOnDate = date
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let dueOnDateString = df.string(from: dueOnDate)
                
                // Update the dueOnDate of the assignment in the database
                db.updateAssignmentDueOnDate(assignmentId: assignmentId, dueOnDate: dueOnDateString)
                
                // Update the dueOnDate and status of the assignment in the local data
                for course in courses {
                    if course.id == selectedCourse?.id {
                        for assignment in course.assignments {
                            if assignment.id == assignmentId {
                                assignment.dueOnDate = dueOnDate
                                assignment.status = .inProgress
                            }
                        }
                    }
                }
            }
        }

        // Filter assignments based on the state of the overdueSwitch
        filterAssignmentsForSwitchState()

        // Reload the ClassPicker and AssignmentPicker components
        ClassPicker.reloadAllComponents()
        AssignmentPicker.reloadAllComponents()

        // Close the modal when there are no more assignments to set
        if coursesFiltered.count == 0 {
            dismiss(animated: true) {
                self.onClose?() // Call the closure when dismissing the modal
            }
        } else {
            let rowClass = ClassPicker.selectedRow(inComponent: 0)
            var rowAssignment = AssignmentPicker.selectedRow(inComponent: 0)
            
            selectedCourse = coursesFiltered[rowClass]
            
            // Filter assignments based on the state of the overdueSwitch
            filterAssignmentsForSwitchState()
            AssignmentPicker.reloadAllComponents()
            
            if rowAssignment >= (selectedCourse?.assignments.count)! {
                rowAssignment = 0
            }
            
            // Select the first assignment for the selected course
            if let assignment = selectedCourse?.assignments[rowAssignment] {
                AssignmentPicker.selectRow(rowAssignment, inComponent: 0, animated: true)
                selectedAssignment = assignment
                
                // Update DueDatePicker with the due date of the selected assignment
                if let dueDate = selectedAssignment?.dueDate {
                    setDatePickers(dueDate)
                }
            }
        }
    }
    
    /**
     Closes the modal view controller and calls the closure when dismissing the modal.
     
     - Parameter sender: The object that triggered the action.
     */
    @IBAction func CloseModal(_ sender: Any) {
        dismiss(animated: true) {
            self.onClose?() // Call the closure when dismissing the modal
        }
    }
    
    // MARK: - UIPickerViewDataSource methods

    /// Returns the number of components in the picker view.
    /// - Parameter pickerView: The picker view.
    /// - Returns: The number of components in the picker view (always 1 in this case).
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // For a single column in the picker
    }

    /// Sets up the initial selections for the view controller.
    /// - Note: The first course in the filtered courses list is set as the default selected course.
    ///         The selected assignment is set based on the row selected in the assignment picker.
    func setupInitialSelections() {
        selectedCourse = coursesFiltered.first // Setting the first course as default
        let row = AssignmentPicker.selectedRow(inComponent: 0)
        setupSelectedAssignmentForRow(row)
    }

    /// Sets the date pickers with the given due date.
    /// - Parameter dueDate: The due date for the assignment.
    /// - Note: The `DueDatePicker` is set to the due date.
    ///         The `DueOnDatePicker` minimum date is set to the current date.
    ///         If the `overdueSwitch` is on, the `DueOnDatePicker` maximum date is set to `nil`.
    ///         If the `overdueSwitch` is off, the `DueOnDatePicker` maximum date is set to the due date.
    func setDatePickers(_ dueDate: Date) {
        DueDatePicker.date = dueDate
        DueOnDatePicker.minimumDate = Date()
        if overdueSwitch.isOn {
            DueOnDatePicker.maximumDate = nil
        } else {
            DueOnDatePicker.maximumDate = dueDate
        }
    }

    /// Sets up the selected assignment based on the given row.
    /// - Parameter row: The row selected in the assignment picker.
    /// - Note: If a course is selected and it has assignments, the selected assignment is set based on the row.
    ///         If the row is out of bounds, the first assignment of the course is selected.
    ///         The `DueDatePicker` is updated with the due date of the selected assignment.
    func setupSelectedAssignmentForRow(_ row: Int) {
        if let selectedCourse = selectedCourse {
            if selectedCourse.assignments.count > 0 {
                if row < selectedCourse.assignments.count {
                    selectedAssignment = selectedCourse.assignments[row]
                } else {
                    selectedAssignment = selectedCourse.assignments[0]
                }
                // Update DueDatePicker with the due date of the selected assignment
                if let dueDate = selectedAssignment?.dueDate {
                    setDatePickers(dueDate)
                }
            }
        }
    }
    
    /**
     Selects the next row in the specified `pickerView`.

     - Parameters:
        - pickerView: The `UIPickerView` in which the next row needs to be selected.
     */
    func selectNextRow(in pickerView: UIPickerView) {
        let currentRow = pickerView.selectedRow(inComponent: 0)
        let nextRow = currentRow + 1
        
        if nextRow < pickerView.numberOfRows(inComponent: 0) {
            pickerView.selectRow(nextRow, inComponent: 0, animated: true)
        } else if pickerView.numberOfRows(inComponent: 0) > 0 {
            pickerView.selectRow(0, inComponent: 0, animated: true) // Wrap to the first element
        }
    }
}

/**
 A delegate method that is called when a row is selected in the UIPickerView.
 
 - Parameters:
    - pickerView: The UIPickerView instance.
    - row: The selected row index.
    - component: The selected component index.
 */
extension AddViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ClassPicker {
            selectedCourse = coursesFiltered[row]
            filterAssignmentsForSwitchState()
            AssignmentPicker.reloadAllComponents()
            // Select the first assignment for the selected course here
            if let firstAssignment = selectedCourse?.assignments.first {
                
                AssignmentPicker.selectRow(0, inComponent: 0, animated: true)
                selectedAssignment = firstAssignment
                
                // Update DueDatePicker with the due date of the selected assignment
                if let dueDate = selectedAssignment?.dueDate {
                    setDatePickers(dueDate)
                }
            }
        } else if pickerView == AssignmentPicker {
            selectedAssignment = selectedCourse?.assignments[row]
            // Update DueDatePicker with the due date of the selected assignment
            if let dueDate = selectedAssignment?.dueDate {
                setDatePickers(dueDate)
            }
        }
    }
}

/**
   This extension conforms to the UIPickerViewDataSource protocol and provides the necessary methods for data source implementation in the AddViewController class.
*/
extension AddViewController: UIPickerViewDataSource{ //#2
    /**
     Returns the number of rows in a given component of the picker view.

     - Parameters:
        - pickerView: The picker view requesting this information.
        - component: An index number identifying a component of the picker view.

     - Returns: The number of rows in the specified component.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == ClassPicker {
            return coursesFiltered.count // Number of courses for ClassPicker
        } else if pickerView == AssignmentPicker {
            // Return the number of assignments for the selected course
            return selectedCourse?.assignments.count ?? 1
        } else {
            return 0
        }
    }
    
    /**
     Returns the title for a row in the specified component of the picker view.

     - Parameters:
        - pickerView: The picker view requesting the title.
        - row: The index of the row.
        - component: The index of the component.

     - Returns: The title for the specified row and component, or nil if there is no title.
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //ClassPicker new selection
        if pickerView == ClassPicker {
            //print(row)
            //print(coursesFiltered[row].code)
            selectedCourse = coursesFiltered[row]
            AssignmentPicker.reloadAllComponents()
            return selectedCourse?.code // Display course codes in ClassPicker
            // AssignmentPicker new selection
        } else if pickerView == AssignmentPicker {
            // Display assignment names for the selected course in AssignmentPicker
            if let name = selectedCourse?.assignments[row]{
                return name.name
            }else{
                return selectedCourse?.assignments[0].name
            }
        } else {
            return nil
        }
    }
}
