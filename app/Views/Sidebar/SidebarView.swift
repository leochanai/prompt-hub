import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination?

    var body: some View {
        List(selection: $selection) {
            Section(footer: EmptyView()) {
                ForEach(SidebarDestination.allCases) { item in
                    Button {
                        selection = item
                    } label: {
                        SidebarRow(item: item, isSelected: selection == item)
                    }
                    .buttonStyle(.plain)
                    .tag(Optional(item))
                    .listRowInsets(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            // 底部留白模拟圆角与阴影空间
            Color.clear.frame(height: 8)
        }
        .background(AppTheme.sidebarBG)
        .overlay(Rectangle().fill(AppTheme.separator).frame(width: 1), alignment: .trailing)
    }
}

struct SidebarRow: View {
    let item: SidebarDestination
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.symbol)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 22)
            Text(item.titleKey)
                .font(.system(size: 14, weight: .semibold))
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .foregroundStyle(isSelected ? Color.white : .primary)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(isSelected ? AppTheme.accent : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(isSelected ? AppTheme.accentBorder : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}
