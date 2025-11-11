import SwiftUI

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var cards: [Card] = [
        .init(title: "Claude", subtitle: "Claude Code 默认配置", selected: false),
        .init(title: "Doubao-Seed-Code", subtitle: "https://ark.cn-beijing.volces.com/api/...", selected: false),
        .init(title: "Kimi For Coding", subtitle: "https://api.kimi.com/coding/", selected: true)
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 260), spacing: 14, alignment: .top)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ContentHeader(title: SidebarDestination.models.titleKey, subtitle: "创建并切换多个模型或供应商配置", searchText: $appState.searchText) {
                // add action placeholder
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(cards) { card in
                        CardView(card: card)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}
