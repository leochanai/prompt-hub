import Foundation

struct ModelFilter: Codable, Equatable {
    var selectedTypes: Set<ModelType> = []
    var selectedVendors: Set<ModelVendor> = []

    var isEmpty: Bool { selectedTypes.isEmpty && selectedVendors.isEmpty }
    var activeCount: Int { selectedTypes.count + selectedVendors.count }
}

