import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var sortOrder: Int
    var reps: Int
    var weight: Double
    var exercise: Exercise?
    var workout: Workout?

    init(exercise: Exercise, sortOrder: Int, reps: Int = 0, weight: Double = 0) {
        self.id = UUID()
        self.exercise = exercise
        self.sortOrder = sortOrder
        self.reps = reps
        self.weight = weight
    }
}
