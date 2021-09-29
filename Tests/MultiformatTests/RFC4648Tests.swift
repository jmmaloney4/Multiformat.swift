// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class RFC4648Tests: XCTestCase {
    func testOctetNTetConversion() {
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([19, 22, 5, 46], n: 6), [77, 97, 110])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([19, 22, 4], n: 6), [77, 97])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([19, 16], n: 6), [77])

        XCTAssertEqual(try RFC4648.octetGroupToNTets([77, 97, 110], n: 6), [19, 22, 5, 46])
        XCTAssertEqual(try RFC4648.octetGroupToNTets([77, 97], n: 6), [19, 22, 4])
        XCTAssertEqual(try RFC4648.octetGroupToNTets([77], n: 6), [19, 16])

        // 01100110 01101111  01101111
        // 01100 11001 10111 10110 11110
        //
        // 01100 11001 10111 10110 11110
        // 01100110 01101111  01101111 0
        XCTAssertEqual(try RFC4648.octetGroupToNTets([102, 111, 111], n: 5), [12, 25, 23, 22, 30])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([12, 25, 23, 22, 30], n: 5), [102, 111, 111])

        // Base 16
        XCTAssertEqual(try RFC4648.octetGroupToNTets([102], n: 4), [6, 6])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([6, 6], n: 4), [102])

        // Base 8
        XCTAssertEqual(try RFC4648.octetGroupToNTets([23], n: 3), [0, 5, 6])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([0, 5, 6], n: 3), [23])

        // Base 2
        XCTAssertEqual(try RFC4648.octetGroupToNTets([201], n: 1), [1, 1, 0, 0, 1, 0, 0, 1])
        XCTAssertEqual(try RFC4648.nTetGroupToOctets([1, 1, 0, 0, 1, 0, 0, 1], n: 1), [201])
    }

    func testCanonicalInput() {
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([19, 22, 5], n: 6)) { error in
            XCTAssertEqual(error as! MultibaseError, .notCanonicalInput)
        }
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([19, 22], n: 6)) { error in
            XCTAssertEqual(error as! MultibaseError, .notCanonicalInput)
        }
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([19], n: 6)) { error in
            XCTAssertEqual(error as! MultibaseError, .notCanonicalInput)
        }

        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([1], n: 1)) { error in
            XCTAssertEqual(error as! MultibaseError, .notCanonicalInput)
        }
    }

    func testInvalidN() {
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([19], n: 12)) { error in
            XCTAssertEqual(error as! MultibaseError, .invalidN)
        }
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([200], n: 9)) { error in
            XCTAssertEqual(error as! MultibaseError, .invalidN)
        }
        XCTAssertThrowsError(try RFC4648.nTetGroupToOctets([12], n: 0)) { error in
            XCTAssertEqual(error as! MultibaseError, .invalidN)
        }
    }

    let testCases = [
        (Data([0, 0, 0, 0, 0]), "AAAAAAA=", true, RFC4648.Alphabet.base64),
        (Data("Many hands make light work.".utf8), "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu", true, .base64),
        (Data("foob".utf8), "Zm9vYg==", true, .base64),
        (Data("foob".utf8), "Zm9vYg", false, .base64),
        (Data("foobar".utf8), "MZXW6YTBOI======", true, .base32upper),
        (Data("foob".utf8), "CPNMUOG=", true, .base32hexupper),
        (Data("foobar".utf8), "666F6F626172".lowercased(), true, .base16),
        (Data("".utf8), "", true, .base64url),
    ]

    func testBase64() {
        for (d, s, p, a) in self.testCases {
            XCTAssertEqual(try RFC4648.decode(s, as: a), d)
            XCTAssertEqual(try RFC4648.encode(d, to: a, pad: p), s)
        }
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

    let alphabetSizes = [
        (.binary, 2, 1),
        (.octal, 8, 3),
        (.base16, 16, 4),
        (.base16upper, 16, 4),
        (.base32, 32, 5),
        (.base32hex, 32, 5),
        (.base32upper, 32, 5),
        (.base32hexupper, 32, 5),
        (RFC4648.Alphabet.base64, 64, 6),
        (RFC4648.Alphabet.base64url, 64, 6),
    ]

    func testAlphabetSizes() {
        for (a, c, b) in self.alphabetSizes {
            XCTAssertEqual(a.asChars().count, c)
            XCTAssertEqual(a.bitsPerCharacter(), b)
        }
    }
}
