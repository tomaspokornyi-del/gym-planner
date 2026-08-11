import Foundation

enum BodyPart: String, Codable, CaseIterable, Identifiable {
    case back = "Záda"
    case chest = "Prsa"
    case arms = "Ruce"
    case shoulders = "Ramena"
    case legs = "Nohy"
    case abs = "Břicho"

    var id: String { rawValue }
}
