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
    var filteredAssignments: [Assignment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ClassPicker.delegate = self
        ClassPicker.dataSource = self
        
        AssignmentPicker.delegate = self
        AssignmentPicker.dataSource = self
        
        filterForActiveCourses()
        
        setupInitialSelections()
    }
    
    func filterForActiveCourses() {
        let today = Date()
        coursesFiltered = courses.filter { course in
            return today >= course.startDate && today <= course.endDate
        }
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
                DueDatePicker.date = dueDate
            }
        }
    }
    func filterAssignmentsForSwitchState() {
        if overdueSwitch.isOn {
            // Show all assignments regardless of dueDate
            filteredAssignments = selectedCourse!.assignments
            
        } else {
            // Filter assignments to show only those with dueDate not past today
            let today = Date()
            filteredAssignments = selectedCourse!.assignments.filter { assignment in
                guard let dueDate = assignment.dueDate else { return false }
                return dueDate >= today
            }
        }
        
        // Update your UI or table view displaying assignments with filteredAssignments
        // For example:
        // tableView.reloadData() or updateUI(filteredAssignments)
    }
    
    @IBAction func Set(_ sender: Any) {
        print(selectedCourse)
        print(selectedAssignment)
        print(DueDatePicker.date)
        print(DueOnDatePicker.date)
        
        if let assignmentId = selectedAssignment?.id {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dueOnDate = df.string(from: DueOnDatePicker.date)
            db.updateAssignmentDueOnDate(assignmentId: assignmentId, dueOnDate: dueOnDate)
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
        // You might want to set some initial values here for selectedCourse and selectedAssignment
        // For example:
        selectedCourse = courses.first // Setting the first course as default
        let row = AssignmentPicker.selectedRow(inComponent: 0)
        setupSelectedAssignmentForRow(row)
        
    }
}

extension AddViewController: UIPickerViewDelegate{
    func setupSelectedAssignmentForRow(_ row: Int) {
        if let selectedCourse = selectedCourse {
            if selectedCourse.assignments.count > 0{
                selectedAssignment = selectedCourse.assignments[row]
                // Update DueDatePicker with the due date of the selected assignment
                if let dueDate = selectedAssignment?.dueDate {
                    DueDatePicker.date = dueDate
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ClassPicker {
            selectedCourse = courses[row]
            filterAssignmentsForSwitchState()
            AssignmentPicker.reloadAllComponents()
            if let firstAssignment = filteredAssignments.first{
                if let dueDate = firstAssignment.dueDate {
                    DueDatePicker.date = dueDate
                }
            }
        } else if pickerView == AssignmentPicker {
            selectedAssignment = selectedCourse?.assignments[row]
            // Update DueDatePicker with the due date of the selected assignment
            if let dueDate = selectedAssignment?.dueDate {
                DueDatePicker.date = dueDate
            }
        }
    }
}

extension AddViewController: UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == ClassPicker {
            return courses.count // Number of courses for ClassPicker
        } else if pickerView == AssignmentPicker {
            // Return the number of assignments for the selected course
            //print(selectedCourse?.code)
            return selectedCourse?.assignments.count ?? 1
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == ClassPicker {
            selectedCourse = courses[row]
            return courses[row].code // Display course codes in ClassPicker
        } else if pickerView == AssignmentPicker {
            // Display assignment names for the selected course in AssignmentPicker
            return selectedCourse?.assignments[row].name
        } else {
            return nil
        }
    }
    
    
}
