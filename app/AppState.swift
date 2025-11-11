import SwiftUI

enum SidebarDestination: String, CaseIterable, Identifiable, Hashable {
    case prompts
    case models
    case settings

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .prompts: return "提示词"
        case .models: return "大模型"
        case .settings: return "设置"
        }
    }

    var symbol: String {
        switch self {
        case .prompts: return "text.badge.star" // text-like
        case .models: return "cpu"
        case .settings: return "gearshape"
        }
    }
}

final class AppState: ObservableObject {
    @Published var selection: SidebarDestination? = .models
    @Published var searchText: String = ""
    // 选中的提示词标签（按 id 存储避免循环依赖）
    @Published var selectedPromptTagIDs: Set<UUID> = []
    // 当前正在编辑的提示词
    @Published var editingPrompt: PromptTemplate? = nil
    // 当前正在编辑的模型配置
    @Published var editingModel: ModelConfig? = nil

    // 偏好设置
    @Published var language: AppLanguage
    @Published var appearance: AppAppearance

    // 大模型过滤
    @Published var modelFilter: ModelFilter = .init() { didSet { persistModelFilter() } }

    init() {
        // 从用户默认加载设置
        let langRaw = UserDefaults.standard.string(forKey: UserDefaultsKeys.language) ?? AppLanguage.zhHans.rawValue
        let appRaw = UserDefaults.standard.string(forKey: UserDefaultsKeys.appearance) ?? AppAppearance.system.rawValue
        self.language = AppLanguage(rawValue: langRaw) ?? .zhHans
        self.appearance = AppAppearance(rawValue: appRaw) ?? .system

        // 读取模型过滤器
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.modelsFilter),
           let decoded = try? JSONDecoder().decode(ModelFilter.self, from: data) {
            self.modelFilter = decoded
        }
    }

    func setLanguage(_ value: AppLanguage) {
        language = value
        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultsKeys.language)
    }

    func setAppearance(_ value: AppAppearance) {
        appearance = value
        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultsKeys.appearance)
    }

    func persistModelFilter() {
        if let data = try? JSONEncoder().encode(modelFilter) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.modelsFilter)
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case zhHans = "zh-Hans"
    case en = "en"
    var id: String { rawValue }
    var titleKey: LocalizedStringKey { self == .zhHans ? "中文" : "English" }
    var locale: Locale { Locale(identifier: rawValue) }
}

enum UserDefaultsKeys {
    static let language = "app.language"
    static let appearance = "app.appearance"
    static let modelsFilter = "models.filter"
}
