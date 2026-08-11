import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var bodyPartRaw: String
    var maxWeight: Double
    var maxReps: Int
    var createdAt: Date

    var bodyPart: BodyPart {
        get { BodyPart(rawValue: bodyPartRaw) ?? .chest }
        set { bodyPartRaw = newValue.rawValue }
    }

    init(
        name: String,
        bodyPart: BodyPart,
        maxWeight: Double = 0,
        maxReps: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.bodyPartRaw = bodyPart.rawValue
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.createdAt = Date()
    }

    func updateRecords(weight: Double, reps: Int) {
        if weight > maxWeight {
            maxWeight = weight
        }
        if reps > maxReps {
            maxReps = reps
        }
    }
}
