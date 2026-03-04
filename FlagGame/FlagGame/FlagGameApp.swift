import SwiftUI

@main
struct FlagGameApp: App {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var storeManager = StoreManager()
    @StateObject private var usageTimerManager = UsageTimerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(storeManager)
                .environmentObject(usageTimerManager)
        }
    }
}
