import SwiftUI

@main
struct GymGeniusWatchApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var phoneConnectivity = PhoneConnectivity()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(workoutManager)
            .environmentObject(phoneConnectivity)
        }
    }
}
