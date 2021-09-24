// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Multiformat

final class BaseNTests: XCTestCase {
    func testToAndFromData() throws {
//        XCTAssertEqual("000000111010101011110011", try BaseN.binary.fromData(try BaseN.binary.toData("000000111010101011110011")))
//        print(log2(Double(16)))
//        XCTAssertEqual("010011010110000101101110", try BaseN.binary.fromData("Man".data(using: .ascii)!))
//        XCTAssertEqual("4D616E", try BaseN.hex.fromData("Man".data(using: .ascii)!))
//        XCTAssertEqual("TWFu", try BaseN.base64.fromData("Man".data(using: .ascii)!))
//        XCTAssertEqual("23260556", try BaseN.octal.fromData("Man".data(using: .ascii)!))
        
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 22, 5, 46]), [77, 97, 110])
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 22, 4]), [77, 97])
        XCTAssertEqual(try RFC4648.sextetGroupToOctets([19, 16]), [77])
        
        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19, 22, 5]))
        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19, 22]))
        XCTAssertThrowsError(try RFC4648.sextetGroupToOctets([19]))
        
        XCTAssertEqual(try RFC4648.octetGroupToSextets([77, 97, 110]), [19, 22, 5, 46])
        XCTAssertEqual(try RFC4648.octetGroupToSextets([77, 97]), [19, 22, 4])
        XCTAssertEqual(try RFC4648.octetGroupToSextets([77]), [19, 16])
        
        XCTAssertEqual(try RFC4648.decodeBase64("Zm9v"),[UInt8]("foo".utf8))
        
    }
}
