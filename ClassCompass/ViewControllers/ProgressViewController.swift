//
//  ProgressViewController.swift
//  ClassCompass
//
//  Created by David Teixeira on 11/26/23.
//

import UIKit
import SwiftUI

class CourseData: ObservableObject {
    @Published var courses: [Course] = []
}

class ProgressViewController: UIViewController {
    var db: Database!
    @ObservedObject var courseData = CourseData()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database()
        courseData.courses = db.fetchAllCoursesWithAssignments()
        let courseProgress = db.calculateOngoingCoursesProgress(courses: courseData.courses)
        
        guard let dbPoint = db.openDatabase() else {
            print("Database failed to open")
            return
        }

        var assignmentProgress: [Int: (Float, [AssignmentStatus: Float])] = [:]
        for course in courseData.courses {
            let courseProgressData = db.calculateAllCoursesAssignmentsProgress(using: dbPoint, courses: [course])
            if let courseData = courseProgressData[course.id] {
                assignmentProgress[course.id] = courseData
            }
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
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// SwiftUI view that contains both progress bars within a scrollable view
struct ScrollableProgressContainerView: View {
    var courseProg: Float
    var assignProg: [Int: (Float, [AssignmentStatus: Float])]
    @ObservedObject var courseData: CourseData
    
    var body: some View {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Total Course Completion Progress:")
                        .font(.headline)
                    
                    // Apply the same scale effect to the total course completion progress bar
                    ProgressBar(progress: .constant(courseProg))
                        .scaleEffect(0.5)
                    
                    // Iterate over each course. Only include courses that are currently ongoing
                    ForEach(courseData.courses.filter { $0.endDate >= Date() }, id: \.id) { course in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(course.name) Progress:")
                                .font(.headline)
                                .padding(.top)

                            // Label for course completion status
                            Text("Course Completion Status:")
                                .font(.subheadline)
                                .padding(.bottom, 5)

                            if let courseProgress = assignProg[course.id] {
                                // Display progress bar for the course's overall completion
                                ProgressBar(progress: .constant(courseProgress.0))
                                    .scaleEffect(0.5)
                                
                                // Divider with label for assignments in progress
                                Text("Assignments In Progress")
                                    .font(.subheadline)
                                    .padding(.vertical, 5)
                                Divider()

                                // Display progress bars for each assignment status
                                ForEach(AssignmentStatus.allCases, id: \.self) { status in
                                    if let statusProgress = courseProgress.1[status] {
                                        HStack {
                                            Text(status.rawValue)
                                                .font(.subheadline)
                                            
                                            // Check if the current course's completion status is 100%
                                            if let courseProgress = assignProg[course.id], courseProgress.0 == 1.0 {
                                                // If the course is 100% complete, set assignment status to 100%
                                                ProgressBar(progress: .constant(1.0))
                                                    .scaleEffect(0.5)
                                            } else {
                                                // Otherwise, use the regular statusProgress
                                                ProgressBar(progress: .constant(statusProgress))
                                                    .scaleEffect(0.5)
                                            }
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
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

