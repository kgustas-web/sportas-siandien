import Foundation

/// How loudly a row speaks. Nothing is ever hidden — everything you follow
/// stays in the timeline and stays reachable. Prominence only decides weight.
enum Prominence: Int, Comparable {
    case quiet = 0     // present, but not asking for anything
    case normal = 1
    case surfaced = 2  // your teams, your country, a reason worth reading

    static func < (a: Prominence, b: Prominence) -> Bool { a.rawValue < b.rawValue }
}
