// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class Base58Tests: XCTestCase {
    // used by BTCUtils code base as well as swift implementations
    let stringTests = [
        (Data("".utf8), ""),
        (Data(" ".utf8), "Z"),
        (Data("-".utf8), "n"),
        (Data("0".utf8), "q"),
        (Data("1".utf8), "r"),
        (Data("-1".utf8), "4SU"),
        (Data("11".utf8), "4k8"),
        (Data("abc".utf8), "ZiCa"),
        (Data("1234598760".utf8), "3mJr7AoUXx2Wqd"),
        (Data("abcdefghijklmnopqrstuvwxyz".utf8), "3yxU3u1igY8WkgtjK92fbJQCd4BZiiT1v25f"),
        (Data("00000000000000000000000000000000000000000000000000000000000000".utf8), "3sN2THZeE9Eh9eYrwkvZqNstbHGvrxSAM7gXUXvyFQP8XvQLUqNCS27icwUeDT7ckHm4FUHM2mTVh1vbLmk7y"),
    ]

    func testBase58() {
        for (input, output) in self.stringTests {
            XCTAssertEqual(try input.multibaseEncodedString(.base58btc, prefix: false), output)
            XCTAssertEqual(try Data(fromMultibaseEncodedString: output, withEncoding: .base58btc), input)
        }
    }
}
