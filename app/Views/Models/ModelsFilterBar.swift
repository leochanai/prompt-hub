import SwiftUI

struct ModelsFilterBar: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelStore: ModelStore

    var filteredCount: Int
    var onAdd: () -> Void

    private var typeCount: Int { appState.modelFilter.selectedTypes.count }
    private var vendorCount: Int { appState.modelFilter.selectedVendors.count + appState.modelFilter.selectedCustomVendorNames.count }

    private var typeTitle: Text {
        let base = Text("模型类型" as LocalizedStringKey)
        if typeCount > 0 { return base + Text(" · \(typeCount)") }
        return base
    }

    private var vendorTitle: Text {
        let base = Text("供应商" as LocalizedStringKey)
        if vendorCount > 0 { return base + Text(" · \(vendorCount)") }
        return base
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: filters
            HStack(spacing: 10) {
                // Type Menu
                Menu {
                    ForEach(ModelType.allCases, id: \.self) { t in
                        Toggle(isOn: binding(for: t)) {
                            Label { Text(t.titleKey) } icon: { Image(systemName: t.iconName) }
                        }
                    }
                    Divider()
                    Toggle(isOn: bindingAllTypes) {
                        Text("全部" as LocalizedStringKey)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        typeTitle
                    }
                }

                // Vendor Menu (动态获取：内置供应商 + 自定义供应商名称)
                Menu {
                    // Built-in vendors (excluding .custom)
                    ForEach(availableEnumVendors, id: \.self) { v in
                        Toggle(isOn: binding(for: v)) {
                            Text(v.localizedTitleKey)
                        }
                    }
                    // Custom vendor names present in current models
                    ForEach(availableCustomVendorNames, id: \.self) { name in
                        Toggle(isOn: binding(forCustomVendorName: name)) {
                            Text(name)
                        }
                    }
                    Divider()
                    Toggle(isOn: bindingAllVendors) {
                        Text("全部" as LocalizedStringKey)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2")
                        vendorTitle
                    }
                }
            }

            Spacer()

            // Search
            TextField("搜索", text: $appState.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 260)

            // Count
            (Text("模型" as LocalizedStringKey) + Text(" · \(filteredCount)"))
                .foregroundColor(.secondary)

            // Clear
            if !appState.modelFilter.isEmpty {
                Button("清除过滤" as LocalizedStringKey) {
                    appState.modelFilter = .init()
                }
                .buttonStyle(.bordered)
            }

            // Add
            Button {
                onAdd()
            } label: {
                Label("新建配置", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(AppTheme.background)
        .overlay(Rectangle().fill(AppTheme.separator).frame(height: 1), alignment: .bottom)
    }

    private func binding(for type: ModelType) -> Binding<Bool> {
        Binding<Bool>(
            get: { appState.modelFilter.selectedTypes.contains(type) },
            set: { newValue in
                var f = appState.modelFilter
                if newValue { f.selectedTypes.insert(type) } else { f.selectedTypes.remove(type) }
                // 若已全选，折叠为“全部”（空集表示不过滤）
                if f.selectedTypes.count == ModelType.allCases.count { f.selectedTypes.removeAll() }
                appState.modelFilter = f
            }
        )
    }

    private func binding(for vendor: ModelVendor) -> Binding<Bool> {
        Binding<Bool>(
            get: { appState.modelFilter.selectedVendors.contains(vendor) },
            set: { newValue in
                var f = appState.modelFilter
                if newValue { f.selectedVendors.insert(vendor) } else { f.selectedVendors.remove(vendor) }
                // 若内置 + 自定义均已全选，则折叠为“全部”
                if (f.selectedVendors.count + f.selectedCustomVendorNames.count) == totalAvailableVendorCount {
                    f.selectedVendors.removeAll()
                    f.selectedCustomVendorNames.removeAll()
                }
                appState.modelFilter = f
            }
        )
    }

    private func binding(forCustomVendorName name: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { appState.modelFilter.selectedCustomVendorNames.contains(name) },
            set: { newValue in
                var f = appState.modelFilter
                if newValue { f.selectedCustomVendorNames.insert(name) } else { f.selectedCustomVendorNames.remove(name) }
                if (f.selectedVendors.count + f.selectedCustomVendorNames.count) == totalAvailableVendorCount {
                    f.selectedVendors.removeAll()
                    f.selectedCustomVendorNames.removeAll()
                }
                appState.modelFilter = f
            }
        )
    }

    private var bindingAllTypes: Binding<Bool> {
        Binding<Bool>(
            get: { appState.modelFilter.selectedTypes.isEmpty },
            set: { newValue in
                var f = appState.modelFilter
                if newValue { f.selectedTypes.removeAll() }
                else { /* 通过选择具体项来关闭“全部” */ }
                appState.modelFilter = f
            }
        )
    }

    private var bindingAllVendors: Binding<Bool> {
        Binding<Bool>(
            get: { appState.modelFilter.selectedVendors.isEmpty && appState.modelFilter.selectedCustomVendorNames.isEmpty },
            set: { newValue in
                var f = appState.modelFilter
                if newValue {
                    f.selectedVendors.removeAll()
                    f.selectedCustomVendorNames.removeAll()
                } else {
                    // 通过选择具体项来关闭“全部”
                }
                appState.modelFilter = f
            }
        )
    }

    // 当前可用的供应商选项：每次切换到“大模型”页面时，视图重建并根据现有模型动态计算
    private var availableEnumVendors: [ModelVendor] {
        let present = Set(modelStore.models.map { $0.vendor })
        // 保持原有顺序，且不包含 .custom（自定义供应商通过名称单独展示）
        return ModelVendor.allCases.filter { $0 != .custom && present.contains($0) }
    }

    private var availableCustomVendorNames: [String] {
        let names = modelStore.models
            .filter { $0.vendor == .custom }
            .compactMap { ($0.customVendorName ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(names)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var totalAvailableVendorCount: Int { availableEnumVendors.count + availableCustomVendorNames.count }
}
