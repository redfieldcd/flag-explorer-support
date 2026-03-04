import SwiftUI

struct QuizResultView: View {
    let score: Int
    let total: Int
    let onPlayAgain: () -> Void
    let onGoHome: () -> Void

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(score) / Double(total) * 100
    }

    private var emoji: String {
        switch percentage {
        case 90...100: return "🏆"
        case 70..<90: return "🌟"
        case 50..<70: return "👍"
        default: return "💪"
        }
    }

    private var message: String {
        switch percentage {
        case 90...100: return "Amazing! You're a flag expert!"
        case 70..<90: return "Great job! Keep learning!"
        case 50..<70: return "Good effort! Practice more!"
        default: return "Keep trying! You'll get better!"
        }
    }

    private var scoreColor: Color {
        switch percentage {
        case 90...100: return .yellow
        case 70..<90: return .green
        case 50..<70: return .blue
        default: return .orange
        }
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Big emoji
            Text(emoji)
                .font(.system(size: 80))

            // Score display
            VStack(spacing: 8) {
                Text("\(score) / \(total)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Score ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(percentage))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(action: onGoHome) {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                        Text("Back to Home")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    QuizResultView(
        score: 8,
        total: 10,
        onPlayAgain: {},
        onGoHome: {}
    )
}
