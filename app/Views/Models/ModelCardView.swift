import SwiftUI

struct ModelCardView: View {
    let model: ModelConfig
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(model.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                Image(systemName: model.type.iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accent)
            }

            Group {
                if model.vendor == .custom, let name = model.customVendorName, !name.isEmpty {
                    Text(name)
                } else {
                    Text(model.vendor.localizedTitleKey)
                }
            }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)

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
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 0, x: 0, y: 0)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}
