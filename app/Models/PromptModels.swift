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

