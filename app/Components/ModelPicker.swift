import SwiftUI

struct ModelPicker: View {
  @EnvironmentObject private var modelStore: ModelStore
  @Binding var modelId: UUID?

  var body: some View {
    Picker("", selection: $modelId) {
      Text("未选择").tag(UUID?.none)
      ForEach(modelStore.models) { model in
        HStack {
          Image(systemName: model.type.iconName)
          Text(model.name)
        }
        .tag(UUID?.some(model.id))
      }
    }
    .pickerStyle(.menu)
  }
}

