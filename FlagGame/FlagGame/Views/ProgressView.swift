import SwiftUI

struct ProgressDetailView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Overall stats
                    OverallStatsCard(
                        learned: viewModel.learnedCountries.count,
                        total: CountryData.allCountries.count,
                        percentage: viewModel.progressPercentage
                    )

                    // Per-continent breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("By Region")
                            .font(.system(size: 18, weight: .bold, design: .rounded))

                        ForEach(Continent.allCases.filter { $0 != .all }) { continent in
                            let countries = CountryData.countries(for: continent)
                            let learnedInRegion = countries.filter { viewModel.learnedCountries.contains($0.code) }.count

                            ContinentProgressRow(
                                continent: continent,
                                learned: learnedInRegion,
                                total: countries.count
                            )
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Quiz history
                    if !viewModel.quizHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Quizzes")
                                .font(.system(size: 18, weight: .bold, design: .rounded))

                            ForEach(viewModel.quizHistory) { record in
                                QuizHistoryRow(record: record)
                            }
                        }
                        .padding(20)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Reset button
                    Button {
                        showResetAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Progress")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .navigationTitle("My Progress")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This will clear all your learned flags and quiz history. Are you sure?")
        }
    }
}

// MARK: - Overall Stats Card
struct OverallStatsCard: View {
    let learned: Int
    let total: Int
    let percentage: Double

    var body: some View {
        VStack(spacing: 20) {
            // Big ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 14)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(percentage))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Complete")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            // Stats row
            HStack(spacing: 30) {
                StatItem(value: "\(learned)", label: "Learned", color: .blue)
                StatItem(value: "\(total - learned)", label: "Remaining", color: .orange)
                StatItem(value: "\(total)", label: "Total", color: .purple)
            }
        }
        .padding(24)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Continent Progress Row
struct ContinentProgressRow: View {
    let continent: Continent
    let learned: Int
    let total: Int

    private var percentage: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(learned) / CGFloat(total)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(continent.emoji)
                    .font(.system(size: 18))

                Text(continent.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Text("\(learned)/\(total)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Quiz History Row
struct QuizHistoryRow: View {
    let record: GameViewModel.QuizRecord

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: record.date)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Score badge
            ZStack {
                Circle()
                    .fill(record.score >= record.total / 2 ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text("\(record.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(record.score >= record.total / 2 ? .green : .orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.score)/\(record.total) correct")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Text("\(record.continent.rawValue) · \(dateString)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProgressDetailView()
    }
    .environmentObject(GameViewModel())
}
