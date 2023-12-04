//
//  CanvasAPIClient.Student.swift
//  ClassCompassDB
//
//  Created by David Teixeira on 11/28/23.
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
        _ = self.database.openDatabase()
    }
    

    func performRequest(url: String, headers: HTTPHeaders, completion: @escaping (Result<[NSDictionary], Error>) -> Void) {
        AF.request(url, headers: headers).response { response in
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
    
    func fetchCourses(completion: @escaping ([Course]) -> Void) {
        performRequest(url: self.canvasAPIURL + "/courses", headers: self.defaultHeaders) { result in
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

    func decodeCourses(_ coursesRaw: [NSDictionary]) -> [Course] {
        var courses: [Course] = []
        
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
    
    func fetchAssignmentsById(courseId: Int, completion: @escaping ([Assignment]) -> Void) {
        performRequest(url: self.canvasAPIURL + "/courses/\(courseId)/assignments", headers: self.defaultHeaders) { result in
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
                                                    grade: grade)
                        self.database.saveAssignment(assignment)
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
