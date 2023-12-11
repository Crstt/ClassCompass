//
//  Course.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/21/23.
//  Edited by David Teixeira
//

import Foundation

class Course {
    let id: Int
    let name: String
    let code: String
    let startDate: Date
    let endDate: Date
    var assignments: [Assignment]
    
    init(id: Int, name: String, code: String, startDate: Date, endDate: Date, assignments: [Assignment]) {
        self.id = id
        self.name = name
        self.code = code
        self.startDate = startDate
        self.endDate = endDate
        self.assignments = assignments
    }
    
    static func dump(_ courses: [Course]) -> String {
        var courseDetails = "Courses:\n"
        
        for course in courses {
            courseDetails += "ID: \(course.id)\n"
            courseDetails += "Name: \(course.name)\n"
            courseDetails += "Code: \(course.code)\n"
            courseDetails += "Start Date: \(course.startDate)\n"
            courseDetails += "End Date: \(course.endDate)\n"
            courseDetails += "---------\n"
        }
        return courseDetails
    }
    
    static func assignmentsDueOnDate(_ courses: [Course], dueOnDate: Date) -> [(Course, Assignment)] {
        var agendaAssignments: [(Course, Assignment)] = []
        
        for course in courses {
            let dueAssignments = course.assignments.filter { assignment in
                if let dueDate = assignment.dueOnDate,
                   Calendar.current.isDate(dueDate, inSameDayAs: dueOnDate),
                   assignment.status != .completed {
                    return true
                }
                return false
            }
            
            let courseWithDueAssignments = dueAssignments.map { (course, $0) }
            agendaAssignments.append(contentsOf: courseWithDueAssignments)
        }
        
        return agendaAssignments
    }
}
