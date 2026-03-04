import SwiftUI
import Combine

@MainActor
class UsageTimerManager: ObservableObject {
    @Published private(set) var accumulatedSeconds: TimeInterval = 0
    @Published private(set) var hasExceededLimit: Bool = false

    static let limitSeconds: TimeInterval = 600 // 10 minutes

    private static let accumulatedKey = "cumulativeUsageSeconds"
    private static let sessionStartKey = "lastSessionStartDate"

    private var timer: Timer?
    private var sessionStartDate: Date?
    private var isTracking = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load persisted time
        accumulatedSeconds = UserDefaults.standard.double(forKey: Self.accumulatedKey)

        // Crash recovery: if there's a persisted session start, recover lost time
        if let savedStart = UserDefaults.standard.object(forKey: Self.sessionStartKey) as? Date {
            let elapsed = Date().timeIntervalSince(savedStart)
            if elapsed > 0 {
                accumulatedSeconds += elapsed
                persist()
            }
            UserDefaults.standard.removeObject(forKey: Self.sessionStartKey)
        }

        hasExceededLimit = accumulatedSeconds >= Self.limitSeconds
        observeAppLifecycle()
    }

    // MARK: - Tracking

    func startTracking() {
        guard !isTracking else { return }
        isTracking = true
        sessionStartDate = Date()
        UserDefaults.standard.set(sessionStartDate, forKey: Self.sessionStartKey)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stopTracking() {
        guard isTracking else { return }
        isTracking = false

        timer?.invalidate()
        timer = nil

        // Use precise elapsed time from session start
        if let start = sessionStartDate {
            let elapsed = Date().timeIntervalSince(start)
            // Replace the tick-based accumulated with precise value
            let preSessionTime = UserDefaults.standard.double(forKey: Self.accumulatedKey)
            // Only use precise if session was tracked (avoid double counting)
            let preciseTotal = preSessionTime + elapsed
            if preciseTotal > accumulatedSeconds {
                accumulatedSeconds = preciseTotal
            }
        }

        sessionStartDate = nil
        UserDefaults.standard.removeObject(forKey: Self.sessionStartKey)
        persist()
    }

    func resetIfPurchased() {
        hasExceededLimit = false
        // Keep accumulated time for stats, just clear the limit flag
    }

    // MARK: - Private

    private func tick() {
        accumulatedSeconds += 1
        persist()
        checkLimit()
    }

    private func checkLimit() {
        if accumulatedSeconds >= Self.limitSeconds && !hasExceededLimit {
            hasExceededLimit = true
        }
    }

    private func persist() {
        UserDefaults.standard.set(accumulatedSeconds, forKey: Self.accumulatedKey)
    }

    private func observeAppLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.stopTracking()
                }
            }
            .store(in: &cancellables)

    }

    var remainingSeconds: TimeInterval {
        max(0, Self.limitSeconds - accumulatedSeconds)
    }

    var remainingFormatted: String {
        let remaining = Int(remainingSeconds)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
