//
//  Assignment.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/21/23.
//

import Foundation

enum AssignmentStatus: String {
    case toDo = "ToDo", inProgress = "InProgress", completed = "Completed"
}

class Assignment {
    let id: Int
    let name: String
    var dueDate: Date?
    var dueOnDate: Date?
    let description: String
    //points_possible
    var grade: Double?
    let courseID: Int // added courseID to store the ID (of course lol)
    var status: AssignmentStatus

    init(id: Int, name: String, dueDate: Date?, dueOnDate: Date? = nil, description: String, grade: Double?, courseID: Int, status: AssignmentStatus = .toDo) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.dueOnDate = dueOnDate
        self.description = description
        self.grade = grade
        self.courseID = courseID
        self.status = status
    }
    
    static func dump(_ assignments: [Assignment]) -> String {
            var assignmentDetails = "Assignments:\n"

            for assignment in assignments {
                assignmentDetails += "ID: \(assignment.id)\n"
                assignmentDetails += "Name: \(assignment.name)\n"
                assignmentDetails += "Due Date: \(String(describing: assignment.dueDate))\n"
                assignmentDetails += "Due On Date: \(String(describing: assignment.dueOnDate))\n"
                //assignmentDetails += "Description: \(assignment.description)\n"
                if let grade = assignment.grade {
                    assignmentDetails += "Grade: \(grade)\n"
                } else {
                    assignmentDetails += "Grade: Not Graded\n"
                }
                assignmentDetails += "Course ID: \(assignment.courseID)\n"
                assignmentDetails += "---------\n"
            }
            return assignmentDetails
        }
}
