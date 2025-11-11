import SwiftUI

struct PromptsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: PromptStore

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 14, alignment: .top)]

    private var filtered: [PromptTemplate] {
        let text = appState.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let selectedTags = appState.selectedPromptTagIDs

        return store.prompts.filter { p in
            let textMatch: Bool
            if text.isEmpty { textMatch = true }
            else {
                textMatch = p.title.lowercased().contains(text) ||
                            p.summary.lowercased().contains(text) ||
                            p.content.lowercased().contains(text)
            }

            let tagMatch: Bool
            if selectedTags.isEmpty { tagMatch = true }
            else { tagMatch = selectedTags.isSubset(of: Set(p.tags)) }

            return textMatch && tagMatch
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
                        CardView(card: Card(title: prompt.title, subtitle: prompt.summary)) {
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
            .frame(minWidth: 560, minHeight: 460)
        }
    }

    private func createNew() {
        let new = PromptTemplate(title: "未命名提示词", summary: "", content: "", tags: [])
        appState.editingPrompt = new
    }
}
