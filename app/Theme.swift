import SwiftUI

enum AppTheme {
    // 近似截图的橙色强调色
    static let accent = Color(red: 0.93, green: 0.44, blue: 0.33) // #ED7154 近似
    static let accentBorder = Color(red: 0.92, green: 0.44, blue: 0.36).opacity(0.55)

    // 背景与分隔（动态，随浅/深色变化）
    static let background = Color(nsColor: .windowBackgroundColor)
    static let sidebarBG = Color(nsColor: .windowBackgroundColor)
    static let cardBorder = Color(nsColor: .separatorColor).opacity(0.35)
    static let separator = Color(nsColor: .separatorColor).opacity(0.4)

    static let cornerRadius: CGFloat = 12
    static let bigCorner: CGFloat = 18
    static let shadow = Color.black.opacity(0.04)
}

extension View {
    func cardShadow() -> some View {
        shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 2)
    }
}
