import SwiftUI

struct PromptsFilterBar: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: PromptStore

    var filteredCount: Int
    var onAdd: () -> Void

    private var selectedCount: Int { appState.selectedPromptTagIDs.count }

    private var tagsTitle: Text {
        let base = Text("标签" as LocalizedStringKey)
        if selectedCount > 0 { return base + Text(" · \(selectedCount)") }
        return base
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: Model type segmented
            Picker("", selection: $appState.promptsSelectedType) {
                Text("全部" as LocalizedStringKey).tag(ModelType?.none)
                ForEach(ModelType.allCases, id: \.self) { type in
                    Label { Text(type.titleKey) } icon: { Image(systemName: type.iconName) }
                        .tag(ModelType?.some(type))
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 420, alignment: .leading)

            // Tag filter menu
            Menu {
                ForEach(store.tags) { tag in
                    Toggle(isOn: binding(for: tag)) {
                        HStack(spacing: 8) {
                            Circle().fill(tag.color).frame(width: 8, height: 8)
                            Text(tag.name)
                        }
                    }
                }
                Divider()
                Toggle(isOn: bindingAllTags) {
                    Text("全部" as LocalizedStringKey)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "tag")
                    tagsTitle
                }
            }

            Spacer()

            // Search
            TextField("搜索", text: $appState.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 260)

            // Count
            (Text("提示词" as LocalizedStringKey) + Text(" · \(filteredCount)"))
                .foregroundColor(.secondary)

            // Clear
            if !appState.selectedPromptTagIDs.isEmpty {
                Button("清除过滤" as LocalizedStringKey) {
                    appState.selectedPromptTagIDs.removeAll()
                }
                .buttonStyle(.bordered)
            }

            // Add
            Button { onAdd() } label: {
                Label("新建提示词", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(AppTheme.background)
        .overlay(Rectangle().fill(AppTheme.separator).frame(height: 1), alignment: .bottom)
    }

    private func binding(for tag: PromptTag) -> Binding<Bool> {
        Binding<Bool>(
            get: { appState.selectedPromptTagIDs.contains(tag.id) },
            set: { newValue in
                if newValue { appState.selectedPromptTagIDs.insert(tag.id) }
                else { appState.selectedPromptTagIDs.remove(tag.id) }
                // 若全选了所有标签，折叠为“全部”（清空集合）
                if appState.selectedPromptTagIDs.count == store.tags.count {
                    appState.selectedPromptTagIDs.removeAll()
                }
            }
        )
    }

    private var bindingAllTags: Binding<Bool> {
        Binding<Bool>(
            get: { appState.selectedPromptTagIDs.isEmpty },
            set: { newValue in
                if newValue { appState.selectedPromptTagIDs.removeAll() }
                else { /* 通过选择具体标签来关闭“全部” */ }
            }
        )
    }
}
