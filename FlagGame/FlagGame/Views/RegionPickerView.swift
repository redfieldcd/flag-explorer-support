import SwiftUI

struct RegionPickerView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a Region")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Continent.allCases) { continent in
                        RegionChip(
                            continent: continent,
                            isSelected: viewModel.selectedContinent == continent,
                            count: CountryData.countries(for: continent).count
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedContinent = continent
                                viewModel.studyIndex = 0
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RegionChip: View {
    let continent: Continent
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(continent.emoji)
                    .font(.system(size: 22))
                Text(continent.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                Text("\(count)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? .white.opacity(0.3) : .white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .white.opacity(0.5) : .clear, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        RegionPickerView()
            .padding()
    }
    .environmentObject(GameViewModel())
}
