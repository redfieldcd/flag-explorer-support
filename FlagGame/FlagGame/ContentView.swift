import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var usageTimerManager: UsageTimerManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(storeManager)
                .environmentObject(usageTimerManager)
        }
        .onChange(of: usageTimerManager.hasExceededLimit) { _, exceeded in
            if exceeded && !storeManager.isUnlocked {
                showPaywall = true
            }
        }
        .onAppear {
            if usageTimerManager.hasExceededLimit && !storeManager.isUnlocked {
                showPaywall = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
        .environmentObject(StoreManager())
        .environmentObject(UsageTimerManager())
}
