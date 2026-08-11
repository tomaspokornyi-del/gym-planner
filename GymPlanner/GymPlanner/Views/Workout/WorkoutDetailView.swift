import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var workout: Workout

    @Query(sort: \Exercise.name) private var allExercises: [Exercise]

    @State private var showingAddExercise = false
    @State private var showingCompleteAlert = false

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Datum",
                    selection: $workout.date,
                    displayedComponents: .date
                )
            }

            Section("Cviky") {
                if workout.sortedExercises.isEmpty {
                    Text("Přidejte cviky z knihovny")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(workout.sortedExercises) { entry in
                        if let exercise = entry.exercise {
                            WorkoutExerciseRowView(
                                entry: entry,
                                exercise: exercise,
                                workout: workout
                            )
                        }
                    }
                    .onDelete(perform: deleteExercises)
                    .onMove(perform: moveExercises)
                }
            }

            if !workout.sortedExercises.isEmpty {
                Section {
                    Button {
                        showingCompleteAlert = true
                    } label: {
                        Label("Dokončit trénink", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Trénink")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(allExercises.isEmpty)
            }

            if !workout.sortedExercises.isEmpty {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseToWorkoutView(workout: workout, exercises: allExercises)
        }
        .alert("Dokončit trénink?", isPresented: $showingCompleteAlert) {
            Button("Zrušit", role: .cancel) {}
            Button("Dokončit") {
                workout.complete()
                dismiss()
            }
        } message: {
            Text("Trénink bude přesunut do archivu a rekordy cviků se aktualizují.")
        }
    }

    private func deleteExercises(at offsets: IndexSet) {
        let sorted = workout.sortedExercises
        for index in offsets {
            modelContext.delete(sorted[index])
        }
        reindexExercises()
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        var sorted = workout.sortedExercises
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, entry) in sorted.enumerated() {
            entry.sortOrder = index
        }
    }

    private func reindexExercises() {
        for (index, entry) in workout.sortedExercises.enumerated() {
            entry.sortOrder = index
        }
    }
}

private struct WorkoutExerciseRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: WorkoutExercise

    let exercise: Exercise
    let workout: Workout

    private var lastPerformance: LastPerformance? {
        LastPerformanceHelper.lastPerformance(
            for: exercise,
            excluding: workout,
            in: modelContext
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Text(exercise.bodyPart.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            if let last = lastPerformance {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Minule: \(formatWeight(last.weight)) kg × \(last.reps)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Váha (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", value: $entry.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Opakování")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0", value: $entry.reps, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout())
    }
    .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
