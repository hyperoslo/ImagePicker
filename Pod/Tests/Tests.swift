import UIKit
import XCTest

class Tests: XCTestCase {

  func testFailing() {
    let ofCourse = true
    XCTAssertEqual(ofCourse, false)
  }
}
