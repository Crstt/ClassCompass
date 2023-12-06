//
//  CanvasAPIClient.Student.swift
//  ClassCompassDB
//
//  Created by Matteo Catalano on 11/26/23.
//

import Foundation
import Alamofire

class CanvasAPIClient {
    
    let authToken : String
    let canvasAPIURL : String
    let defaultHeaders: HTTPHeaders
    let database : Database
    
    enum APIError: Error {
        case invalidData
        case networkError(Error)
    }
    
    init (authToken: String, canvasAPIURL: String? = "https://ivylearn.ivytech.edu/api/v1/", database: Database){
        self.authToken = authToken
        self.canvasAPIURL = canvasAPIURL ?? "https://ivylearn.ivytech.edu/api/v1/"
        self.defaultHeaders = [
            "Authorization": "Bearer \(self.authToken)",
            "Accept": "application/json"
        ]
        
        // Added this step to init the db and open the db file
        self.database = Database()
        // self.database = self.database.openDatabase()
    }
    

    func performRequest(url: String, parameters: [String: Any], headers: HTTPHeaders, completion: @escaping (Result<[NSDictionary], Error>) -> Void) {
        AF.request(url, parameters: parameters, headers: headers).response { response in
            switch response.result {
            case .success(let json):
                if let jsonData = json as? NSData {
                    do {
                        
                        if let deserializedJson = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? [NSDictionary] {
                            completion(.success(deserializedJson))
                        } else {
                            // JSON data doesn't match the expected format
                            completion(.failure(APIError.invalidData))
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCourses(page: Int = 1, pageSize: Int = 999, completion: @escaping ([Course]) -> Void) {
        
        let parameters: [String: Any] = [
            "page": page,
            "per_page": pageSize
        ]
        
        performRequest(url: self.canvasAPIURL + "/courses", parameters: parameters, headers: self.defaultHeaders) { result in
            switch result {
            case .success(let coursesRaw):
                let courses = self.decodeCourses(coursesRaw)
                for course in courses {
                    self.database.saveCourse(course)  // Save each course to the database
                }
                completion(courses)
            case .failure(let error):
                print("Error: \(error)")
                completion([])
            }
        }
    }

    fileprivate func regExReplace(_ inputString: String, _ pattern: String, _ replacement: String) -> String {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            return regex.stringByReplacingMatches(in: inputString, options: [], range: NSRange(inputString.startIndex..., in: inputString), withTemplate: replacement)
        } catch {
            print("Error creating regex: \(error)")
            return inputString
        }
    }
    
    func decodeCourses(_ coursesRaw: [NSDictionary]) -> [Course] {
        var courses: [Course] = []
        
        for courseRaw in coursesRaw {
            if let _ = courseRaw["access_restricted_by_date"] {
                print("Course with id: \(courseRaw["id"] as! Int ) has restricted access by date. Could not be saved.")
            } else {
                let id = courseRaw["id"] as! Int
                var name = courseRaw["name"] as! String
                var courseCode = courseRaw["course_code"] as! String
                guard let start_at = courseRaw["start_at"] as? String else {
                    print("Course with id: \(courseRaw["id"] as! Int ) has no start date. Could not be saved.")
                    continue
                }
                guard let end_at = courseRaw["end_at"] as? String else {
                    print("Course with id: \(courseRaw["id"] as! Int ) has no end date. Could not be saved.")
                    continue
                }
                
                courseCode = String(courseCode.prefix(7))
                
                name = regExReplace(name, "(^.+)-(.+)-(.+$)", "$3")
                
                let startDate = self.stringtoDate(start_at)
                let endDate = self.stringtoDate(end_at)
                
                let course = Course(id: id, name: name, code: courseCode, startDate: startDate, endDate: endDate, assignments: [])
                courses.append(course)
            }
        }
        //print(Course.dump(courses))
        return courses
    }
    
    func stringtoDate(_ date: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let resDate = dateFormatter.date(from: date) else {
            print("Error parsing date")
            return dateFormatter.date(from: "1970-01-01T0000:00:00Z")!
        }
        return resDate
    }
    
    func coursesDump(_ courses: [Course]) -> String {
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
    
    func fetchAssignmentsById(courseId: Int, page: Int = 1, pageSize: Int = 999, completion: @escaping ([Assignment]) -> Void) {
        let parameters: [String: Any] = [
            "page": page,
            "per_page": pageSize
        ]

        performRequest(url: self.canvasAPIURL + "/courses/\(courseId)/assignments", parameters: parameters, headers: self.defaultHeaders) { result in
            switch result {
            case .success(let assignmentRaw):
                let assignments = self.decodeAssignments(assignmentRaw)
                for assignment in assignments {
                    self.database.saveAssignment(assignment)
                }
                completion(assignments)
            case .failure(let error):
                print("Error: \(error)")
                completion([])
            }
        }
    }

    func decodeAssignments(_ assignmentsRaw: [NSDictionary]) -> [Assignment] {
        var assignments: [Assignment] = []

            for assignmentRaw in assignmentsRaw {
                guard let id = assignmentRaw["id"] as? Int,
                      let name = assignmentRaw["name"] as? String else {
                    continue
                }

                let dueDateString = assignmentRaw["dueDate"] as? String
                let dueDate = dueDateString.flatMap { self.stringtoDate($0) }

                let dueOnDateString = assignmentRaw["dueOnDate"] as? String
                let dueOnDate = dueOnDateString.flatMap { self.stringtoDate($0) }

                let rawDescription = assignmentRaw["description"] as? String ?? "No description"
                let description = stripHTML(rawDescription)

                let grade = assignmentRaw["grade"] as? Double

                let courseID = assignmentRaw["courseID"] as? Int ?? 0

                let statusString = assignmentRaw["status"] as? String ?? "ToDo"
                let status = AssignmentStatus(rawValue: statusString) ?? .toDo

                let assignment = Assignment(id: id,
                                            name: name,
                                            dueDate: dueDate,
                                            dueOnDate: dueOnDate,
                                            description: description,
                                            grade: grade,
                                            courseID: courseID,
                                            status: status)

                assignments.append(assignment)
            }
            return assignments
        }

    func stripHTML(_ input: String) -> String {
        var output = input.replacingOccurrences(of: "&nbsp;", with: " ")
        let htmlPattern = "<[^>]+>"
        let regex = try! NSRegularExpression(pattern: htmlPattern, options: [])
        let range = NSRange(location: 0, length: output.utf16.count)
        output = regex.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "")

        return output
    }
    
    /*
     func fetchAssignmentsById(courseId: Int, page: Int = 1, pageSize: Int = 999, completion: @escaping ([Assignment]) -> Void) {
         
         let parameters: [String: Any] = [
             "page": page,
             "per_page": pageSize
         ]
         
         performRequest(url: self.canvasAPIURL + "/courses/\(courseId)/assignments", parameters: parameters, headers: self.defaultHeaders) { result in
             switch result {
             case .success(let assignmentRaw):
                 var assignments: [Assignment] = []
                 for assignmentDict in assignmentRaw {
                     guard let id = assignmentDict["id"] as? Int else {
                         print("Error: 'id' is not an Int or is missing in assignment: \(assignmentDict)")
                         continue
                     }
                     guard let name = assignmentDict["name"] as? String else {
                         print("Error: 'name' is not a String or is missing in assignment: \(assignmentDict)")
                         continue
                     }
                     guard let description = assignmentDict["description"] as? String else {
                         print("Error: 'description' is not a String or is missing in assignment: \(assignmentDict)")
                         continue
                     }

                     let dueAtString = assignmentDict["due_at"] as? String
                     let dueAtDate = dueAtString != nil ? self.stringtoDate(dueAtString!) : nil
                     let grade = assignmentDict["grade"] as? Double
                     
                     // Now all required values are non-nil
                     if dueAtDate != nil {
                         let assignment = Assignment(id: id,
                                                     name: name,
                                                     dueDate: dueAtDate,
                                                     description: description,
                                                     grade: grade,
                                                     courseID: courseId)
                         self.database.saveAssignment(assignment, Int32(courseId))
                         assignments.append(assignment)
                     }
                 }
                 completion(assignments)
             case .failure(let error):
                 print("Error: \(error)")
                 completion([])
             }
         }
     }
     */
    
    
    /////
    /*func fetchUsers(completion: @escaping ([Users]) -> Void) {
        performRequest(url: self.canvasAPIURL + "/users", headers: self.defaultHeaders) { result in
            switch result {
            case .success(let usersRaw):
                let users = self.decodeUsers(usersRaw)
                for user in users {
                    self.database.saveUser(user)  // Save each user to the database
                }
                completion(users)
            case .failure(let error):
                print("Error: \(error)")
                completion([])
            }
        }
    }

    func decodeUsers(_ usersRaw: [NSDictionary]) -> [Users] {
        var users: [Users] = []
        
        for userRaw in usersRaw {
            guard let id = userRaw["id"] as? Int,
                  let first_name = userRaw["first_name"] as? String,
                  let last_name = userRaw["last_name"] as? String,
                  let login_id = userRaw["login_id"] as? String else {
                continue
            }

            let user = Users(id: id, first_name: first_name, last_name: last_name, login_id: login_id)
            users.append(user)
        }
        return users
    }
    
    func usersDump(_ users: [Users]) -> String {
        var userDetails = "Users:\n"

        for user in users {
            userDetails += "ID: \(user.id)\n"
            userDetails += "First Name: \(user.first_name)\n"
            userDetails += "Last Name: \(user.last_name)\n"
            userDetails += "Login Email: \(user.login_id)\n"
            userDetails += "---------\n"
        }
        return userDetails
    }*/
}
