import SwiftUI

struct TagTokenChip: View {
  var tag: PromptTag
  var onRemove: (() -> Void)?

  var body: some View {
    HStack(spacing: 6) {
      Circle().fill(tag.color.opacity(0.9)).frame(width: 8, height: 8)
      Text(tag.name).font(.system(size: 12, weight: .semibold))
      if let onRemove {
        Button(action: onRemove) {
          Image(systemName: "xmark").font(.system(size: 9, weight: .bold))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .padding(.leading, 2)
      }
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 10)
    .background(
      Capsule(style: .continuous)
        .fill(Color(nsColor: .textBackgroundColor))
    )
    .overlay(
      Capsule(style: .continuous)
        .stroke(AppTheme.cardBorder, lineWidth: 1)
    )
  }
}

