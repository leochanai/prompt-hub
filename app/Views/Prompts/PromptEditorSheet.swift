import SwiftUI
import AppKit

struct PromptEditorSheet: View {
    @EnvironmentObject private var store: PromptStore
    @EnvironmentObject private var modelStore: ModelStore

    @Environment(\.dismiss) private var dismiss
    @State private var working: PromptTemplate
    @State private var showTagPopover: Bool = false
    var onDone: (PromptTemplate, Bool) -> Void // (updated, delete)

    init(prompt: PromptTemplate, onDone: @escaping (PromptTemplate, Bool) -> Void) {
        _working = State(initialValue: prompt)
        self.onDone = onDone
    }

    // 会话级媒体（加载自磁盘，缩略图等）
    private struct LocalImageItem: Identifiable, Hashable { let id: UUID; let image: NSImage; let url: URL? }
    @State private var imageItems: [LocalImageItem] = []
    @State private var leftSel: UUID? = nil
    @State private var rightSel: UUID? = nil
    @State private var videoItems: [URL] = []
    @State private var compareRatio: CGFloat = 0.5
    @FocusState private var editorFocused: Bool

    // 当前选择的模型
    private var selectedModel: ModelConfig? {
        if let id = working.modelId { return modelStore.models.first { $0.id == id } }
        return nil
    }

