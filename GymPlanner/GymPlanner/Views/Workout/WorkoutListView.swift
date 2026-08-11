import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Workout> { !$0.isCompleted },
        sort: \Workout.date,
        order: .reverse
    ) private var activeWorkouts: [Workout]

    @State private var showingNewWorkout = false

    var body: some View {
        NavigationStack {
            Group {
                if activeWorkouts.isEmpty {
                    ContentUnavailableView(
                        "Žádný trénink",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Vytvořte nový trénink a poskládejte si cviky z knihovny")
                    )
                } else {
                    List {
                        ForEach(activeWorkouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                WorkoutRowView(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
            }
            .navigationTitle("Trénink")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutSheet()
            }
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activeWorkouts[index])
        }
    }
}

private struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date, format: .dateTime.day().month().year())
                .font(.headline)

            Text("\(workout.exercises.count) cviků")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct NewWorkoutSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Datum tréninku") {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Nový trénink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vytvořit") {
                        let workout = Workout(date: date)
                        modelContext.insert(workout)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    WorkoutListView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
