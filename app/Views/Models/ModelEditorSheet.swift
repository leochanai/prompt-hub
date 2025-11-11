import SwiftUI

struct ModelEditorSheet: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelStore: ModelStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: ModelType = .chat
    @State private var selectedVendor: ModelVendor = .anthropic
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private let labelWidth: CGFloat = 78
    private let controlWidth: CGFloat = 260
    // macOS 控件风格在分段与弹出按钮左侧存在额外可视空隙，做轻微修正以实现像素级左对齐
    private let leadingAlignFix: CGFloat = -10

    private var isEditing: Bool {
        appState.editingModel != nil
    }

    private var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            && trimmedName.count <= 40
            && !modelStore.modelExists(withName: trimmedName, excludingId: appState.editingModel?.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "编辑模型配置" as LocalizedStringKey : "新建模型配置" as LocalizedStringKey)
                    .font(.headline)
                Spacer()
                Button("取消" as LocalizedStringKey) {
                    dismiss()
                }
            }
            .padding()
            .background(AppTheme.background)

            Divider()

            // Content (custom layout, no Form background)
            VStack(alignment: .leading, spacing: 16) {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
                    // Name
                    GridRow(alignment: .center) {
                        Text("模型名称" as LocalizedStringKey)
                            .frame(width: labelWidth, alignment: .leading)
                        HStack(spacing: 0) {
                            TextField("", text: $name)
                                .textFieldStyle(.roundedBorder)
                            Spacer(minLength: 0)
                        }
                        .frame(width: controlWidth)
                        .gridColumnAlignment(.leading)
                    }

                    if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count > 40 {
                        GridRow {
                            Color.clear.frame(width: labelWidth)
                            Text("名称不能超过40个字符" as LocalizedStringKey)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    // Type
                    GridRow(alignment: .center) {
                        Text("模型类型" as LocalizedStringKey)
                            .frame(width: labelWidth, alignment: .leading)
                        HStack(spacing: 0) {
                            Picker("" as LocalizedStringKey, selection: $selectedType) {
                                ForEach(ModelType.allCases, id: \.self) { type in
                                    Label {
                                        Text(type.titleKey)
                                    } icon: {
                                        Image(systemName: type.iconName)
                                    }
                                    .labelStyle(.titleAndIcon)
                                    .tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            Spacer(minLength: 0)
                        }
                        .frame(width: controlWidth)
                        .padding(.leading, leadingAlignFix)
                        .gridColumnAlignment(.leading)
                    }

                    // Vendor
                    GridRow(alignment: .center) {
                        Text("供应商" as LocalizedStringKey)
                            .frame(width: labelWidth, alignment: .leading)
                        HStack(spacing: 0) {
                            Picker("" as LocalizedStringKey, selection: $selectedVendor) {
                                ForEach(ModelVendor.allCases, id: \.self) { vendor in
                                    Text(vendor.localizedTitleKey)
                                        .tag(vendor)
                                }
                            }
                            .pickerStyle(.menu)
                            Spacer(minLength: 0)
                        }
                        .frame(width: controlWidth)
                        .padding(.leading, leadingAlignFix)
                        .gridColumnAlignment(.leading)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)

            Spacer()

            // Actions
            HStack {
                Button("删除" as LocalizedStringKey) {
                    deleteModel()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.red)
                .opacity(isEditing ? 1 : 0)
                .disabled(!isEditing)

                Spacer()

                Button("保存" as LocalizedStringKey) {
                    saveModel()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 400, height: 400)
        .onAppear {
            setupForm()
        }
        .alert("提示" as LocalizedStringKey, isPresented: $showingAlert) {
            Button("确定" as LocalizedStringKey, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func setupForm() {
        if let model = appState.editingModel {
            name = model.name
            selectedType = model.type
            selectedVendor = model.vendor
        } else {
            name = ""
            selectedType = .chat
            selectedVendor = .anthropic
        }
    }

    private func saveModel() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if modelStore.modelExists(withName: trimmedName, excludingId: appState.editingModel?.id) {
            alertMessage = String(localized: "模型名称已存在，请使用其他名称")
            showingAlert = true
            return
        }

        let model: ModelConfig
        if let existingModel = appState.editingModel {
            model = ModelConfig(
                id: existingModel.id,
                name: trimmedName,
                type: selectedType,
                vendor: selectedVendor,
                createdAt: existingModel.createdAt,
                updatedAt: .now
            )
        } else {
            model = ModelConfig(
                name: trimmedName,
                type: selectedType,
                vendor: selectedVendor
            )
        }

        modelStore.upsert(model)
        dismiss()
    }

    private func deleteModel() {
        guard let model = appState.editingModel else { return }
        modelStore.remove(model.id)
        dismiss()
    }
}

#Preview {
    ModelEditorSheet()
        .environmentObject(AppState())
        .environmentObject(ModelStore())
}
