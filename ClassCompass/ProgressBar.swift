//
//  ProgressBar.swift
//  ClassCompass
//
//  Created by David Teixeira on 12/10/23.
//

import SwiftUI

// Create the struct for progress bar
struct ProgressBar: View {
    // Declare Local Variables
    @Binding var progress: Float // Bind to dynamic progress value
    var color: Color = Color.green

    // Create the background and foreground circle
    var body: some View {
        ZStack {
            // Background
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.2)
                .foregroundColor(Color.gray)
            
            // Foreground
            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0))) // Trims circle to represent the 'progress'
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0)) // Rotates the circle to start at top N
                .animation(.easeInOut(duration: 2.0), value: progress) // Apply the animation.
        }
    }
}

// Struct wrapper to hold the ProgressBar
struct ProgressViewWrapper: View {
    @State private var progress: Float = 0.0

    var body: some View {
        ProgressBar(progress: $progress)
            .onAppear {
                // Initialize the progress or update it based on your app's logic
                self.progress = 0.05 // Starting progress
                // Example to increment the progress
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.progress = 0.5 // Update to new progress
                }
            }
    }
}

struct ScrollableProgressBarView: View {
    @Binding var progress: Float

    var body: some View {
        ScrollView {
            VStack {
                ProgressBar(progress: $progress)
                    .scaleEffect(1) // Adjust scale to make it larger
                    .padding([.leading, .trailing], 1)
            }
        }
    }
}

/* struct ContentView: View {
    // Example progress value
    @State private var progress = 0.0

    var body: some View {
        VStack {
            // Circular ProgressView
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2) // Increase the size of the progress view
                .padding()

            // Button to simulate progress
            Button("Increment Progress") {
                // Calculate your progress based on active courses
                // For example, incrementing by 0.1 for demonstration
                withAnimation {
                    progress += 0.1
                }
            }
        }
    }
} */

