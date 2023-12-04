//
//  AddViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/26/23.
//

import UIKit

class AddViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ClassPicker.delegate = self
        ClassPicker.dataSource = self
    }
    
    @IBOutlet weak var ClassPicker: UIPickerView!
    @IBOutlet weak var AssignmentPicker: UIPickerView!
    @IBOutlet weak var DueDatePicker: UIDatePicker!
    @IBOutlet weak var DueOnDatePicker: UIDatePicker!
    
    @IBAction func Set(_ sender: Any) {
    }
    
    @IBAction func CloseModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // For a single column in the picker
    }
}

var courses: [Course] = []
var canvasClient: CanvasAPIClient!
var db: Database!

var selectedCourse: Course?
var selectedAssignment: Assignment?

extension AddViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ClassPicker {
            selectedCourse = courses[row]
            AssignmentPicker.reloadAllComponents() // Reload AssignmentPicker data
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
            return selectedCourse?.assignments.count ?? 0
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == ClassPicker {
            return courses[row].code // Display course codes in ClassPicker
        } else if pickerView == AssignmentPicker {
            // Display assignment names for the selected course in AssignmentPicker
            return selectedCourse?.assignments[row].name
        } else {
            return nil
        }
    }
    
    
}
