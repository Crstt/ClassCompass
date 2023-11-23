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
    let grade: Double?

    init(id: Int, name: String, dueDate: Date, description: String, grade: Double?) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.description = description
        self.grade = grade
    }
}