    // 媒体持久化路径
    private func mediaRootURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("PromptHub", isDirectory: true).appendingPathComponent("media", isDirectory: true)
    }
    private func promptFolderURL() -> URL {
        mediaRootURL().appendingPathComponent(working.id.uuidString, isDirectory: true)
    }
    private func folderURL(for type: PromptMediaType) -> URL {
        switch type {
        case .image: return promptFolderURL().appendingPathComponent("images", isDirectory: true)
        case .video: return promptFolderURL().appendingPathComponent("videos", isDirectory: true)
        }
    }
    private func ensureFolder(_ url: URL) { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
    private func absoluteURL(fromRelative rel: String) -> URL { mediaRootURL().appendingPathComponent(rel) }
    private func relativePath(fromAbsolute abs: URL) -> String {
        let root = mediaRootURL().standardizedFileURL
        let path = abs.standardizedFileURL.path
        var rel = path.replacingOccurrences(of: root.path + "/", with: "")
        if rel.hasPrefix("/") { rel.removeFirst() }
        return rel
    }

    private func importMediaFiles(_ urls: [URL], as type: PromptMediaType) {
        let destFolder = folderURL(for: type)
        ensureFolder(destFolder)
        for src in urls {
            let ext = (src.pathExtension.isEmpty ? (type == .image ? "png" : "mov") : src.pathExtension)
            let dest = destFolder.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
            do {
                if FileManager.default.fileExists(atPath: dest.path) { try? FileManager.default.removeItem(at: dest) }
                try FileManager.default.copyItem(at: src, to: dest)
                let rel = relativePath(fromAbsolute: dest)
                let media = PromptMedia(type: type, relativePath: rel)
                working.media.append(media)
                if type == .image, let img = NSImage(contentsOf: dest) {
                    imageItems.append(.init(id: media.id, image: img, url: dest))
                } else if type == .video {
                    videoItems.append(dest)
                }
            } catch {
                // ignore copy failures for now
            }
        }
    }

    private func loadPersistedMediaOnce() {
        if imageItems.isEmpty {
            for m in working.media where m.type == .image {
                let url = absoluteURL(fromRelative: m.relativePath)
                if let img = NSImage(contentsOf: url) { imageItems.append(.init(id: m.id, image: img, url: url)) }
            }
        }
        if videoItems.isEmpty {
            for m in working.media where m.type == .video {
                let url = absoluteURL(fromRelative: m.relativePath)
                if FileManager.default.fileExists(atPath: url.path) { videoItems.append(url) }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header (toolbar-like)
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                    if working.title.isEmpty {
                        Text("编辑提示词")
                    } else {
                        Text(verbatim: working.title)
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button("删除", role: .destructive) {
                    // 清理该提示词的媒体目录
                    let folder = promptFolderURL()
                    try? FileManager.default.removeItem(at: folder)
                    onDone(working, true)
                    dismiss()
                }
                .buttonStyle(.bordered)
                Button("完成") {
                    working.updatedAt = .now
                    onDone(working, false)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppTheme.background)
            Divider()

            GeometryReader { proxy in
                let isTwoColumn = proxy.size.width >= AppLayout.twoColumnBreakpoint
                ScrollView {
                    if isTwoColumn {
                        HStack(alignment: .top, spacing: AppLayout.sectionSpacing) {
                            VStack(alignment: .leading, spacing: AppLayout.sectionSpacing) {
                                SectionCard(title: "基本信息") { metaGrid }
                            }
                            .frame(maxWidth: 520)

                            VStack(alignment: .leading, spacing: AppLayout.sectionSpacing) {
                                SectionCard(title: "内容") { contentEditorSection }
                                if let t = selectedModel?.type, t == .image {
                                    SectionCard(title: "图片素材") { imageSection }
                                }
                                if let t = selectedModel?.type, t == .video {
                                    SectionCard(title: "视频素材") { videoSection }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(AppLayout.contentPadding)
                    } else {
                        VStack(alignment: .leading, spacing: AppLayout.sectionSpacing) {
                            SectionCard(title: "基本信息") { metaGrid }
                            SectionCard(title: "内容") { contentEditorSection }
                            if let t = selectedModel?.type, t == .image {
                                SectionCard(title: "图片素材") { imageSection }
                            }
                            if let t = selectedModel?.type, t == .video {
                                SectionCard(title: "视频素材") { videoSection }
                            }
                        }
                        .padding(AppLayout.contentPadding)
                    }
                }
            }
        }
        .background(AppTheme.background)
        .onAppear { loadPersistedMediaOnce(); editorFocused = true }
    }

    // 左侧：基本信息网格
    private var metaGrid: some View {
        Grid(alignment: .leading,
             horizontalSpacing: AppLayout.gridHSpacing,
             verticalSpacing: AppLayout.gridVSpacing) {
            GridRow(alignment: .center) {
                Text("标题").frame(width: AppLayout.formLabelWidth, alignment: .leading)
                TextField("请输入标题", text: $working.title)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
                            GridRow(alignment: .center) {
                                Text("来源链接").frame(width: AppLayout.formLabelWidth, alignment: .leading)
                                HStack(spacing: 8) {
                                    TextField("https://…", text: $working.sourceURL)
                                        .textFieldStyle(.roundedBorder)
                                    Button("打开链接") {
                                        if let url = URL(string: working.sourceURL), !working.sourceURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }
                                    .disabled(URL(string: working.sourceURL) == nil)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            GridRow(alignment: .center) {
                                Text("最佳模型").frame(width: AppLayout.formLabelWidth, alignment: .leading)
                                HStack(spacing: 0) {
                                    ModelPicker(modelId: $working.modelId)
                                        .padding(.leading, AppLayout.controlLeadingAlignFix)
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity)
                            }
            GridRow(alignment: .top) {
                Text("标签").frame(width: AppLayout.formLabelWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    if working.tags.isEmpty {
                        TagAddCallout { showTagPopover = true }
                            .popover(isPresented: $showTagPopover, arrowEdge: .top) {
                                TagPickerPopover(selectedIDs: $working.tags)
                                    .environmentObject(store)
                            }
                    } else {
                        FlowLayout(spacing: 8, alignment: .leading) {
                            ForEach(working.tags, id: \.self) { tid in
                                if let tag = store.tag(by: tid) {
                                    TagTokenChip(tag: tag) {
                                        working.tags.removeAll { $0 == tid }
                                    }
                                }
                            }
                            Button {
                                showTagPopover = true
                            } label: {
                                Image(systemName: "plus")
                                    .padding(6)
                                    .background(Capsule().stroke(AppTheme.cardBorder))
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showTagPopover, arrowEdge: .top) {
                                TagPickerPopover(selectedIDs: $working.tags)
                                    .environmentObject(store)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // 内容编辑器（带预览切换）
    private var contentEditorSection: some View {
        Group {
            if editorFocused {
                CodeEditor(text: $working.content, focus: $editorFocused)
            } else {
                ScrollView { MarkdownPreviewer(text: working.content) }
                    .onTapGesture { editorFocused = true }
            }
        }
    }

    // MARK: - Sections

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            MediaDropZone(mode: .images, titleKey: "拖拽图片到此处，或点击选择") { urls in
                importMediaFiles(urls, as: .image)
            }

            if !imageItems.isEmpty {
                // 缩略图网格 + L/R 选择
                let cols = [GridItem(.adaptive(minimum: AppLayout.thumbMinWidth), spacing: 10, alignment: .top)]
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(imageItems) { item in
                        ZStack(alignment: .topTrailing) {
                            Image(nsImage: item.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: AppLayout.thumbHeight)
                                .clipped()
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke((leftSel == item.id || rightSel == item.id) ? AppTheme.accentBorder : AppTheme.cardBorder)
                                )

                            // File name bottom overlay (if available)
                            if let name = item.url?.lastPathComponent {
                                Text(verbatim: name)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.thinMaterial)
                                    .cornerRadius(6)
                                    .padding(6)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            }

                            HStack(spacing: 6) {
                                selectBadge(label: "L", selected: leftSel == item.id) { leftSel = (leftSel == item.id ? nil : item.id) }
                                selectBadge(label: "R", selected: rightSel == item.id) { rightSel = (rightSel == item.id ? nil : item.id) }
                                Button {
                                    if let url = item.url { try? FileManager.default.removeItem(at: url) }
                                    working.media.removeAll { $0.id == item.id }
                                    imageItems.removeAll { $0.id == item.id }
                                    if leftSel == item.id { leftSel = nil }
                                    if rightSel == item.id { rightSel = nil }
                                } label: {
                                    Image(systemName: "trash")
                                        .padding(6)
                                        .background(Circle().fill(Color(nsColor: .textBackgroundColor)))
                                        .overlay(Circle().stroke(AppTheme.cardBorder))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(6)
                        }
                    }
                }

                HStack {
                    Button("重置对比") { compareRatio = 0.5 }
                        .buttonStyle(.plain)
                    Spacer()
                    Button("清空图片") {
                        let folder = folderURL(for: .image)
                        try? FileManager.default.removeItem(at: folder)
                        imageItems.removeAll(); leftSel = nil; rightSel = nil
                        working.media.removeAll { $0.type == .image }
                    }
                        .buttonStyle(.bordered)
                }

                if let l = leftSel, let r = rightSel,
                   let li = imageItems.first(where: { $0.id == l })?.image,
                   let ri = imageItems.first(where: { $0.id == r })?.image {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("对比")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        ImageCompareSlider(left: li, right: ri, ratio: $compareRatio)
                            .frame(height: AppLayout.previewCompareHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.cardBorder))
                    }
                }
            }
        }
    }

    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            MediaDropZone(mode: .videos, titleKey: "拖拽视频到此处，或点击选择") { urls in
                importMediaFiles(urls, as: .video)
            }

            if !videoItems.isEmpty {
                let cols = [GridItem(.adaptive(minimum: 180), spacing: 10, alignment: .top)]
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(videoItems, id: \.self) { url in
                        HStack(alignment: .center, spacing: 10) {
                            let icon = NSWorkspace.shared.icon(forFile: url.path)
                            Image(nsImage: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 38)
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                            Button {
                                // remove file and detach from media list
                                try? FileManager.default.removeItem(at: url)
                                let rel = relativePath(fromAbsolute: url)
                                working.media.removeAll { $0.type == .video && $0.relativePath == rel }
                                videoItems.removeAll { $0 == url }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(8)
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .textBackgroundColor)))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
                    }
                }
                HStack {
                    Spacer()
                    Button("清空视频") {
                        let folder = folderURL(for: .video)
                        try? FileManager.default.removeItem(at: folder)
                        videoItems.removeAll()
                        working.media.removeAll { $0.type == .video }
                    }
                        .buttonStyle(.bordered)
                }
    }
        }
    }

    private func selectBadge(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(selected ? AppTheme.accent.opacity(0.15) : Color(nsColor: .textBackgroundColor)))
                .overlay(Capsule().stroke(selected ? AppTheme.accentBorder : AppTheme.cardBorder))
        }
        .buttonStyle(.plain)
    }
}

// Section card container with title and consistent style
private struct SectionCard<Content: View>: View {
    var title: LocalizedStringKey
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).fill(Color(nsColor: .textBackgroundColor).opacity(0.95)))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.cardBorder))
    }
}

// 简易流式布局（用于标签）
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: () -> Content

    init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View { _Flow(spacing: spacing, alignment: alignment) { content() } }
}

private struct _Flow: Layout {
    let spacing: CGFloat
    let alignment: HorizontalAlignment

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 600
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for v in subviews {
            let sz = v.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            rowHeight = max(rowHeight, sz.height)
            x += sz.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for v in subviews {
            let sz = v.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: sz.width, height: sz.height))
            x += sz.width + spacing
            rowHeight = max(rowHeight, sz.height)
        }
    }
}
