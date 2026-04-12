import SwiftUI
import HealthKit

// MARK: - Theme Colors

extension Color {
    static let appBg = Color(red: 0.04, green: 0.055, blue: 0.1)
    static let cardBg = Color(red: 0.067, green: 0.094, blue: 0.153)
    static let accent = Color(red: 0.231, green: 0.51, blue: 0.965)
    static let accentSecondary = Color(red: 0.133, green: 0.827, blue: 0.933)
    static let success = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let warning = Color(red: 0.961, green: 0.62, blue: 0.043)
    static let error = Color(red: 0.957, green: 0.247, blue: 0.369)
    static let textPrimary = Color(red: 0.949, green: 0.949, blue: 0.949)
    static let textSecondary = Color(red: 0.58, green: 0.639, blue: 0.722)
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var phoneConnectivity: PhoneConnectivity

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("GymGenius")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.accent)
                    .padding(.top, 4)

                // Start Workout
                NavigationLink(destination: TemplateListView()) {
                    HStack {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 16))
                        Text("Start Workout")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                // Heart Rate
                NavigationLink(destination: HeartRateView()) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.error)
                        Text("Heart Rate")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.cardBg)
                    .foregroundColor(.textPrimary)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Today's Stats
                HStack(spacing: 6) {
                    MiniStatView(
                        value: "4,823",
                        label: "Steps",
                        color: .accent
                    )
                    MiniStatView(
                        value: "312",
                        label: "Cal",
                        color: .warning
                    )
                }
                .padding(.top, 4)

                // Connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(phoneConnectivity.isPhoneReachable ? Color.success : Color.textSecondary)
                        .frame(width: 6, height: 6)
                    Text(phoneConnectivity.isPhoneReachable ? "Phone connected" : "Phone not connected")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Mini Stat View

struct MiniStatView: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.cardBg)
        .cornerRadius(10)
    }
}

// MARK: - Template List View

struct TemplateListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    let templates = [
        ("Push Day", "Chest, Shoulders, Triceps"),
        ("Pull Day", "Back, Biceps"),
        ("Leg Day", "Quads, Hamstrings, Calves"),
        ("Upper Body", "Full Upper"),
        ("Full Body", "All Muscle Groups"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text("Select Workout")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.bottom, 4)

                ForEach(templates, id: \.0) { template in
                    NavigationLink(destination: ActiveWorkoutView(workoutName: template.0)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.0)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textPrimary)
                            Text(template.1)
                                .font(.system(size: 10))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.cardBg)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - Active Workout View

struct ActiveWorkoutView: View {
    let workoutName: String
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var phoneConnectivity: PhoneConnectivity
    @State private var elapsedSeconds = 0
    @State private var currentSetIndex = 0
    @State private var isResting = false
    @State private var restSeconds = 0
    @State private var navigateToSummary = false

