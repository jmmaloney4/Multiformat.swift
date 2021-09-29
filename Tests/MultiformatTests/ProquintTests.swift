// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class ProquintTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try Proquint.wordToProquint([127, 0]), "lusab")
        XCTAssertEqual(try Proquint.proquintToWord("lusab"), [127, 0])

        XCTAssertEqual(try Proquint.encode(Data([127, 0, 0, 1])), "lusab-babad")
        XCTAssertEqual(try Proquint.decode("lusab-babad"), Data([127, 0, 0, 1]))
    }
}
