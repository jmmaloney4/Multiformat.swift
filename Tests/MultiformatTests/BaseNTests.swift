// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class BaseNTests: XCTestCase {
    func testToAndFromData() throws {
        XCTAssertEqual("000111010101011110011", try BaseN().fromData(try BaseN().toData("000111010101011110011")))
    }
}
