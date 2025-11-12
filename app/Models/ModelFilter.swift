import Foundation

struct ModelFilter: Codable, Equatable {
    var selectedTypes: Set<ModelType> = []
    var selectedVendors: Set<ModelVendor> = []
    // Names of custom vendors selected in filter
    var selectedCustomVendorNames: Set<String> = []

    var isEmpty: Bool { selectedTypes.isEmpty && selectedVendors.isEmpty && selectedCustomVendorNames.isEmpty }
    var activeCount: Int { selectedTypes.count + selectedVendors.count + selectedCustomVendorNames.count }
}
