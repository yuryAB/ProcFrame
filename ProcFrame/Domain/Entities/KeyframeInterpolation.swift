import Foundation

enum KeyframeInterpolation: String, CaseIterable, Codable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case stepped

    func apply(_ t: Double) -> Double {
        let clamped = max(0, min(t, 1))
        switch self {
        case .linear:
            return clamped
        case .easeIn:
            return clamped * clamped
        case .easeOut:
            let inv = 1 - clamped
            return 1 - inv * inv
        case .easeInOut:
            if clamped < 0.5 {
                return 2 * clamped * clamped
            }
            let inv = -2 * clamped + 2
            return 1 - (inv * inv) / 2
        case .stepped:
            return clamped < 1 ? 0 : 1
        }
    }

    var displayName: String {
        switch self {
        case .linear:
            return "Linear"
        case .easeIn:
            return "Ease In"
        case .easeOut:
            return "Ease Out"
        case .easeInOut:
            return "Ease In Out"
        case .stepped:
            return "Stepped"
        }
    }
}
