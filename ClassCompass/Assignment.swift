//
//  Assignment.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/21/23.
//

import Foundation

class Assignment {
    let id: Int
    let name: String
    let dueDate: Date
    let description: String
    //points_possible
    var grade: Double?

    init(id: Int, name: String, dueDate: Date, description: String, grade: Double?) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.description = description
        self.grade = grade
    }
    
    static func dump(_ assignments: [Assignment]) -> String {
            var assignmentDetails = "Assignments:\n"

            for assignment in assignments {
                assignmentDetails += "ID: \(assignment.id)\n"
                assignmentDetails += "Name: \(assignment.name)\n"
                assignmentDetails += "Due Date: \(assignment.dueDate)\n"
                assignmentDetails += "Description: \(assignment.description)\n"
                if let grade = assignment.grade {
                    assignmentDetails += "Grade: \(grade)\n"
                } else {
                    assignmentDetails += "Grade: Not Graded\n"
                }
                assignmentDetails += "---------\n"
            }
            return assignmentDetails
        }
}