import SwiftUI

@main
struct SportsCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
                .preferredColorScheme(.dark)
        }
    }
}
