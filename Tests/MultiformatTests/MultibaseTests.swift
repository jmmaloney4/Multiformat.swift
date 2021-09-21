// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class MultibaseTests: XCTestCase {
    func testEncodingIdentification() throws {
        // bafykbzacedlxaeuckppk5sxhk4bkriewnf3zcojvaklwgzvwaghykrmuyzi3u
        XCTAssertEqual(Multibase.identifyEncoding(string: "bafykbzacedlxaeuckppk5sxhk4bkriewnf3zcojvaklwgzvwaghykrmuyzi3u"), Multibase.Encoding.base32)
        XCTAssertEqual(Multibase.identifyEncoding(string: "zfffs"), Multibase.Encoding.base58btc)
        XCTAssertEqual(Multibase.identifyEncoding(string: "asdfasdf"), nil)
    }
}
