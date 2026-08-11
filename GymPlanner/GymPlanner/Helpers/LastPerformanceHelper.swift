import Foundation
import SwiftData

struct LastPerformance {
    let weight: Double
    let reps: Int
    let date: Date
}

enum LastPerformanceHelper {
    static func lastPerformance(
        for exercise: Exercise,
        excluding workout: Workout?,
        in context: ModelContext
    ) -> LastPerformance? {
        let exerciseID = exercise.id
        let excludingID = workout?.id

        var descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.isCompleted == true
            },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )

        guard let completedWorkouts = try? context.fetch(descriptor) else {
            return nil
        }

        for completedWorkout in completedWorkouts {
            if completedWorkout.id == excludingID {
                continue
            }

            for entry in completedWorkout.exercises where entry.exercise?.id == exerciseID {
                return LastPerformance(
                    weight: entry.weight,
                    reps: entry.reps,
                    date: completedWorkout.completedAt ?? completedWorkout.date
                )
            }
        }

        return nil
    }
}
