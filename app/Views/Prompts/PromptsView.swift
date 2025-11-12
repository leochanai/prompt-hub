import SwiftUI

struct PromptsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: PromptStore
    @EnvironmentObject private var modelStore: ModelStore

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 14, alignment: .top)]

    private var filtered: [PromptTemplate] {
        let text = appState.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let selectedTags = appState.selectedPromptTagIDs
        let typeSel = appState.promptsSelectedType

        return store.prompts.filter { p in
            // search
            let textMatch: Bool
            if text.isEmpty { textMatch = true }
            else {
                textMatch = p.title.lowercased().contains(text) ||
                            p.content.lowercased().contains(text)
            }

            // tags (AND)
            let tagMatch: Bool
            if selectedTags.isEmpty { tagMatch = true }
            else { tagMatch = selectedTags.isSubset(of: Set(p.tags)) }

            // model type（仅当提示词选择了具体模型时才参与类型过滤）
            let typeMatch: Bool
            if let ts = typeSel {
                if let mid = p.modelId, let model = modelStore.models.first(where: { $0.id == mid }) {
                    typeMatch = model.type == ts
                } else {
                    // 未选择模型的提示词在特定类型筛选下不显示
                    typeMatch = false
                }
            } else {
                // 选择“全部”时不过滤
                typeMatch = true
            }

            return textMatch && tagMatch && typeMatch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            PromptsFilterBar(filteredCount: filtered.count) {
                createNew()
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filtered) { prompt in
                        CardView(card: Card(title: prompt.title, subtitle: subtitle(for: prompt))) {
                            appState.editingPrompt = prompt
                        }
                        .contextMenu {
                            Button("编辑") { appState.editingPrompt = prompt }
                            Button(role: .destructive) { store.remove(prompt.id) } label: { Text("删除") }
                        }
                    }
                    if filtered.isEmpty {
                        VStack(spacing: 8) {
                            Text("无匹配结果" as LocalizedStringKey)
                                .foregroundColor(.secondary)
                            if !appState.selectedPromptTagIDs.isEmpty {
                                Button("清除过滤" as LocalizedStringKey) {
                                    appState.selectedPromptTagIDs.removeAll()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .sheet(item: $appState.editingPrompt) { item in
            PromptEditorSheet(prompt: item) { updated, delete in
                if delete { store.remove(item.id) }
                else { store.upsert(updated) }
            }
            .frame(minWidth: 920, minHeight: 680)
        }
    }

    private func createNew() {
        let new = PromptTemplate(title: "未命名提示词", content: "", tags: [])
        appState.editingPrompt = new
    }

    private func subtitle(for p: PromptTemplate) -> String {
        let firstLine = p.content.split(whereSeparator: { $0.isNewline }).first
        return firstLine.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""
    }
}
