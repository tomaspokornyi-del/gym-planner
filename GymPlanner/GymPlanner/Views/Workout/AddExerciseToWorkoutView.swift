import SwiftUI
import SwiftData

struct AddExerciseToWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let workout: Workout
    let exercises: [Exercise]

    @State private var selectedBodyPart: BodyPart?
    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesPart = selectedBodyPart == nil || exercise.bodyPart == selectedBodyPart
            let matchesSearch = searchText.isEmpty ||
                exercise.name.localizedCaseInsensitiveContains(searchText)
            return matchesPart && matchesSearch
        }
    }

    private var groupedExercises: [(BodyPart, [Exercise])] {
        let parts = selectedBodyPart.map { [$0] } ?? BodyPart.allCases
        return parts.compactMap { part in
            let items = filteredExercises.filter { $0.bodyPart == part }
            return items.isEmpty ? nil : (part, items)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "Vše",
                                isSelected: selectedBodyPart == nil
                            ) {
                                selectedBodyPart = nil
                            }

                            ForEach(BodyPart.allCases) { part in
                                FilterChip(
                                    title: part.rawValue,
                                    isSelected: selectedBodyPart == part
                                ) {
                                    selectedBodyPart = part
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                if filteredExercises.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(groupedExercises, id: \.0) { part, items in
                        Section(part.rawValue) {
                            ForEach(items) { exercise in
                                Button {
                                    addExercise(exercise)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(exercise.name)
                                                .foregroundStyle(.primary)
                                            if exercise.maxWeight > 0 || exercise.maxReps > 0 {
                                                Text("Rekord: \(formatWeight(exercise.maxWeight)) kg × \(exercise.maxReps)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(.accent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Přidat cvik")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Hledat cvik")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hotovo") { dismiss() }
                }
            }
        }
    }

    private func addExercise(_ exercise: Exercise) {
        let nextOrder = (workout.exercises.map(\.sortOrder).max() ?? -1) + 1
        let entry = WorkoutExercise(exercise: exercise, sortOrder: nextOrder)
        entry.workout = workout
        workout.exercises.append(entry)
        modelContext.insert(entry)
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddExerciseToWorkoutView(workout: Workout(), exercises: [])
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
