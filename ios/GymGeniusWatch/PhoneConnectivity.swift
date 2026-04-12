import Foundation
import WatchConnectivity

/// Manages communication between the Apple Watch and the paired iPhone
/// using the WatchConnectivity framework.
///
/// Handles bidirectional data transfer:
/// - Phone -> Watch: workout state, templates, rest timer
/// - Watch -> Phone: set completion, heart rate updates
class PhoneConnectivity: NSObject, ObservableObject {

    // MARK: - Published State

    @Published var isPhoneReachable: Bool = false
    @Published var receivedWorkoutState: WorkoutStateMessage? = nil
    @Published var syncedTemplates: [TemplateMessage] = []

    // MARK: - Private Properties

    private var session: WCSession?

    // MARK: - Initialization

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Send to Phone

    /// Notify the phone that a set was completed on the watch.
    func sendSetCompleted(exerciseName: String, setNumber: Int) {
        sendMessage([
            "type": "set_completed",
            "data": [
                "exerciseName": exerciseName,
                "setNumber": setNumber,
                "timestamp": Date().timeIntervalSince1970,
            ] as [String: Any],
        ])
    }

    /// Send the current heart rate reading to the phone.
    func sendHeartRateUpdate(bpm: Int) {
        sendMessage([
            "type": "heart_rate_update",
            "data": [
                "bpm": bpm,
                "timestamp": Date().timeIntervalSince1970,
            ] as [String: Any],
        ])
    }

    /// Notify the phone that a workout was started from the watch.
    func sendWorkoutStartedFromWatch(templateId: String, templateName: String) {
        sendMessage([
            "type": "workout_started_from_watch",
            "data": [
                "templateId": templateId,
                "templateName": templateName,
                "timestamp": Date().timeIntervalSince1970,
            ] as [String: Any],
        ])
    }

    // MARK: - Private Helpers

    private func sendMessage(_ message: [String: Any]) {
        guard let session = session, session.isReachable else { return }

        session.sendMessage(message, replyHandler: nil) { error in
            print("WCSession send error: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Messages from Phone

    private func handlePhoneMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "workout_state":
            if let data = message["data"] as? [String: Any] {
                DispatchQueue.main.async {
                    self.receivedWorkoutState = WorkoutStateMessage(
                        workoutName: data["workoutName"] as? String ?? "",
                        currentExercise: data["currentExercise"] as? String ?? "",
                        currentSet: data["currentSet"] as? Int ?? 0,
                        totalSets: data["totalSets"] as? Int ?? 0,
                        elapsedSeconds: data["elapsedSeconds"] as? Int ?? 0,
                        isResting: data["isResting"] as? Bool ?? false,
                        restSecondsRemaining: data["restSecondsRemaining"] as? Int ?? 0
                    )
                }
            }

        case "sync_templates":
            if let data = message["data"] as? [String: Any],
               let templatesArray = data["templates"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    self.syncedTemplates = templatesArray.map { dict in
                        TemplateMessage(
                            id: dict["id"] as? String ?? "",
                            name: dict["name"] as? String ?? "",
                            description: dict["description"] as? String ?? ""
                        )
                    }
                }
            }

        case "rest_timer_start":
            if let data = message["data"] as? [String: Any] {
                let duration = data["duration"] as? Int ?? 90
                DispatchQueue.main.async {
                    self.receivedWorkoutState = self.receivedWorkoutState.map {
                        var updated = $0
                        updated.isResting = true
                        updated.restSecondsRemaining = duration
                        return updated
                    }
                }
                // Trigger haptic for rest timer start.
                WKInterfaceDevice.current().play(.start)
            }

        case "workout_complete":
            DispatchQueue.main.async {
                self.receivedWorkoutState = nil
            }
            WKInterfaceDevice.current().play(.success)

        default:
            break
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneConnectivity: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        handlePhoneMessage(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        handlePhoneMessage(message)
        replyHandler(["status": "received"])
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        handlePhoneMessage(applicationContext)
    }
}

// MARK: - Message Models

struct WorkoutStateMessage {
    var workoutName: String
    var currentExercise: String
    var currentSet: Int
    var totalSets: Int
    var elapsedSeconds: Int
    var isResting: Bool
    var restSecondsRemaining: Int
}

struct TemplateMessage: Identifiable {
    let id: String
    let name: String
    let description: String
}
