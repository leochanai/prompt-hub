import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $appState.selection)
                .frame(minWidth: 220)
                .navigationSplitViewColumnWidth(240)
        } detail: {
            Group {
                switch appState.selection ?? .models {
                case .prompts:
                    PromptsView()
                case .models:
                    ModelsView()
                case .settings:
                    SettingsView()
                }
            }
            .background(AppTheme.background)
        }
        .tint(AppTheme.accent)
        .environment(\.locale, appState.language.locale)
        .preferredColorScheme(appState.appearance.colorScheme)
        .id("lang:\(appState.language.rawValue)|theme:\(appState.appearance.rawValue)")
    }
}
