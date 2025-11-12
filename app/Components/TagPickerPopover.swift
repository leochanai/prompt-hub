import SwiftUI

struct TagPickerPopover: View {
  @EnvironmentObject private var store: PromptStore

  @Binding var selectedIDs: [UUID]
  @State private var query: String = ""
  @State private var colorIndex: Int = 0

  private let presetColors: [Color] = [
    .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple
  ]

  private var normalizedQuery: String {
    query.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var filtered: [PromptTag] {
    if normalizedQuery.isEmpty { return store.tags }
    let q = normalizedQuery.lowercased()
    return store.tags.filter { $0.name.lowercased().contains(q) }
  }

  private func existsTag(with name: String) -> PromptTag? {
    let q = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return store.tags.first { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == q }
  }

  private var creatableName: String? {
    guard !normalizedQuery.isEmpty else { return nil }
    if existsTag(with: normalizedQuery) != nil { return nil }
    return normalizedQuery
  }

  var body: some View {
    VStack(alignment: .leading, spacing: AppLayout.gridVSpacing) {
      // Search/input
      HStack(spacing: 8) {
        Image(systemName: "number")
          .foregroundStyle(.secondary)
        TextField("输入以搜索或新建标签", text: $query)
          .onSubmit { onSubmit() }
          .textFieldStyle(.plain)
      }
      .padding(10)
      .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .textBackgroundColor)))
      .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))

      // Results
      ScrollView {
        VStack(alignment: .leading, spacing: 6) {
          ForEach(filtered) { tag in
            Button {
              toggle(tag)
            } label: {
              HStack(spacing: 10) {
                Circle().fill(tag.color).frame(width: 10, height: 10)
                Text(verbatim: tag.name)
                Spacer()
                if selectedIDs.contains(tag.id) {
                  Image(systemName: "checkmark").foregroundStyle(AppTheme.accent)
                }
              }
              .padding(.vertical, 6).padding(.horizontal, 8)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .frame(maxHeight: 220)

      // Create row + color presets
      if let name = creatableName {
        Divider()
        Button(action: { createTag(named: name) }) {
          HStack(spacing: 6) {
            Text("创建标签")
            Text(verbatim: "\"\(name)\"").fontWeight(.semibold)
            Spacer()
          }
          .padding(.vertical, 6).padding(.horizontal, 4)
        }
        .buttonStyle(.plain)

        HStack(spacing: 8) {
          ForEach(Array(presetColors.enumerated()), id: \.offset) { item in
            let idx = item.offset
            let c = item.element
            Circle()
              .fill(c.opacity(0.95))
              .frame(width: AppLayout.colorSwatchSize, height: AppLayout.colorSwatchSize)
              .overlay(
                Circle().stroke(idx == colorIndex ? AppTheme.accentBorder : .clear, lineWidth: 2)
              )
              .onTapGesture { colorIndex = idx }
          }
        }
        .padding(.top, 2)
      }
    }
    .padding(AppLayout.contentPadding)
    .frame(width: 340)
  }

  private func onSubmit() {
    if let name = creatableName {
      createTag(named: name)
    } else if let hit = existsTag(with: normalizedQuery) {
      toggle(hit)
    }
  }

  private func toggle(_ tag: PromptTag) {
    if let i = selectedIDs.firstIndex(of: tag.id) { selectedIDs.remove(at: i) }
    else { selectedIDs.append(tag.id) }
    query = ""
  }

  private func createTag(named name: String) {
    let color = presetColors[colorIndex % presetColors.count]
    let new = PromptTag(name: name, color: color)
    store.tags.append(new)
    selectedIDs.append(new.id)
    query = ""
  }
}
