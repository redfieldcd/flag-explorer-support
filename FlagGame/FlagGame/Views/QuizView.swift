import SwiftUI

struct QuizView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var usageTimerManager: UsageTimerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if viewModel.quizFinished {
                QuizResultView(
                    score: viewModel.quizScore,
                    total: viewModel.quizTotal,
                    onPlayAgain: { viewModel.startQuiz() },
                    onGoHome: { dismiss() }
                )
            } else if let country = viewModel.currentCountry {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Question \(viewModel.quizQuestionIndex + 1) of \(viewModel.quizTotal)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("\(viewModel.quizScore)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray4))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(.orange)
                                .frame(
                                    width: geo.size.width * CGFloat(viewModel.quizQuestionIndex) / CGFloat(max(1, viewModel.quizTotal)),
                                    height: 6
                                )
                                .animation(.spring(response: 0.3), value: viewModel.quizQuestionIndex)
                        }
                    }
                    .frame(height: 6)

                    // Question prompt
                    Text("Which country does this flag belong to?")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    // Flag
                    Text(country.flag)
                        .font(.system(size: 100))
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                        )

                    Spacer()

                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(viewModel.quizOptions) { option in
                            QuizOptionButton(
                                country: option,
                                isSelected: viewModel.selectedAnswer == option,
                                isCorrect: option == country,
                                showResult: viewModel.selectedAnswer != nil,
                                onSpeak: { viewModel.speechManager.speak(option.name) }
                            ) {
                                viewModel.selectQuizAnswer(option)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(20)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startQuiz()
            if !storeManager.isUnlocked {
                usageTimerManager.startTracking()
            }
        }
        .onDisappear {
            usageTimerManager.stopTracking()
        }
    }
}

struct QuizOptionButton: View {
    let country: Country
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let onSpeak: () -> Void
    let action: () -> Void

    private var backgroundColor: Color {
        guard showResult else {
            return .white
        }
        if isCorrect {
            return Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.15)
        }
        if isSelected && !isCorrect {
            return Color.red.opacity(0.15)
        }
        return .white.opacity(0.6)
    }

    private var borderColor: Color {
        guard showResult else {
            return Color(.systemGray4)
        }
        if isCorrect {
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        }
        if isSelected && !isCorrect {
            return .red
        }
        return Color(.systemGray4).opacity(0.5)
    }

    private var icon: String? {
        guard showResult else { return nil }
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected && !isCorrect { return "xmark.circle.fill" }
        return nil
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: action) {
                HStack(spacing: 12) {
                    Text(country.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Spacer()

                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(isCorrect ? .green : .red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 2)
                )
            }
            .disabled(showResult)

            Button(action: onSpeak) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .animation(.spring(response: 0.3), value: showResult)
    }
}

#Preview {
    NavigationStack {
        QuizView()
    }
    .environmentObject(GameViewModel())
    .environmentObject(StoreManager())
    .environmentObject(UsageTimerManager())
}
