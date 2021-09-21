// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class BaseNTests: XCTestCase {
    func testToAndFromData() throws {
        XCTAssertEqual("000000111010101011110011", try BaseN.binary.fromData(try BaseN.binary.toData("000000111010101011110011")))
        print(log2(Double(16)))
        XCTAssertEqual("4D616E", try BaseN.hex.fromData("Man".data(using: .ascii)!))
    }
    
}
