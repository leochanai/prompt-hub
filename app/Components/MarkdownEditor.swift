import SwiftUI

enum MarkdownEditorMode: String, CaseIterable, Identifiable {
  case edit, preview, split
  var id: String { rawValue }
  var title: LocalizedStringKey {
    switch self {
    case .edit: return "编辑"
    case .preview: return "预览"
    case .split: return "分屏"
    }
  }
}

struct MarkdownEditor: View {
  @Binding var text: String
  @State private var mode: MarkdownEditorMode = .edit

  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Picker("", selection: $mode) {
          ForEach(MarkdownEditorMode.allCases) { m in
            Text(m.title).tag(m)
          }
        }
        .pickerStyle(.segmented)
        Spacer()
        Text(meta)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Group {
        switch mode {
        case .edit:
          CodeEditor(text: $text)
        case .preview:
          MarkdownPreview(text: text)
            .frame(minHeight: AppLayout.editorMinHeight)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
        case .split:
          HStack(spacing: 10) {
            CodeEditor(text: $text)
            MarkdownPreview(text: text)
              .frame(minWidth: 0)
              .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
          }
          .frame(minHeight: AppLayout.editorMinHeight)
        }
      }
    }
  }

  private var meta: String {
    let lines = text.split(whereSeparator: { $0.isNewline }).count
    return "\(text.count) 字 · \(lines) 行"
  }
}

private struct MarkdownPreview: View {
  var text: String
  var body: some View {
    ScrollView {
      if let attr = try? AttributedString(markdown: text) {
        Text(attr)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
      } else {
        Text(text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
      }
    }
  }
}

