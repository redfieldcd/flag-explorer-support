import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.35, blue: 0.65), Color(red: 0.25, green: 0.55, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🌍")
                            .font(.system(size: 60))

                        Text("Flag Explorer")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Learn flags from around the world!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // Progress summary
                    ProgressSummaryCard(
                        learned: viewModel.learnedCountries.count,
                        total: CountryData.allCountries.count,
                        percentage: viewModel.progressPercentage
                    )

                    // Region picker
                    RegionPickerView()

                    // Main action buttons
                    VStack(spacing: 16) {
                        NavigationLink {
                            StudyView()
                        } label: {
                            ActionCard(
                                icon: "📚",
                                title: "Study Mode",
                                subtitle: "Learn flags with flashcards",
                                color: Color(red: 0.2, green: 0.7, blue: 0.4)
                            )
                        }

                        NavigationLink {
                            QuizView()
                        } label: {
                            ActionCard(
                                icon: "🧠",
                                title: "Quiz Mode",
                                subtitle: "Test your knowledge!",
                                color: Color(red: 0.9, green: 0.5, blue: 0.2)
                            )
                        }

                        NavigationLink {
                            ProgressDetailView()
                        } label: {
                            ActionCard(
                                icon: "📊",
                                title: "My Progress",
                                subtitle: "See how much you've learned",
                                color: Color(red: 0.6, green: 0.4, blue: 0.8)
                            )
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Progress Summary Card
struct ProgressSummaryCard: View {
    let learned: Int
    let total: Int
    let percentage: Double

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))

                    Text("\(learned) / \(total) flags")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 6)
                        .frame(width: 56, height: 56)

                    Circle()
                        .trim(from: 0, to: percentage / 100)
                        .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(percentage))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Action Card
struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(color.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(GameViewModel())
}
