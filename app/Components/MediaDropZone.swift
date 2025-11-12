import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct MediaDropZone: View {
  enum Mode { case images, videos }

  var mode: Mode
  var titleKey: LocalizedStringKey
  var onFiles: ([URL]) -> Void

  @State private var isTargeted: Bool = false

  private var acceptedTypes: [UTType] {
    switch mode {
    case .images: return [.image, .fileURL]
    case .videos: return [.movie, .video, .fileURL]
    }
  }

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: mode == .images ? "photo.on.rectangle" : "video")
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(.secondary)
      Text(titleKey).foregroundStyle(.secondary)
      Button("选择文件") { pickFiles() }
        .buttonStyle(.bordered)
    }
    .frame(maxWidth: .infinity, minHeight: AppLayout.mediaDropMinHeight)
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(nsColor: .textBackgroundColor).opacity(isTargeted ? 1.0 : 0.9))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isTargeted ? AppTheme.accentBorder : AppTheme.cardBorder, style: StrokeStyle(lineWidth: 1, dash: [6,4]))
    )
    .onDrop(of: acceptedTypes, isTargeted: $isTargeted) { providers in
      handleDrop(providers)
      return true
    }
  }

  private func pickFiles() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = true
    switch mode {
    case .images:
      panel.allowedContentTypes = [.image]
    case .videos:
      panel.allowedContentTypes = [.movie, .video]
    }
    panel.begin { resp in
      if resp == .OK { onFiles(panel.urls) }
    }
  }

  private func handleDrop(_ providers: [NSItemProvider]) {
    var urls: [URL] = []
    let group = DispatchGroup()
    for p in providers {
      if p.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
        group.enter()
        p.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
          defer { group.leave() }
          if let data = item as? Data, let str = String(data: data, encoding: .utf8), let url = URL(string: str) {
            urls.append(url)
          } else if let url = item as? URL {
            urls.append(url)
          }
        }
      }
    }
    group.notify(queue: .main) {
      onFiles(urls)
    }
  }
}
