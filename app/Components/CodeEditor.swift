import SwiftUI

// 轻量等宽“代码编辑器”占位实现，后续可替换为 NSTextView 包装以支持更丰富功能
struct CodeEditor: View {
  @Binding var text: String
  var focus: FocusState<Bool>.Binding? = nil

  var body: some View {
    TextEditor(text: $text)
      .font(.system(.body, design: .monospaced))
      .textSelection(.enabled)
      .frame(minHeight: AppLayout.editorMinHeight)
      .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
      .modifier(OptionalFocused(focus))
  }
}

private struct OptionalFocused: ViewModifier {
  let binding: FocusState<Bool>.Binding?
  init(_ binding: FocusState<Bool>.Binding?) { self.binding = binding }
  func body(content: Content) -> some View {
    if let b = binding { content.focused(b) } else { content }
  }
}
