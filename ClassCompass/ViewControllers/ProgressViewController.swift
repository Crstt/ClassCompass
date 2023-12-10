//
//  ProgressViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/26/23.
//

import UIKit
import SwiftUI

class ProgressViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress"

        // Set initial progress values
        let assignmentsProgressValue: Float = 0.5 // Replace with actual progress data
        let coursesProgressValue: Float = 0.7    // Replace with actual progress data

        // Create a SwiftUI view for a scrollable progress bar container
        let scrollableProgressContainer = ScrollableProgressContainerView(assignmentsProgress: assignmentsProgressValue, coursesProgress: coursesProgressValue)
        
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
    var assignmentsProgress: Float
    var coursesProgress: Float

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Assignments Progress")
                    .font(.headline)
                ProgressBar(progress: .constant(assignmentsProgress))
                    .scaleEffect(0.5)

                Text("Courses Progress")
                    .font(.headline)
                ProgressBar(progress: .constant(coursesProgress))
                    .scaleEffect(0.5)
            }
            .padding()
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


