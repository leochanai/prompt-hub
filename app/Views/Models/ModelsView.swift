import SwiftUI

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelStore: ModelStore
    @State private var showingEditor = false

    private let columns = [
        GridItem(.adaptive(minimum: 260), spacing: 14, alignment: .top)
    ]

    var filteredModels: [ModelConfig] {
        if appState.searchText.isEmpty {
            return modelStore.models
        } else {
            return modelStore.models.filter { model in
                model.name.localizedCaseInsensitiveContains(appState.searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ContentHeader(title: SidebarDestination.models.titleKey, subtitle: "创建并切换多个模型或供应商配置", searchText: $appState.searchText) {
                appState.editingModel = nil
                showingEditor = true
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filteredModels) { model in
                        ModelCardView(model: model) {
                            appState.editingModel = model
                            showingEditor = true
                        }
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
