import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var usageTimerManager: UsageTimerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.35, blue: 0.65), Color(red: 0.25, green: 0.55, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)

                    Text("🔓")
                        .font(.system(size: 70))

                    Text("Unlock Flag Explorer!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your free preview has ended.\nGet unlimited access to all flags,\nquizzes, and study modes!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Feature list
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "checkmark.circle.fill", text: "All 195+ country flags")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited study sessions")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited quizzes")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Track your progress forever")
                    }
                    .padding(20)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Spacer(minLength: 20)

                    // Purchase button
                    Button {
                        Task { await storeManager.purchase() }
                    } label: {
                        Group {
                            if storeManager.purchaseState == .purchasing {
                                ProgressView()
                                    .tint(.blue)
                                    .frame(height: 50)
                            } else {
                                VStack(spacing: 4) {
                                    Text("Unlock Full Access")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                    Text(storeManager.product?.displayPrice ?? "$3.99")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .opacity(0.8)
                                    Text("One-time purchase")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .opacity(0.6)
                                }
                            }
                        }
                        .foregroundStyle(Color(red: 0.15, green: 0.35, blue: 0.65))
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(storeManager.purchaseState == .purchasing)

                    // Restore button
                    Button {
                        Task { await storeManager.restorePurchase() }
                    } label: {
                        Text("Restore Purchase")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    // Status messages
                    if storeManager.purchaseState == .pending {
                        Text("Purchase is waiting for approval.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.yellow)
                            .padding(10)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if case .failed(let message) = storeManager.purchaseState {
                        Text(message)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.red)
                            .padding(10)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    #if DEBUG
                    Button {
                        storeManager.debugUnlock()
                    } label: {
                        Text("[DEBUG] Unlock for Free")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    #endif

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .onChange(of: storeManager.isUnlocked) { _, unlocked in
            if unlocked {
                usageTimerManager.resetIfPurchased()
                dismiss()
            }
        }
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.green)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager())
        .environmentObject(UsageTimerManager())
}
