import SwiftUI

struct FlagCardView: View {
    let country: Country
    let showDetails: Bool
    let onSpeak: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Flag display
            Text(country.flag)
                .font(.system(size: 120))
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 4)

            if showDetails {
                // Answer section
                VStack(spacing: 16) {
                    // Country name with speak button
                    HStack(spacing: 12) {
                        Text(country.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Button(action: onSpeak) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.blue)
                                .frame(width: 44, height: 44)
                                .background(.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }

                    // Details grid
                    VStack(spacing: 12) {
                        DetailRow(icon: "building.columns.fill", label: "Capital", value: country.capital)
                        DetailRow(icon: "globe", label: "Region", value: country.continent.rawValue)
                        DetailRow(icon: "star.fill", label: "Fun Fact", value: country.funFact)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 20)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

#Preview {
    FlagCardView(
        country: CountryData.allCountries[0],
        showDetails: true,
        onSpeak: {}
    )
    .padding()
}
