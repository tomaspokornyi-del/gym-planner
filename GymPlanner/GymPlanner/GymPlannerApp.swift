import SwiftUI
import SwiftData

@main
struct GymPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self])
    }
}
