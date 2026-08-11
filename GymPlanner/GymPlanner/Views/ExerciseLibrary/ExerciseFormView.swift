import SwiftUI
import SwiftData

struct ExerciseFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise?

    @State private var name: String
    @State private var bodyPart: BodyPart

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        _name = State(initialValue: exercise?.name ?? "")
        _bodyPart = State(initialValue: exercise?.bodyPart ?? .chest)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Název cviku") {
                    TextField("např. Bench press", text: $name)
                }

                Section("Partie") {
                    Picker("Partie", selection: $bodyPart) {
                        ForEach(BodyPart.allCases) { part in
                            Text(part.rawValue).tag(part)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                if let exercise {
                    Section("Rekordy") {
                        LabeledContent("Nejvyšší váha") {
                            Text("\(formatWeight(exercise.maxWeight)) kg")
                        }
                        LabeledContent("Nejvíce opakování") {
                            Text("\(exercise.maxReps)×")
                        }
                    }
                }
            }
            .navigationTitle(exercise == nil ? "Nový cvik" : "Upravit cvik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložit") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let exercise {
            exercise.name = trimmedName
            exercise.bodyPart = bodyPart
        } else {
            let newExercise = Exercise(name: trimmedName, bodyPart: bodyPart)
            modelContext.insert(newExercise)
        }

        dismiss()
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}

#Preview {
    ExerciseFormView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
