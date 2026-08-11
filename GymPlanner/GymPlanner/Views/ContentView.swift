import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExerciseLibraryView()
                .tabItem {
                    Label("Knihovna", systemImage: "dumbbell.fill")
                }

            WorkoutListView()
                .tabItem {
                    Label("Trénink", systemImage: "figure.strengthtraining.traditional")
                }

            ArchiveView()
                .tabItem {
                    Label("Archiv", systemImage: "archivebox.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
