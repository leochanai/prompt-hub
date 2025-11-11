import XCTest
@testable import PromptHub

final class ModelFilterTests: XCTestCase {
    func testEmptyFilter() {
        let f = ModelFilter()
        XCTAssertTrue(f.isEmpty)
        XCTAssertEqual(f.activeCount, 0)
    }
}

