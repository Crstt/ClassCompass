//
//  AddViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/26/23.
//

import UIKit

class AddViewController: UIViewController {
    
    var courses: [Course] = []
    var coursesFiltered: [Course] = []
    var canvasClient: CanvasAPIClient!
    var db: Database!
    var selectedCourse: Course?
    var selectedAssignment: Assignment?
    //var filteredAssignments: [Assignment] = []
    
    override func viewDidLoad() {//#1
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
    
    @IBAction func overdueSwitched(_ sender: Any) {
        filterAssignmentsForSwitchState()
        
        AssignmentPicker.reloadAllComponents()
        if let firstAssignment = selectedCourse?.assignments.first{
            if let dueDate = firstAssignment.dueDate {
                setDatePickers(dueDate)
            }
        }
    }
    
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
    
    func filterCoursesWithAssignments(_ courses: [Course]) -> [Course] {
        let filteredCourses = courses.filter { course in
            return course.assignments.count > 0
        }
        return filteredCourses
    }
    
    
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
    
    @IBAction func Set(_ sender: Any) {
        /*print(selectedCourse as Any)
         print(selectedAssignment as Any)
         print(DueDatePicker.date)
         print(DueOnDatePicker.date)*/
        
        if let assignmentId = selectedAssignment?.id {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dueOnDate = df.string(from: DueOnDatePicker.date)
            db.addAssignmentInProgress(assignmentId: assignmentId, dueOnDate: dueOnDate)
            
            for course in courses {
                if course.id == selectedCourse?.id{
                    for assignment in course.assignments {
                        if assignment.id == assignmentId{
                            assignment.dueOnDate = DueOnDatePicker.date
                        }
                    }
                }
            }
        }
        filterAssignmentsForSwitchState()
        
        //Close modal when there are no more assignments to set
        if coursesFiltered.count == 0{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func CloseModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // For a single column in the picker
    }
    
    func setupInitialSelections() {
        selectedCourse = coursesFiltered.first // Setting the first course as default
        let row = AssignmentPicker.selectedRow(inComponent: 0)
        setupSelectedAssignmentForRow(row)
    }
    
    func setDatePickers(_ dueDate: Date) {
        DueDatePicker.date = dueDate
        DueOnDatePicker.minimumDate = Date()
        if overdueSwitch.isOn{
            DueOnDatePicker.maximumDate = nil
        }else{
            DueOnDatePicker.maximumDate = dueDate
        }
    }
    
    func setupSelectedAssignmentForRow(_ row: Int) {
        if let selectedCourse = selectedCourse {
            if selectedCourse.assignments.count > 0{
                if row < selectedCourse.assignments.count{
                    selectedAssignment = selectedCourse.assignments[row]
                }else{
                    selectedAssignment = selectedCourse.assignments[0]
                }
                // Update DueDatePicker with the due date of the selected assignment
                if let dueDate = selectedAssignment?.dueDate {
                    setDatePickers(dueDate)
                }
            }
        }
    }
}

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

extension AddViewController: UIPickerViewDataSource{ //#2
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {//#3
        //ClassPicker new selectin
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
