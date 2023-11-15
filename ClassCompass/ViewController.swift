//
//  ViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/14/23.
//

import UIKit
import Alamofire

var courses: [Course] = []

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
}

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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var APIToken: UITextField!
    @IBOutlet weak var ResponseLbl: UILabel!
    
    func stringtoDate(_ date: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let resDate = dateFormatter.date(from: date) else {
            print("Error parsing date")
            return dateFormatter.date(from: "1970-01-01T0000:00:00Z")!
        }
        return resDate
        
    }
    
    fileprivate func decodeCourses(_ coursesRaw: [NSDictionary]) {
        for courseRaw in coursesRaw {
            let id = courseRaw["id"] as! Int
            let name = courseRaw["name"] as! String
            let courseCode = courseRaw["course_code"] as! String
            let start_at = courseRaw["start_at"] as! String
            let end_at = courseRaw["end_at"] as! String
            
            let startDate = self.stringtoDate(start_at)
            let endDate = self.stringtoDate(end_at)
            
            let course = Course(id: id, name: name, code: courseCode, startDate: startDate, endDate: endDate, assignments: [])
            courses.append(course)
        }
    }
    
    @IBAction func APITestBtn(_ sender: Any) {
        let canvasAPIURL = "https://ivylearn.ivytech.edu/api/v1/courses"
        let authToken = APIToken.text!

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)",
            "Accept": "application/json"
        ]
        
        AF.request(canvasAPIURL, headers: headers).response { response in
            switch response.result {
            case .success(let json):
                    if let jsonData = json as? NSData {
                        do {
                            let coursesRaw = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as! [NSDictionary]

                            self.decodeCourses(coursesRaw)
                            
                            print("Courses:")
                            for course in courses {
                                print("ID: \(course.id)")
                                print("Name: \(course.name)")
                                print("Code: \(course.code)")
                                print("Start Date: \(course.startDate)")
                                print("End Date: \(course.endDate)")
                                print("---------")
                                
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
