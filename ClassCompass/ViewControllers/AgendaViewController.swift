//
//  ViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/14/23.
//

import UIKit

/**
 `AgendaViewController` is a UIViewController subclass that manages and displays an agenda.

 It is responsible for:
 - Fetching agenda items from a data source
 - Displaying these items in a user-friendly format
 - Handling user interactions with these items, such as selecting an item to view more details

 This controller uses a UITableView to display the agenda items, with each item represented 
 by a custom UITableViewCell.

 The agenda items are fetched from the data source in `viewDidLoad`, and the table view is 
 reloaded to display the items.

 User interactions with the agenda items are handled in the table view's delegate methods.
 */
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
    
    /**
    `viewWillAppear` is a method in UIViewController that is called just before
    the view controller's view is about to be added to a view hierarchy and become visible.

    In `AgendaViewController`, this method is overridden to perform additional tasks associated 
    with presenting the view. 

    If you're fetching data from a remote source or performing an update that could change the data, 
    you might want to do it here so the updated data will be displayed when the view appears.

    Remember to call `super.viewWillAppear(animated)` at the start of your method to ensure that the 
    view hierarchy is set up correctly.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Init Database
        db = Database()
        
        // Get courses and assignments from database
        courses = db.fetchAllCoursesWithAssignments()
        
        // Load settings from the plist file
        if let loadedSettings = SettingsViewController.loadSettingsFromPlist() {
            // Assign the loaded settings to the settingsValues dictionary
            settingsValues = loadedSettings
        }else{
            print("Error loading settings")
        }
        
        initAndFetchFromCanvas()
        
        // Set the Agenda date and courses
        dueOnDate = Date()
        updateDueOnDateLabel(dueOnDate)
        agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
        agendaTableView.reloadData()
    }
    
    /**
        This method is called after the view controller's view is loaded into memory.
        It sets up the gestures, registers the table view cell, and assigns the delegate
        and data source for the agenda table view.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define Gestures
        let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGR.direction = .left
        view.addGestureRecognizer(swipeLeftGR)
        
        let swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUpGR.direction = .up
        view.addGestureRecognizer(swipeUpGR)
        
        // Set up Agenda table
        let nib = UINib(nibName: "agendaTableViewCell", bundle: nil)
        agendaTableView.register(nib, forCellReuseIdentifier: "agendaTableViewCell")
        
        agendaTableView.delegate = self
        agendaTableView.dataSource = self
    }
    
    /**
     Initializes and fetches data from the Canvas API.
     
     This function initializes the Canvas client and fetches courses and assignments from the Canvas API. If the initialization is successful, it fetches the courses and appends them to the existing courses array. Then, for each course, it fetches the assignments and appends them to the existing assignments array for that course.
     
     - Note: This function assumes that the `courses` and `canvasClient` properties are already initialized.
     */
    fileprivate func initAndFetchFromCanvas() {
        // Init and run Canvas API
        if initCanvasClient() {
            
            canvasClient.fetchCourses(){ fetchedCourses in
                //self.courses = fetchedCourses
                let existingIDs = Set(self.courses.map(\.id))
                self.courses.append(contentsOf: fetchedCourses.filter { !existingIDs.contains($0.id) })
                
                for index in 0..<self.courses.count {
                    let course = self.courses[index]
                    self.canvasClient.fetchAssignmentsById(courseId: course.id) { fetchedAssignments in
                        let existingIDs = Set(self.courses[index].assignments.map(\.id))
                        self.courses[index].assignments.append(contentsOf: fetchedAssignments.filter { !existingIDs.contains($0.id) })
                    }
                }
            }
        }else{
            performSegue(withIdentifier: "settingsSegue", sender: self)
        }
    }
    
    /// Updates the due on date label with the formatted date.
    ///
    /// - Parameter dueOnDate: The date to be formatted and displayed on the label.
    fileprivate func updateDueOnDateLabel(_ dueOnDate : Date) {
        let df = DateFormatter()
        df.dateFormat = "EEEE,\nMMMM d, yyyy"
        df.locale = Locale(identifier: "en_US") // Set the locale for English formatting
        
        dueOnDateLabel.text = df.string(from: dueOnDate)
    }
    
    /**
     `dueOnDateForward` is a method in `AgendaViewController` that advances the currently viewed date on the agenda to the next day and reloads all assignments for that day.

     When this method is called, it:
     - Advances the `dueOnDate` property to the next day.
     - Fetches all assignments due on the new `dueOnDate` from the data source.
     - Reloads the table view to display the new assignments.

     This method does not return a value and does not take any arguments. It should be called when the user wants to view the assignments for the next day.
     */
    @IBAction func dueOnDateForward(_ sender: Any) {
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dueOnDate) {
            dueOnDate = tomorrow
            updateDueOnDateLabel(dueOnDate)
            agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
            agendaTableView.reloadData()
        }
    }
    
    /**
     `dueOnDateBackward` is a method in `AgendaViewController` that moves the currently viewed date on the agenda to the previous day and reloads all assignments for that day.

     When this method is called, it:
     - Advances the `dueOnDate` property to the previous day.
     - Fetches all assignments due on the new `dueOnDate` from the data source.
     - Reloads the table view to display the new assignments.

     This method does not return a value and does not take any arguments. It should be called when the user wants to view the assignments for the previous day.
     */
    @IBAction func dueOnDateBackward(_ sender: Any) {
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: dueOnDate) {
            dueOnDate = yesterday
            updateDueOnDateLabel(dueOnDate)
            agendaAssignments = Course.assignmentsDueOnDate(courses, dueOnDate: dueOnDate)
            agendaTableView.reloadData()
        }
    }
    
    /**
        Handles the swipe left gesture action.
        
        - Parameter sender: The UISwipeGestureRecognizer that triggers the action.
    */
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ProgressViewController = storyboard.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        navigationController?.pushViewController(ProgressViewController, animated: true)
    }
    
    /**
     Handles the swipe up gesture action.
     
     - Parameter sender: The `UISwipeGestureRecognizer` that triggered the action.
     */
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        // Pass data to AddViewController here
        addVC.courses = courses
        addVC.canvasClient = canvasClient
        addVC.db = db
        present(addVC, animated: true)
    }
    
    /// Prepares for a segue and passes data to the destination view controller.
    ///
    /// - Parameters:
    ///   - segue: The segue being performed.
    ///   - sender: The object that initiated the segue.
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
        } else if segue.identifier == "settingsSegue" {
            if let destinationVC = segue.destination as? SettingsViewController {
                destinationVC.db = db
                destinationVC.settingsValues = settingsValues
                destinationVC.settingsDidChange = { updatedSettings in
                    self.settingsValues = updatedSettings
                    
                    self.initAndFetchFromCanvas()
                }
            }
        }
    }
    
    /**
     Initializes the Canvas client and sets up the authentication token.
     
     - Returns: A boolean value indicating whether the initialization was successful.
     */
    func initCanvasClient() -> Bool{
        if !settingsValues.contains(where: { $0.key == "API Token" }) {
            print("API Token not in settings. Using APIToken text field")
            settingsValues["API Token"] = APIToken.text!
            return false
        }
        
        if settingsValues["API Token"]! == "" {
            print("Error: APIToken empty.")
            return false
        }
        
        canvasClient = CanvasAPIClient(authToken: settingsValues["API Token"]! , database: db)
        return true
    }
    
    /**
     This method is called when the APITestBtn is tapped. It initializes the Canvas client and fetches the courses from the Canvas API. It then updates the courses property and displays the course information in the ResponseView.

     - Parameter sender: The object that triggered the action.
     */
    @IBAction func APITestBtn(_ sender: Any) {
        if initCanvasClient(){
            
            canvasClient.fetchCourses(){ fetchedCourses in
                self.courses = fetchedCourses
                let courseDump = Course.dump(fetchedCourses)
                //print(courseDump)
                self.ResponseView.text = courseDump
            }
        }
    }


    /**
     Fetches assignments for each course and updates the response view.

     - Parameter sender: The object that triggered the action.
     */
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

