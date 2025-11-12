import SwiftUI

struct Card: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var subtitle: String
    var accent: Color = AppTheme.accent
    var selected: Bool = false
}

struct CardView: View {
    var card: Card
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: card.title)
                .font(.system(size: 15, weight: .semibold))
            Text(verbatim: card.subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            HStack {
                Spacer()
                ZStack {
                    Circle().fill(Color.black.opacity(0.03))
                        .frame(width: 24, height: 24)
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(card.selected ? card.accent : AppTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 0, x: 0, y: 0)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}
