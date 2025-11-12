import SwiftUI

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelStore: ModelStore
    @State private var showingEditor = false

    private let columns = [
        GridItem(.adaptive(minimum: 260), spacing: 14, alignment: .top)
    ]

    var filteredModels: [ModelConfig] {
        let text = appState.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filter = appState.modelFilter
        return modelStore.models.filter { m in
            let textMatch = text.isEmpty || m.name.localizedCaseInsensitiveContains(text)
            let typeMatch = filter.selectedTypes.isEmpty || filter.selectedTypes.contains(m.type)
            let vendorMatch: Bool = {
                // When no vendor filters applied at all, pass
                if filter.selectedVendors.isEmpty && filter.selectedCustomVendorNames.isEmpty { return true }
                if m.vendor == .custom {
                    let name = (m.customVendorName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    return !name.isEmpty && filter.selectedCustomVendorNames.contains(name)
                } else {
                    return filter.selectedVendors.contains(m.vendor)
                }
            }()
            return textMatch && typeMatch && vendorMatch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ModelsFilterBar(filteredCount: filteredModels.count, onAdd: {
                appState.editingModel = nil
                showingEditor = true
            })

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filteredModels) { model in
                        ModelCardView(model: model) {
                            appState.editingModel = model
                            showingEditor = true
                        }
                    }
                    if filteredModels.isEmpty {
                        VStack(spacing: 8) {
                            Text("无匹配结果" as LocalizedStringKey)
                                .foregroundStyle(.secondary)
                            if !appState.modelFilter.isEmpty {
                                Button("清除过滤" as LocalizedStringKey) {
                                    appState.modelFilter = .init()
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
        .sheet(isPresented: $showingEditor) {
            ModelEditorSheet()
        }
    }
}
