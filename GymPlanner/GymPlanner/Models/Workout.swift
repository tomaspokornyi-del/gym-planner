import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var date: Date
    var isCompleted: Bool
    var completedAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise]

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.isCompleted = false
        self.completedAt = nil
        self.exercises = []
    }

    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    func complete() {
        isCompleted = true
        completedAt = Date()
        for entry in exercises {
            entry.exercise?.updateRecords(weight: entry.weight, reps: entry.reps)
        }
    }
}
