//
//  Course.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/21/23.
//

import Foundation

class Course {
    let id: Int
    let name: String
    let code: String
    let startDate: Date
    let endDate: Date
    let assignments: [Assignment]
    
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
}
