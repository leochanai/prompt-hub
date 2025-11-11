import SwiftUI

@main
struct PromptHubApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var promptStore = PromptStore()
    @StateObject private var modelStore = ModelStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(promptStore)
                .environmentObject(modelStore)
                .environment(\.locale, appState.language.locale)
                .preferredColorScheme(appState.appearance.colorScheme)
                .id("lang:\(appState.language.rawValue)|theme:\(appState.appearance.rawValue)")
        }
    }
}
