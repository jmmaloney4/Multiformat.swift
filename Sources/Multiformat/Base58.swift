//  SKIP LICENSE INSERTION
//  Code in this file from https://github.com/yeeth/Base58.swift with the following license:
//
//  MIT License
//
//  Copyright (c) 2019
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import BigInt
import Foundation

private let alphabet = [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
private let radix = BigUInt(alphabet.count)

public extension Array where Element == UInt8 {
    func base58EncodedString() -> String {
        Data(self).base58EncodedString()
    }
}

public extension Data {
    func base58EncodedString() -> String {
        var bytes = [UInt8]()
        var integer = BigUInt(self)
        while integer > 0 {
            let (quotient, remainder) = integer.quotientAndRemainder(dividingBy: radix)
            bytes.insert(alphabet[Int(remainder)], at: 0)
            integer = quotient
        }

        bytes.insert(contentsOf: Array(prefix { $0 == 0 }).map { _ in alphabet[0] }, at: 0)
        // Given that the alphabet characters are all utf8 characters, we
        // should have no problem encoding this string.
        return String(bytes: bytes, encoding: .utf8)!
    }
}

public extension String {
    // @todo should this be done with the decode/encode generic function?
    // @todo better naming?
    func base58EncodedData() throws -> Data {
        var answer = BigUInt(0)
        var i = BigUInt(1)

        for char in utf8.reversed() {
            guard let index = alphabet.firstIndex(of: char) else {
                throw MultibaseError.outOfAlphabetCharacter
            }

            answer += (i * BigUInt(index))
            i *= radix
        }

        return Data(Array(utf8.prefix { i in i == alphabet[0] } + answer.serialize()))
    }
}
