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
        
        // Call the function to load settings from the plist file
        if let loadedSettings = SettingsViewController.loadSettingsFromPlist() {
            // Assign the loaded settings to the settingsValues dictionary
            settingsValues = loadedSettings
        }else{
            print("Error loading settings")
        }

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
            }
        }else if segue.identifier == "settingsSegue"{
            if let destinationVC = segue.destination as? SettingsViewController {
                destinationVC.db = db
                destinationVC.settingsValues = settingsValues
                destinationVC.settingsDidChange = { updatedSettings in
                    self.settingsValues = updatedSettings
                }
            }
        }
    }
    
    @IBOutlet weak var ResponseView: UITextView!
    @IBOutlet weak var APIToken: UITextField!
    
    func initCanvasClient() {
        if !settingsValues.contains(where: { $0.key == "API Token" }) {
            print("API Token not in settings. Using APIToken text field")
            settingsValues["API Token"] = APIToken.text!
        }
        
        if settingsValues["API Token"] as! String == "" {
            print("Error: APIToken empty.")
            return
        }
        
        canvasClient = CanvasAPIClient(authToken: settingsValues["API Token"]! as! String, database: db)
    }
    
    @IBAction func APITestBtn(_ sender: Any) {
        
        initCanvasClient()
        
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
