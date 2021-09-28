// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class CIDTests: XCTestCase {
    func testExample() throws {
        let cid = try CID("bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a")
        XCTAssertEqual(try Multibase(cid!.hash.digest, withEncoding: .base16).stringRepresentation(), "cb0bb4beadfaed664a12f0dcaa6e9dc01ffcc21f3c9ae21b1c925d574b887ed8")
    }
}
