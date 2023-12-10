//
//  ProgressViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/26/23.
//

import UIKit
import SwiftUI

class CourseData: ObservableObject {
    @Published var courses: [Course] = []
}

class ProgressViewController: UIViewController {
    var db: Database!
    @ObservedObject var courseData = CourseData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress"
        db = Database()
        courseData.courses = db.fetchAllCoursesWithAssignments()
        let courseProgress = db.calculateOngoingCoursesProgress(courses: courseData.courses)
        
        guard let dbPoint = db.openDatabase() else {
            print("Database failed to open")
            return
        }
        var assignmentProgress: [Int: [AssignmentStatus: Float]] = [:]
        for course in courseData.courses {
            assignmentProgress[course.id] = db.calculateAssignmentsStatusPercentage(using: dbPoint, courseID: course.id)
        }
        
        // Create a SwiftUI view for a scrollable progress bar container
        let scrollableProgressContainer = ScrollableProgressContainerView(courseProg: courseProgress, assignProg: assignmentProgress, courseData: courseData)
        
        // Create a hosting controller with the SwiftUI view
        let hostingController = UIHostingController(rootView: scrollableProgressContainer)
        
        // Add as a child of the current view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set up constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// SwiftUI view that contains both progress bars within a scrollable view
struct ScrollableProgressContainerView: View {
    var courseProg: Float
    var assignProg: [Int: [AssignmentStatus: Float]]
    @ObservedObject var courseData: CourseData

    var body: some View {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Total Course Completion Progress:")
                        .font(.headline)
                    ProgressBar(progress: .constant(courseProg))
                        .scaleEffect(0.5)

                    // Ensure this ForEach uses the 'courses' array correctly
                    ForEach($courseData.courses, id: \.id) { $course in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(course.name) Progress:")
                                .font(.headline)
                                .padding(.top)
                            
                            // This nested ForEach iterates over AssignmentStatus
                            ForEach(AssignmentStatus.allCases, id: \.self) { status in
                                if let statusProgress = assignProg[course.id]?[status] {
                                    HStack {
                                        Text(status.rawValue)
                                            .font(.subheadline)
                                        ProgressBar(progress: .constant(statusProgress))
                                            .scaleEffect(0.5)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


