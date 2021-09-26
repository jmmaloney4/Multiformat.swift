// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class BaseNTests: XCTestCase {
    func testSextetOctetConversion() {
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 22, 5, 46]), [77, 97, 110])
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 22, 4]), [77, 97])
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 16]), [77])

        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19, 22, 5]))
        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19, 22]))
        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19]))
    }

    func testQuintetOctetConversion() {
        XCTAssertEqual(try RFC4648.octetsToNBits([102, 111, 111], n: 5), [12, 25, 23, 22, 30])
        XCTAssertEqual(try RFC4648.quintetsToOctets([12, 25, 23, 22, 30]), [102, 111, 111])
        XCTAssertEqual(try RFC4648.octetsToNBits([77, 97], n: 6), [19, 22, 4])

        XCTAssertEqual(try RFC4648.octetsToNBits([77, 97, 110], n: 6), [19, 22, 5, 46])
        XCTAssertEqual(try RFC4648.octetsToNBits([77, 97], n: 6), [19, 22, 4])
        XCTAssertEqual(try RFC4648.octetsToNBits([77], n: 6), [19, 16])
    }

    func testToAndFromData() throws {
        XCTAssertEqual(try RFC4648.decodeBase64("Zm9v"), [UInt8]("foo".utf8))

        XCTAssertEqual(try RFC4648.encodeToBase64(Data("Many hands make light work.".utf8)), "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu")
        XCTAssertEqual(try RFC4648.decodeBase64("TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu"), [UInt8]("Many hands make light work.".utf8))

        XCTAssertEqual(try RFC4648.encodeToBase64(Data("foob".utf8)), "Zm9vYg==")
    }

    func testPow2() {
        XCTAssertEqual(pow2(0), 1)
        XCTAssertEqual(pow2(1), 2)
        XCTAssertEqual(pow2(2), 4)
        XCTAssertEqual(pow2(3), 8)
        XCTAssertEqual(pow2(4), 16)
        XCTAssertEqual(pow2(5), 32)
        XCTAssertEqual(pow2(6), 64)
        XCTAssertEqual(pow2(7), 128)
    }
}
