import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var usageTimerManager: UsageTimerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.43, green: 0.74, blue: 0.91),
                    Color(red: 0.23, green: 0.43, blue: 0.56),
                    Color(red: 0.20, green: 0.36, blue: 0.56)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("🌍")
                    .font(.system(size: 80))

                Text("Unlock Flag Explorer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Your free trial has ended.\nUnlock full access to keep learning!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "All 195 countries")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited study & quiz")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Track your progress")
                    FeatureRow(icon: "checkmark.circle.fill", text: "No ads, ever")
                }
                .padding(.vertical, 16)

                Spacer()

                // Purchase button
                Button {
                    Task { await storeManager.purchase() }
                } label: {
                    HStack {
                        if case .purchasing = storeManager.purchaseState {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Text("Unlock Full Access — \(storeManager.product?.displayPrice ?? "$3.99")")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(storeManager.purchaseState == .purchasing)

                // Restore
                Button {
                    Task { await storeManager.restore() }
                } label: {
                    Text("Restore Purchase")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }

                if case .failed(let msg) = storeManager.purchaseState {
                    Text(msg)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.red)
                }

                #if DEBUG
                Button {
                    storeManager.debugUnlock()
                } label: {
                    Text("[DEBUG] Unlock for Free")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.yellow)
                }
                .padding(.top, 4)
                #endif

                Spacer()
            }
            .padding(24)
        }
        .interactiveDismissDisabled(true)
        .onChange(of: storeManager.isUnlocked) { _, unlocked in
            if unlocked { dismiss() }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.green)
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// Need to conform PurchaseState to Equatable for the .disabled check
extension StoreManager.PurchaseState: Equatable {
    static func == (lhs: StoreManager.PurchaseState, rhs: StoreManager.PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.purchasing, .purchasing), (.purchased, .purchased), (.pending, .pending):
            return true
        case (.failed(let a), .failed(let b)):
            return a == b
        default:
            return false
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager())
        .environmentObject(UsageTimerManager())
}
