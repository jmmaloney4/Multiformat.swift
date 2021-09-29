// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class ArrayTests: XCTestCase {
    func testGroup() throws {
        XCTAssertEqual([0, 1, 2, 3, 4, 5].grouped(3), [[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual([0, 1, 2, 3, 4].grouped(3), [[0, 1, 2], [3, 4]])
        XCTAssertEqual([0, 1, 3, 4, 5].grouped(3), [[0, 1, 3], [4, 5]])
        XCTAssertEqual([Int]().grouped(3), [])
        XCTAssertEqual([0].grouped(3), [[0]])
        XCTAssertEqual([0, 1].grouped(3), [[0, 1]])
    }
}
