import SwiftUI

struct TagAddCallout: View {
  var titleKey: LocalizedStringKey = "添加标签"
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        Image(systemName: "plus")
        Text(titleKey)
        Spacer(minLength: 0)
      }
      .padding(.vertical, 10)
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity)
      .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .textBackgroundColor).opacity(0.9)))
      .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder))
    }
    .buttonStyle(.plain)
  }
}

