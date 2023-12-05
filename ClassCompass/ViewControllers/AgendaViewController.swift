//
//  ViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/14/23.
//

import UIKit

class AgendaViewController: UIViewController {
    
    var courses: [Course] = []
    var canvasClient: CanvasAPIClient!
    var db: Database!
    var settingsValues = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agenda"
        let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGR.direction = .left
        view.addGestureRecognizer(swipeLeftGR)
        
        let swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUpGR.direction = .up
        view.addGestureRecognizer(swipeUpGR)
        
        db = Database()
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ProgressViewController = storyboard.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        navigationController?.pushViewController(ProgressViewController, animated: true)
    }
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let AddViewController = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        present(AddViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            if let destinationVC = segue.destination as? AddViewController {
                // Pass data to AddViewController here
                destinationVC.courses = courses
                destinationVC.canvasClient = canvasClient
                destinationVC.db = db
            }else if segue.identifier == "settingsSegue"{
                if let destinationVC = segue.destination as? SettingsViewController {
                    destinationVC.db = db
                    destinationVC.settingsValues = settingsValues
                }
            }
        }
    }
    
    @IBOutlet weak var ResponseView: UITextView!
    @IBOutlet weak var APIToken: UITextField!
    
    @IBAction func APITestBtn(_ sender: Any) {
        
        canvasClient = CanvasAPIClient(authToken: APIToken.text!, database: db)
        
        canvasClient.fetchCourses(){ fetchedCourses in
            self.courses = fetchedCourses
            let courseDump = Course.dump(fetchedCourses)
            //print(courseDump)
            self.ResponseView.text = courseDump
        }
    }
    @IBAction func fetchAssignments(_ sender: Any) {
        
        self.ResponseView.text = ""
        for index in 0..<self.courses.count {
            let course = self.courses[index]
            canvasClient.fetchAssignmentsById(courseId: course.id) { fetchedAssignments in
                self.ResponseView.text += course.code + "\n------------------------\n"
                self.courses[index].assignments = fetchedAssignments
                self.ResponseView.text += Assignment.dump(fetchedAssignments)
            }
        }
    }
}
