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
    var dueOnDate : Date!
    var agendaAssignments : [(Course, Assignment)]!
    
    @IBOutlet weak var agendaTableView: UITableView!
    @IBOutlet weak var dueOnDateLabel: UILabel!
    
    @IBOutlet weak var ResponseView: UITextView!
    @IBOutlet weak var APIToken: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGR.direction = .left
        view.addGestureRecognizer(swipeLeftGR)
        
        let swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUpGR.direction = .up
        view.addGestureRecognizer(swipeUpGR)
        
        db = Database()
        
        courses = db.fetchAllCoursesWithAssignments()
        //print(courses.count)
        
        // Call the function to load settings from the plist file
        if let loadedSettings = SettingsViewController.loadSettingsFromPlist() {
            // Assign the loaded settings to the settingsValues dictionary
            settingsValues = loadedSettings
        }else{
            print("Error loading settings")
        }
        
        dueOnDate = Date()
        updateDueOnDateLabel(dueOnDate)
        agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
        
        let nib = UINib(nibName: "agendaTableViewCell", bundle: nil)
        agendaTableView.register(nib, forCellReuseIdentifier: "agendaTableViewCell")
        
        agendaTableView.delegate = self
        agendaTableView.dataSource = self
        
    }
    
    fileprivate func updateDueOnDateLabel(_ dueOnDate : Date) {
        let df = DateFormatter()
        df.dateFormat = "EEEE,\nMMMM d, yyyy"
        df.locale = Locale(identifier: "en_US") // Set the locale for English formatting

        dueOnDateLabel.text = df.string(from: dueOnDate)
    }
    
    @IBAction func dueOnDateForward(_ sender: Any) {
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dueOnDate) {
            dueOnDate = tomorrow
            updateDueOnDateLabel(dueOnDate)
            agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
            agendaTableView.reloadData()
        }
    }
    
    @IBAction func dueOnDateBackward(_ sender: Any) {
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: dueOnDate) {
            dueOnDate = yesterday
            updateDueOnDateLabel(dueOnDate)
            agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
            agendaTableView.reloadData()
        }
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ProgressViewController = storyboard.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        navigationController?.pushViewController(ProgressViewController, animated: true)
    }
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        // Pass data to AddViewController here
        addVC.courses = courses
        addVC.canvasClient = canvasClient
        addVC.db = db
        present(addVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            if let destinationVC = segue.destination as? AddViewController {
                // Pass data to AddViewController here
                destinationVC.courses = courses
                destinationVC.canvasClient = canvasClient
                destinationVC.db = db
                
                destinationVC.onClose = { [weak self] in
                    // Update assignments when add page closes
                    self?.agendaAssignments = Course.assignmentsDueOnDate(destinationVC.courses, dueOnDate: self!.dueOnDate)
                    self?.agendaTableView.reloadData()
                }
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
    
    func initCanvasClient() {
        if !settingsValues.contains(where: { $0.key == "API Token" }) {
            print("API Token not in settings. Using APIToken text field")
            settingsValues["API Token"] = APIToken.text!
        }
        
        if settingsValues["API Token"]! == "" {
            print("Error: APIToken empty.")
            return
        }
        
        canvasClient = CanvasAPIClient(authToken: settingsValues["API Token"]! , database: db)
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

extension AgendaViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? agendaTableViewCell {
            
            print(cell.courseLabel.text ?? "")
            print(cell.assignmentLabel.text ?? "")
        }
    }
}

extension AgendaViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agendaAssignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaTableViewCell", for: indexPath) as! agendaTableViewCell
        
        let assignment = agendaAssignments[indexPath.row]
        cell.courseLabel?.text = assignment.0.code
        cell.assignmentLabel?.text = assignment.1.name
        
        
        return cell
    }
}
