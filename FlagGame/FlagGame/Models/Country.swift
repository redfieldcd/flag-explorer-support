import Foundation

enum Continent: String, CaseIterable, Identifiable {
    case all = "All"
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .all: return "🌍"
        case .africa: return "🌍"
        case .asia: return "🌏"
        case .europe: return "🌍"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🌎"
        case .oceania: return "🌏"
        }
    }
}

struct Country: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let flag: String // emoji flag
    let code: String // ISO 3166-1 alpha-2
    let continent: Continent
    let capital: String
    let funFact: String

    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
