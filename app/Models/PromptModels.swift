import SwiftUI

struct PromptTag: Identifiable, Hashable {
    let id: UUID
    var name: String
    var color: Color

    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

struct PromptTemplate: Identifiable, Hashable {
    let id: UUID
    var title: String
    var summary: String
    var content: String
    var tags: [UUID] // tag ids
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, summary: String, content: String, tags: [UUID], updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.summary = summary
        self.content = content
        self.tags = tags
        self.updatedAt = updatedAt
    }
}

enum ModelType: String, CaseIterable, Codable {
    case chat    = "chat"
    case code    = "code"
    case image   = "image"
    case video   = "video"
    case voice   = "voice"

    var titleKey: LocalizedStringKey {
        switch self {
        case .chat:  return "模型类型.对话"
        case .code:  return "模型类型.编码"
        case .image: return "模型类型.生图"
        case .video: return "模型类型.视频"
        case .voice: return "模型类型.语音"
        }
    }

    var iconName: String {
        switch self {
        case .chat:  return "bubble.left.and.bubble.right"
        case .code:  return "chevron.left.forwardslash.chevron.right"
        case .image: return "photo"
        case .video: return "video"
        case .voice: return "waveform"
        }
    }
}

enum ModelVendor: String, CaseIterable, Codable {
    case openAI      = "OpenAI"
    case anthropic   = "Anthropic"
    case google      = "Google"
    case moonshot    = "Moonshot"
    case volcengine  = "Volcengine"
    case alibaba     = "Alibaba"
    case baidu       = "Baidu"
    case tencent     = "Tencent"

    var displayName: String {
        switch self {
        case .openAI:     return "OpenAI"
        case .anthropic:  return "Anthropic (Claude)"
        case .google:     return "Google (Gemini)"
        case .moonshot:   return "Moonshot (Kimi)"
        case .volcengine: return "Volcengine (豆包)"
        case .alibaba:    return "Alibaba (通义)"
        case .baidu:      return "Baidu (文心)"
        case .tencent:    return "Tencent (混元)"
        }
    }

    var localizedTitleKey: LocalizedStringKey {
        switch self {
        case .openAI:     return "供应商.OpenAI"
        case .anthropic:  return "供应商.Anthropic"
        case .google:     return "供应商.Google"
        case .moonshot:   return "供应商.Moonshot"
        case .volcengine: return "供应商.Volcengine"
        case .alibaba:    return "供应商.Alibaba"
        case .baidu:      return "供应商.Baidu"
        case .tencent:    return "供应商.Tencent"
        }
    }
}

struct ModelConfig: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: ModelType
    var vendor: ModelVendor
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, type: ModelType, vendor: ModelVendor, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.type = type
        self.vendor = vendor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

final class ModelStore: ObservableObject {
    @Published var models: [ModelConfig] = []

    private let userDefaultsKey = "app.models"

    init() {
        loadModels()
        if models.isEmpty {
            seedSampleModels()
        }
    }

    func upsert(_ model: ModelConfig) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            var updatedModel = model
            updatedModel.updatedAt = .now
            models[index] = updatedModel
        } else {
            models.insert(model, at: 0)
        }
        saveModels()
    }

    func remove(_ id: UUID) {
        models.removeAll { $0.id == id }
        saveModels()
    }

    func modelExists(withName name: String, excludingId: UUID? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return models.contains { model in
            model.name.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(trimmedName) == .orderedSame
            && model.id != excludingId
        }
    }

    private func saveModels() {
        if let encoded = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadModels() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([ModelConfig].self, from: data) else {
            models = []
            return
        }
        models = decoded
    }

    private func seedSampleModels() {
        let sampleModels = [
            ModelConfig(name: "Claude", type: .chat, vendor: .anthropic),
            ModelConfig(name: "Doubao-Seed-Code", type: .chat, vendor: .volcengine),
            ModelConfig(name: "Kimi For Coding", type: .chat, vendor: .moonshot)
        ]
        models = sampleModels
        saveModels()
    }
}

final class PromptStore: ObservableObject {
    @Published var tags: [PromptTag] = []
    @Published var prompts: [PromptTemplate] = []

    init() { loadSample() }

    func tag(by id: UUID) -> PromptTag? { tags.first { $0.id == id } }
    func tags(for ids: [UUID]) -> [PromptTag] { ids.compactMap { tag(by: $0) } }

    func upsert(_ item: PromptTemplate) {
        if let idx = prompts.firstIndex(where: { $0.id == item.id }) {
            prompts[idx] = item
        } else {
            prompts.insert(item, at: 0)
        }
    }

    func remove(_ id: UUID) { prompts.removeAll { $0.id == id } }

    private func loadSample() {
        // sample tags
        let tSys = PromptTag(name: "系统", color: .blue)
        let tCode = PromptTag(name: "代码", color: .purple)
        let tProd = PromptTag(name: "产品", color: .green)
        let tMkt = PromptTag(name: "营销", color: .orange)
        tags = [tSys, tCode, tProd, tMkt]

        // sample prompts
        prompts = [
            PromptTemplate(title: "系统提示词", summary: "通用系统 / 安全边界", content: "你是一个…", tags: [tSys.id]),
            PromptTemplate(title: "代码评审", summary: "PR 审阅要点与风格", content: "请审阅以下代码…", tags: [tCode.id]),
            PromptTemplate(title: "产品需求澄清", summary: "澄清需求与验收标准", content: "请根据以下需求…", tags: [tProd.id]),
            PromptTemplate(title: "营销文案", summary: "邮件/社媒/落地页", content: "请撰写…", tags: [tMkt.id])
        ]
    }
}
