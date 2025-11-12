import SwiftUI
import AppKit
import Foundation

struct MarkdownPreviewer: View {
  var text: String

  struct Segment: Identifiable { let id = UUID(); let isCode: Bool; let content: String; let lang: String? }

  var body: some View {
    let segments = parseSegments(text)
    VStack(alignment: .leading, spacing: 10) {
      ForEach(segments) { seg in
        if seg.isCode {
          CodeBlockView(code: seg.content, lang: seg.lang)
        } else {
          if let attr = try? AttributedString(markdown: seg.content) {
            Text(attr)
              .frame(maxWidth: .infinity, alignment: .leading)
          } else {
            Text(verbatim: seg.content)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
    .padding(10)
    .frame(minHeight: AppLayout.editorMinHeight)
    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
  }

  private func parseSegments(_ md: String) -> [Segment] {
    let pattern = #"(?s)```([A-Za-z0-9_+-]*)\n(.*?)\n```"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return [Segment(isCode: false, content: md, lang: nil)] }
    let ns = md as NSString
    var result: [Segment] = []
    var last = 0
    for m in regex.matches(in: md, options: [], range: NSRange(location: 0, length: ns.length)) {
      let rangeBefore = NSRange(location: last, length: m.range.location - last)
      if rangeBefore.length > 0 {
        let s = ns.substring(with: rangeBefore)
        result.append(Segment(isCode: false, content: s, lang: nil))
      }
      let lang = m.range(at: 1).length > 0 ? ns.substring(with: m.range(at: 1)) : nil
      let code = ns.substring(with: m.range(at: 2))
      result.append(Segment(isCode: true, content: code, lang: lang))
      last = m.range.location + m.range.length
    }
    if last < ns.length {
      let s = ns.substring(with: NSRange(location: last, length: ns.length - last))
      result.append(Segment(isCode: false, content: s, lang: nil))
    }
    return result
  }
}

private struct CodeBlockView: View {
  var code: String
  var lang: String?

  var body: some View {
    let attr = SyntaxHighlighter.highlight(code, language: lang)
    ScrollView(.horizontal, showsIndicators: false) {
      Text(attr)
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .textBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
    }
  }
}
