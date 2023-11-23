//
//  CanvasAPIClient.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/21/23.
//

import Foundation
import Alamofire

class CanvasAPIClient {
    
    let authToken : String
    let canvasAPIURL : String
    let defaultHeaders: HTTPHeaders
    
    enum APIError: Error {
        case invalidData
        case networkError(Error)
    }
    
    init (authToken: String, canvasAPIURL: String? = "https://ivylearn.ivytech.edu/api/v1/"){
        self.authToken = authToken
        self.canvasAPIURL = canvasAPIURL ?? "https://ivylearn.ivytech.edu/api/v1/"
        self.defaultHeaders = [
            "Authorization": "Bearer \(self.authToken)",
            "Accept": "application/json"
        ]
    }
    

    func performRequest(url: String, headers: HTTPHeaders, completion: @escaping (Result<[NSDictionary], Error>) -> Void) {
        AF.request(url, headers: headers).response { response in
            switch response.result {
            case .success(let json):
                if let jsonData = json as? NSData {
                    do {
                        //let deserializedJson = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as! [NSDictionary]
                        //completion(.success(deserializedJson))
                        
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
}

