import SwiftUI

struct ContentHeader: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var showsAdd: Bool = true
    @Binding var searchText: String
    var addAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()

            TextField("搜索", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 260)

            if showsAdd {
                Button {
                    addAction?()
                } label: {
                    Label("新建配置", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.accent)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(AppTheme.background)
        .overlay(Rectangle().fill(AppTheme.separator).frame(height: 1), alignment: .bottom)
    }

    // no-op helper removed
}
