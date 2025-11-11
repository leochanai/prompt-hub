import SwiftUI

struct TagChipsBar: View {
    @EnvironmentObject private var store: PromptStore
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagChip(label: Text("全部"), color: .secondary, selected: appState.selectedPromptTagIDs.isEmpty) {
                    appState.selectedPromptTagIDs.removeAll()
                }

                ForEach(store.tags) { tag in
                    TagChip(label: Text(tag.name), color: tag.color, selected: appState.selectedPromptTagIDs.contains(tag.id)) {
                        if appState.selectedPromptTagIDs.contains(tag.id) {
                            appState.selectedPromptTagIDs.remove(tag.id)
                        } else {
                            appState.selectedPromptTagIDs.insert(tag.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(AppTheme.background)
        .overlay(Rectangle().fill(AppTheme.separator).frame(height: 1), alignment: .bottom)
    }
}

private struct TagChip: View {
    let label: Text
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle().fill(color.opacity(0.9)).frame(width: 8, height: 8)
                label.font(.system(size: 12, weight: .semibold))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(selected ? color.opacity(0.15) : Color(nsColor: .textBackgroundColor))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(selected ? color.opacity(0.6) : AppTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
