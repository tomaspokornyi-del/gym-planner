import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Workout> { $0.isCompleted },
        sort: \Workout.completedAt,
        order: .reverse
    ) private var archivedWorkouts: [Workout]

    var body: some View {
        NavigationStack {
            Group {
                if archivedWorkouts.isEmpty {
                    ContentUnavailableView(
                        "Archiv je prázdný",
                        systemImage: "archivebox",
                        description: Text("Dokončené tréninky se zobrazí zde")
                    )
                } else {
                    List {
                        ForEach(archivedWorkouts) { workout in
                            NavigationLink {
                                ArchivedWorkoutDetailView(workout: workout)
                            } label: {
                                ArchivedWorkoutRowView(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
            }
            .navigationTitle("Archiv")
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(archivedWorkouts[index])
        }
    }
}

private struct ArchivedWorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date, format: .dateTime.day().month().year())
                .font(.headline)

            HStack {
                Text("\(workout.exercises.count) cviků")
                if let completedAt = workout.completedAt {
                    Text("•")
                    Text("Dokončeno \(completedAt, format: .dateTime.day().month())")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ArchivedWorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        List {
            Section {
                LabeledContent("Datum tréninku") {
                    Text(workout.date, format: .dateTime.day().month().year())
                }
                if let completedAt = workout.completedAt {
                    LabeledContent("Dokončeno") {
                        Text(completedAt, format: .dateTime.day().month().year().hour().minute())
                    }
                }
            }

            Section("Cviky") {
                ForEach(workout.sortedExercises) { entry in
                    if let exercise = entry.exercise {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.headline)
                                Text(exercise.bodyPart.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(formatWeight(entry.weight)) kg × \(entry.reps)")
                                .font(.subheadline.monospacedDigit())
                        }
                    }
                }
            }
        }
        .navigationTitle("Archivovaný trénink")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
