import SwiftUI

struct StudyView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var usageTimerManager: UsageTimerManager
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header info
                if !viewModel.studyCountries.isEmpty {
                    HStack {
                        Text("\(viewModel.studyIndex + 1) of \(viewModel.studyCountries.count)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(viewModel.selectedContinent.emoji + " " + viewModel.selectedContinent.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray4))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(.blue)
                                .frame(
                                    width: viewModel.studyCountries.isEmpty ? 0 :
                                        geo.size.width * CGFloat(viewModel.studyIndex + 1) / CGFloat(viewModel.studyCountries.count),
                                    height: 6
                                )
                        }
                    }
                    .frame(height: 6)
                }

                Spacer()

                // Flag card
                if let country = viewModel.currentStudyCountry {
                    FlagCardView(
                        country: country,
                        showDetails: viewModel.showAnswer,
                        onSpeak: { viewModel.speechManager.speak(country.name) }
                    )
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width * 0.5
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.3)) {
                                    if value.translation.width > 80 {
                                        viewModel.previousStudyCard()
                                    } else if value.translation.width < -80 {
                                        viewModel.nextStudyCard()
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
                } else {
                    Text("No countries in this region")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    if !viewModel.showAnswer {
                        // Show Answer button
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                viewModel.revealAnswer()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "eye.fill")
                                Text("Show Answer")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        // Navigation buttons
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.previousStudyCard()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }

                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.nextStudyCard()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Study Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startStudy()
            if !storeManager.isUnlocked {
                usageTimerManager.startTracking()
            }
        }
        .onDisappear {
            usageTimerManager.stopTracking()
        }
    }
}

#Preview {
    NavigationStack {
        StudyView()
    }
    .environmentObject(GameViewModel())
    .environmentObject(StoreManager())
    .environmentObject(UsageTimerManager())
}
