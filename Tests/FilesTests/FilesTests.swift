import XCTest
@testable import Files

final class FilesTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Files().text, "Hello, World!")
    }
}
