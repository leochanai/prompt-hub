import SwiftUI
import AppKit

struct SyntaxHighlighter {
  struct Theme {
    var keyword = NSColor.systemBlue
    var type = NSColor.systemPurple
    var string = NSColor.systemGreen
    var number = NSColor.systemOrange
    var comment = NSColor.systemGray
    var plain = NSColor.labelColor
    var font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
  }

  static func highlight(_ code: String, language: String?) -> AttributedString {
    let theme = Theme()
    let base = NSMutableAttributedString(string: code)
    base.addAttributes([
      .font: theme.font,
      .foregroundColor: theme.plain
    ], range: NSRange(location: 0, length: base.length))

    func apply(_ pattern: String, color: NSColor) {
      if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
        for m in regex.matches(in: code, options: [], range: NSRange(location: 0, length: base.length)) {
          base.addAttribute(.foregroundColor, value: color, range: m.range)
        }
      }
    }

    // Common
    apply(#"\b\d+(?:\.\d+)?\b"#, color: theme.number)               // numbers

    let lang = (language ?? "").lowercased()
    switch lang {
    case "swift":
      let kw = ["let","var","func","class","struct","enum","protocol","extension","import","if","else","guard","return","throw","throws","try","in","for","while","switch","case","default","public","private","internal","open","static","mutating","where","associatedtype","init","deinit","nil","true","false"]
      apply(wordPattern(from: kw), color: theme.keyword)
      apply(#"//.*"#, color: theme.comment)
      apply(#"/\*[\s\S]*?\*/"#, color: theme.comment)
      apply(stringPattern(), color: theme.string)
    case "js","javascript","ts","typescript":
      let kw = ["function","const","let","var","if","else","return","import","from","export","class","extends","new","try","catch","finally","throw","await","async","for","while","switch","case","default","break","continue","this","super","true","false","null","undefined","typeof","instanceof"]
      apply(wordPattern(from: kw), color: theme.keyword)
      apply(#"//.*"#, color: theme.comment)
      apply(#"/\*[\s\S]*?\*/"#, color: theme.comment)
      apply(stringPattern(), color: theme.string)
    case "py","python":
      let kw = ["def","class","import","from","as","if","elif","else","return","for","while","try","except","finally","with","lambda","True","False","None","pass","break","continue","yield","global","nonlocal"]
      apply(wordPattern(from: kw), color: theme.keyword)
      apply(#"#.*"#, color: theme.comment)
      apply(stringPattern(), color: theme.string)
    case "json":
      // keys
      apply(#"(?m)\"([^\"]+)\"\s*(?=:)"#, color: theme.type)
      // strings
      apply(#"\"([^"\\]|\\.)*\""#, color: theme.string)
    case "bash","sh","zsh":
      let kw = ["if","then","fi","elif","else","for","do","done","function","case","esac","in","echo","cd","ls","grep","awk","sed","exit","export"]
      apply(wordPattern(from: kw), color: theme.keyword)
      apply(#"#.*"#, color: theme.comment)
      apply(stringPattern(), color: theme.string)
    default:
      // Generic: strings and comments for C-like
      apply(#"//.*"#, color: theme.comment)
      apply(#"/\*[\s\S]*?\*/"#, color: theme.comment)
      apply(stringPattern(), color: theme.string)
    }

    return AttributedString(base)
  }

  private static func wordPattern(from words: [String]) -> String {
    let escaped = words.map { NSRegularExpression.escapedPattern(for: $0) }
    return "\\b(" + escaped.joined(separator: "|") + ")\\b"
  }

  private static func stringPattern() -> String { #"\"([^"\\]|\\.)*\"|'([^'\\]|\\.)*'"# }
}

