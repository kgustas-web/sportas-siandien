import Foundation

/// What the timeline is currently showing. A view over the same events —
/// nothing below it knows the lens exists.
enum Lens: Hashable {
    case all
    /// Cuts across every sport. Following a country is a story, not a sport.
    case lithuania
    case sport(String)

    var label: String? {
        switch self {
        case .all:             return nil
        case .lithuania:       return "Lithuania"
        case .sport(let name): return name
        }
    }
}