/**
   This extension conforms to the UITableViewDelegate protocol and provides additional functionality for the AgendaViewController class.
*/
extension AgendaViewController: UITableViewDelegate{
    /**
        Called when a table view cell is selected.
        
        - Parameters:
            - tableView: The table view containing the selected cell.
            - indexPath: The index path of the selected cell.
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? agendaTableViewCell {
            
            print(cell.courseLabel.text ?? "")
            print(cell.assignmentLabel.text ?? "")
        }
    }

    /**
        Returns the height for a table view row at a specified index path.
        
        - Parameters:
            - tableView: The table view requesting this information.
            - indexPath: The index path of the row.
        
        - Returns: The height for the row.
    */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

/**
 The extension of `AgendaViewController` that conforms to the `UITableViewDataSource` protocol.
 This extension provides the necessary data source methods for populating the table view in the `AgendaViewController`.
 */
extension AgendaViewController: UITableViewDataSource{
    /**
     Returns the number of rows in the table view section.
     
     - Parameters:
        - tableView: The table view object displaying the data.
        - section: The section index in the table view.
     
     - Returns: The number of rows in the specified section.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agendaAssignments.count
    }
    
    /**
     Configures and returns a table view cell for the specified index path.
     
     - Parameters:
        - tableView: The table view object requesting the cell.
        - indexPath: The index path that specifies the location of the cell.
     
     - Returns: A configured table view cell for the specified index path.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaTableViewCell", for: indexPath) as! agendaTableViewCell
        
        let agendaItem = agendaAssignments[indexPath.row]
        cell.courseLabel?.text = agendaItem.0.code
        cell.assignmentLabel?.text = agendaItem.1.name
        
        let calendar = Calendar.current
        let startOfDayForDueOnDate = calendar.startOfDay(for: Date())
        let startOfDayForDueDate = calendar.startOfDay(for: agendaItem.1.dueDate!)
        
        let components = calendar.dateComponents([.day], from: startOfDayForDueOnDate, to: startOfDayForDueDate)
        
        if let days = components.day {
            cell.daysTillDue?.text = days == 0 ? "Today" : "\(days)"
        } else {
            cell.daysTillDue?.text = "-" // Handle nil case as needed
        }
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        df.locale = Locale(identifier: "en_US")
        
        cell.dueDate?.text = df.string(from: agendaItem.1.dueDate!)
        
        cell.checkButton = { [weak self] in
            
            agendaItem.1.status = .completed
            self?.db.updateAssignmentCompleted(assignmentId : agendaItem.1.id)
            self?.agendaAssignments = Course.assignmentsDueOnDate(self!.courses, dueOnDate: self!.dueOnDate)
            self?.agendaTableView.reloadData()
        }
        
        return cell
    }
}