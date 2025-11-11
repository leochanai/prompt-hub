import SwiftUI

struct PromptEditorSheet: View {
    @EnvironmentObject private var store: PromptStore

    @Environment(\.dismiss) private var dismiss
    @State private var working: PromptTemplate
    var onDone: (PromptTemplate, Bool) -> Void // (updated, delete)

    init(prompt: PromptTemplate, onDone: @escaping (PromptTemplate, Bool) -> Void) {
        _working = State(initialValue: prompt)
        self.onDone = onDone
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(working.title.isEmpty ? "编辑提示词" : working.title)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(role: .destructive) {
                    onDone(working, true)
                    dismiss()
                } label: { Label("删除", systemImage: "trash") }
                Button("完成") {
                    working.updatedAt = .now
                    onDone(working, false)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, 4)

            Form {
                TextField("标题", text: $working.title)
                TextField("摘要", text: $working.summary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("内容")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    TextEditor(text: $working.content)
                        .frame(minHeight: 160)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cardBorder))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("标签")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 8, alignment: .leading) {
                        ForEach(store.tags) { tag in
                            let selected = working.tags.contains(tag.id)
                            Button {
                                if selected { working.tags.removeAll { $0 == tag.id } }
                                else { working.tags.append(tag.id) }
                            } label: {
                                HStack(spacing: 6) {
                                    Circle().fill(tag.color.opacity(0.9)).frame(width: 8, height: 8)
                                    Text(tag.name).font(.system(size: 12, weight: .medium))
                                }
                                .padding(.vertical, 6).padding(.horizontal, 10)
                                .background(Capsule().fill(selected ? tag.color.opacity(0.15) : Color(nsColor: .textBackgroundColor)))
                                .overlay(Capsule().stroke(selected ? tag.color.opacity(0.6) : AppTheme.cardBorder, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(16)
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
