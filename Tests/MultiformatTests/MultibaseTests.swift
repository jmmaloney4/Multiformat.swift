// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class MultibaseTests: XCTestCase {
    func testEncodingIdentification() {
        // bafykbzacedlxaeuckppk5sxhk4bkriewnf3zcojvaklwgzvwaghykrmuyzi3u
        XCTAssertEqual(Multibase.identifyEncoding(string: "bafykbzacedlxaeuckppk5sxhk4bkriewnf3zcojvaklwgzvwaghykrmuyzi3u"), Multibase.Encoding.base32)
        XCTAssertEqual(Multibase.identifyEncoding(string: "zfffs"), Multibase.Encoding.base58btc)
        XCTAssertEqual(Multibase.identifyEncoding(string: "asdfasdf"), nil)
        XCTAssertEqual(Multibase.identifyEncoding(string: "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw=="), .base64pad)
    }

    func testDecode() throws {
        XCTAssertEqual(
            [UInt8](try Data(fromMultibaseEncodedString: "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw==")),
            [0x4D, 0x75, 0x6C, 0x74, 0x69, 0x62, 0x61, 0x73, 0x65, 0x20, 0x69, 0x73, 0x20, 0x61, 0x77, 0x65, 0x73, 0x6F, 0x6D, 0x65, 0x21, 0x20, 0x5C, 0x6F, 0x2F]
        )

        XCTAssertEqual(Data([127, 0, 0, 1]), try Data(fromMultibaseEncodedString: "pro-lusab-babad"))
    }
}
