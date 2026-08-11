import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var showingAddExercise = false
    @State private var exerciseToEdit: Exercise?

    private var groupedExercises: [(BodyPart, [Exercise])] {
        BodyPart.allCases.compactMap { part in
            let filtered = exercises.filter { $0.bodyPart == part }
            return filtered.isEmpty ? nil : (part, filtered.sorted { $0.name < $1.name })
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if exercises.isEmpty {
                    ContentUnavailableView(
                        "Žádné cviky",
                        systemImage: "dumbbell",
                        description: Text("Přidejte první cvik do knihovny pomocí tlačítka +")
                    )
                } else {
                    List {
                        ForEach(groupedExercises, id: \.0) { part, items in
                            Section(part.rawValue) {
                                ForEach(items) { exercise in
                                    ExerciseRowView(exercise: exercise)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            exerciseToEdit = exercise
                                        }
                                }
                                .onDelete { offsets in
                                    deleteExercises(in: items, at: offsets)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Knihovna cviků")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseFormView()
            }
            .sheet(item: $exerciseToEdit) { exercise in
                ExerciseFormView(exercise: exercise)
            }
        }
    }

    private func deleteExercises(in items: [Exercise], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

private struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)

            HStack(spacing: 12) {
                Label("\(formatWeight(exercise.maxWeight)) kg", systemImage: "scalemass.fill")
                Label("\(exercise.maxReps)×", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

#Preview {
    ExerciseLibraryView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
