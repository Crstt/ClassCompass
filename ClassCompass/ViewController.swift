//
//  ViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/14/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var courses: [Course] = []
    var canvasClient: CanvasAPIClient!
    
    @IBOutlet weak var ResponseView: UITextView!
    @IBOutlet weak var APIToken: UITextField!
    
    @IBAction func APITestBtn(_ sender: Any) {
        
        canvasClient = CanvasAPIClient(authToken: APIToken.text!)
        
        canvasClient.fetchCourses(){ fetchedCourses in
            self.courses = fetchedCourses
            let courseDump = Course.dump(fetchedCourses)
            print(courseDump)
            self.ResponseView.text = courseDump
        }
    }
    @IBAction func fetchAssignments(_ sender: Any) {
        print(Course.dump(self.courses))
        canvasClient.fetchAssignmentsById(courseId: self.courses[0].id){ fetchedAssignments in
            self.courses[0].assignments = fetchedAssignments
            print(Assignment.dump(fetchedAssignments))
            self.ResponseView.text = Assignment.dump(fetchedAssignments)
        }
        
    }
}
