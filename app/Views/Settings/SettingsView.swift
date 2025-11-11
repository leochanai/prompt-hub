import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            ContentHeader(title: SidebarDestination.settings.titleKey, subtitle: "应用偏好与数据管理", showsAdd: false, searchText: $appState.searchText) {}

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    SettingRow(label: "语言") {
                        Picker("", selection: Binding(get: { appState.language }, set: { appState.setLanguage($0) })) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.titleKey).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 220)
                    }

                    SettingRow(label: "主题") {
                        Picker("", selection: Binding(get: { appState.appearance }, set: { appState.setAppearance($0) })) {
                            ForEach(AppAppearance.allCases) { ap in
                                Text(ap.titleKey).tag(ap)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 220)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("软件版本").font(.system(size: 13, weight: .semibold))
                        Text(AppVersion.currentLine).foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 560, alignment: .leading)
                Spacer()
            }
            .padding(16)
        }
    }
}

// 通用设置行：左侧固定宽度标签 + 右侧控件
private struct SettingRow<Content: View>: View {
    let label: LocalizedStringKey
    @ViewBuilder let content: () -> Content
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 48, alignment: .leading)
            content()
            Spacer(minLength: 0)
        }
    }
}

private enum AppVersion {
    static var currentLine: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return "v\(v) 已是最新版本"
    }
}

extension AppAppearance {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
