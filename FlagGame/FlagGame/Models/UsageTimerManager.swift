import Foundation
import UIKit
import Combine

@MainActor
class UsageTimerManager: ObservableObject {
    @Published var cumulativeSeconds: Double = 0
    @Published var hasExceededLimit: Bool = false

    let limitSeconds: Double = 600 // 10 minutes

    private var timer: Timer?
    private let cumulativeKey = "cumulativeUsageSeconds"
    private let sessionStartKey = "sessionStartDate"

    var remainingFormatted: String {
        let remaining = max(0, limitSeconds - cumulativeSeconds)
        let mins = Int(remaining) / 60
        let secs = Int(remaining) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    init() {
        cumulativeSeconds = UserDefaults.standard.double(forKey: cumulativeKey)
        hasExceededLimit = cumulativeSeconds >= limitSeconds

        // Crash recovery: if there's a persisted session start, account for elapsed time
        if let startDate = UserDefaults.standard.object(forKey: sessionStartKey) as? Date {
            let elapsed = Date().timeIntervalSince(startDate)
            if elapsed > 0 && elapsed < 3600 { // sanity: max 1 hour
                cumulativeSeconds += elapsed
                persist()
            }
            UserDefaults.standard.removeObject(forKey: sessionStartKey)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    func startTracking() {
        guard timer == nil else { return }
        UserDefaults.standard.set(Date(), forKey: sessionStartKey)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
        UserDefaults.standard.removeObject(forKey: sessionStartKey)
        persist()
    }

    private func tick() {
        cumulativeSeconds += 1
        persist()
        if cumulativeSeconds >= limitSeconds {
            hasExceededLimit = true
            stopTracking()
        }
    }

    private func persist() {
        UserDefaults.standard.set(cumulativeSeconds, forKey: cumulativeKey)
    }

    @objc private func appWillResignActive() {
        stopTracking()
    }
}
