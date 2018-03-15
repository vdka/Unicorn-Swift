import XCTest
@testable import Unicorn_Swift

class Unicorn_SwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Unicorn_Swift().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
