// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BigInt
import Foundation

private let alphabet = [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
private let radix = BigUInt(alphabet.count)

public extension Array where Element == UInt8 {
    func base58EncodedString() -> String? {
        var bytes = [UInt8]()

        var integer = BigUInt(Data(self))

        while integer > 0 {
            let (quotient, remainder) = integer.quotientAndRemainder(dividingBy: radix)
            bytes.insert(alphabet[Int(remainder)], at: 0)
            integer = quotient
        }

        bytes.insert(contentsOf: Array(prefix { $0 == 0 }).map { _ in alphabet[0] }, at: 0)
        return String(bytes: bytes, encoding: .utf8)
    }
}

public extension String {
    // @todo should this be done with the decode/encode generic function?
    // @todo better naming?
    func base58EncodedStringToBytes() -> [UInt8] {
        var answer = BigUInt(0)
        var i = BigUInt(1)

        for char in utf8.reversed() {
            guard let index = alphabet.firstIndex(of: char) else {
                return []
            }

            answer += (i * BigUInt(index))
            i *= radix
        }

        return Array(utf8.prefix { i in i == alphabet[0] } + answer.serialize())
    }
}
