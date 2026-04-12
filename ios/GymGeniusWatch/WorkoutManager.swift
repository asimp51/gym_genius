import Foundation
import HealthKit
import Combine

/// Manages HealthKit workout sessions on Apple Watch.
/// Handles heart rate monitoring, workout start/stop, and data collection.
class WorkoutManager: NSObject, ObservableObject {

    // MARK: - Published State

    @Published var currentHeartRate: Int = 72
    @Published var averageHeartRate: Int = 0
    @Published var restingHeartRate: Int? = nil
    @Published var activeCalories: Double = 0
    @Published var elapsedSeconds: Int = 0
    @Published var isWorkoutActive: Bool = false

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var heartRateSamples: [Int] = []
    private var timer: Timer?

    // MARK: - HealthKit Types

    private let heartRateType = HKQuantityType.quantityType(
        forIdentifier: .heartRate
    )!
    private let activeEnergyType = HKQuantityType.quantityType(
        forIdentifier: .activeEnergyBurned
    )!
    private let restingHeartRateType = HKQuantityType.quantityType(
        forIdentifier: .restingHeartRate
    )!

    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.workoutType(),
    ]

    private let typesToWrite: Set<HKSampleType> = [
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.workoutType(),
    ]

    // MARK: - Initialization

    override init() {
        super.init()
        requestAuthorization()
        fetchRestingHeartRate()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Workout Session Management

    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()

            workoutSession?.delegate = self
            workoutBuilder?.delegate = self

            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            workoutBuilder?.beginCollection(withStart: startDate) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isWorkoutActive = true
                        self.heartRateSamples = []
                        self.elapsedSeconds = 0
                        self.activeCalories = 0
                        self.startTimer()
                    }
                }
            }
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }

    func endWorkout() {
        guard isWorkoutActive else { return }

        workoutSession?.end()
        stopTimer()

        DispatchQueue.main.async {
            self.isWorkoutActive = false
            self.calculateAverageHeartRate()
        }
    }

    func pauseWorkout() {
        workoutSession?.pause()
    }

    func resumeWorkout() {
        workoutSession?.resume()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Heart Rate

    private func fetchRestingHeartRate() {
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        let query = HKSampleQuery(
            sampleType: restingHeartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(
                for: HKUnit.count().unitDivided(by: .minute())
            )
            DispatchQueue.main.async {
                self?.restingHeartRate = Int(bpm)
            }
        }
        healthStore.execute(query)
    }

    private func updateHeartRate(_ value: Double) {
        let bpm = Int(value)
        DispatchQueue.main.async {
            self.currentHeartRate = bpm
            self.heartRateSamples.append(bpm)
        }
    }

    private func calculateAverageHeartRate() {
        guard !heartRateSamples.isEmpty else {
            averageHeartRate = 0
            return
        }
        let sum = heartRateSamples.reduce(0, +)
        averageHeartRate = sum / heartRateSamples.count
    }

    // MARK: - Data Collection

    private func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        switch statistics.quantityType {
        case heartRateType:
            if let value = statistics.mostRecentQuantity()?.doubleValue(
                for: HKUnit.count().unitDivided(by: .minute())
            ) {
                updateHeartRate(value)
            }

        case activeEnergyType:
            if let value = statistics.sumQuantity()?.doubleValue(
                for: .kilocalorie()
            ) {
                DispatchQueue.main.async {
                    self.activeCalories = value
                }
            }

        default:
            break
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        if toState == .ended {
            workoutBuilder?.endCollection(withEnd: date) { success, error in
                if success {
                    self.workoutBuilder?.finishWorkout { workout, error in
                        // Workout saved to HealthKit.
                    }
                }
            }
        }
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events (e.g., pause/resume markers).
    }

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
    }
}