    let totalSets = 4
    let exerciseName = "Bench Press"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Timer
                Text(formatTime(elapsedSeconds))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.accent)

                // Heart Rate
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(heartRateColor(workoutManager.currentHeartRate))
                    Text("\(workoutManager.currentHeartRate)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(heartRateColor(workoutManager.currentHeartRate))
                    Text("BPM")
                        .font(.system(size: 9))
                        .foregroundColor(.textSecondary)
                }

                if isResting {
                    // Rest Timer
                    VStack(spacing: 4) {
                        Text("REST")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.warning)

                        Text(formatTime(restSeconds))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.textPrimary)

                        Button("Skip") {
                            isResting = false
                            WKInterfaceDevice.current().play(.click)
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cardBg)
                    .cornerRadius(12)
                } else {
                    // Current Exercise
                    VStack(spacing: 4) {
                        Text(exerciseName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        Text("Set \(currentSetIndex + 1) of \(totalSets)")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)

                        Text("185 lbs  |  8 reps")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cardBg)
                    .cornerRadius(12)

                    // Complete Set
                    Button {
                        completeSet()
                    } label: {
                        Text(currentSetIndex < totalSets - 1 ? "Complete Set" : "Finish")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .background(currentSetIndex < totalSets - 1 ? Color.success : Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(.plain)
                }

                // End Workout
                Button {
                    navigateToSummary = true
                } label: {
                    Text("End Workout")
                        .font(.system(size: 11))
                        .foregroundColor(.error)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(workoutName)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            elapsedSeconds += 1
            if isResting && restSeconds > 0 {
                restSeconds -= 1
                if restSeconds == 0 {
                    isResting = false
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
        .onAppear {
            workoutManager.startWorkout()
        }
        .onDisappear {
            workoutManager.endWorkout()
        }
        .navigationDestination(isPresented: $navigateToSummary) {
            WorkoutSummaryView(
                duration: elapsedSeconds,
                setsCompleted: currentSetIndex + 1,
                avgHeartRate: workoutManager.averageHeartRate
            )
        }
    }

    private func completeSet() {
        WKInterfaceDevice.current().play(.success)

        phoneConnectivity.sendSetCompleted(
            exerciseName: exerciseName,
            setNumber: currentSetIndex + 1
        )

        if currentSetIndex < totalSets - 1 {
            currentSetIndex += 1
            isResting = true
            restSeconds = 90
        } else {
            navigateToSummary = true
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func heartRateColor(_ bpm: Int) -> Color {
        switch bpm {
        case ..<100: return .success
        case 100..<120: return .accentSecondary
        case 120..<140: return .warning
        case 140..<160: return .orange
        default: return .error
        }
    }
}

// MARK: - Workout Summary View

struct WorkoutSummaryView: View {
    let duration: Int
    let setsCompleted: Int
    let avgHeartRate: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.success)

                Text("Workout Complete!")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textPrimary)

                // Stats grid
                HStack(spacing: 6) {
                    MiniStatView(
                        value: formatTime(duration),
                        label: "Duration",
                        color: .accent
                    )
                    MiniStatView(
                        value: "\(setsCompleted)",
                        label: "Sets",
                        color: .success
                    )
                }

                HStack(spacing: 6) {
                    MiniStatView(
                        value: "4,200",
                        label: "Volume",
                        color: .warning
                    )
                    MiniStatView(
                        value: "\(avgHeartRate)",
                        label: "Avg HR",
                        color: .error
                    )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .background(Color.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Heart Rate View

struct HeartRateView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var animateHeart = false

    var body: some View {
        VStack(spacing: 6) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 28))
                .foregroundColor(heartRateColor(workoutManager.currentHeartRate))
                .scaleEffect(animateHeart ? 1.15 : 0.95)
                .animation(
                    .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                    value: animateHeart
                )

            Text("\(workoutManager.currentHeartRate)")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(heartRateColor(workoutManager.currentHeartRate))

            Text("BPM")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)

            // Zone indicator
            Text(heartRateZoneName(workoutManager.currentHeartRate))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(heartRateColor(workoutManager.currentHeartRate))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    heartRateColor(workoutManager.currentHeartRate)
                        .opacity(0.15)
                )
                .cornerRadius(12)

            Spacer()

            // Resting HR
            if let restingHR = workoutManager.restingHeartRate {
                HStack(spacing: 4) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                    Text("Resting: \(restingHR) BPM")
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .onAppear { animateHeart = true }
    }

    private func heartRateColor(_ bpm: Int) -> Color {
        switch bpm {
        case ..<100: return .success
        case 100..<120: return .accentSecondary
        case 120..<140: return .warning
        case 140..<160: return .orange
        default: return .error
        }
    }

    private func heartRateZoneName(_ bpm: Int) -> String {
        switch bpm {
        case ..<100: return "Rest"
        case 100..<114: return "Warm Up"
        case 114..<133: return "Fat Burn"
        case 133..<162: return "Cardio"
        default: return "Peak"
        }
    }
}
