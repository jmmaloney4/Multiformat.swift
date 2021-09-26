// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Data {
    func asRFC4648Base64EncodedString(withPadding _: Bool = true) throws -> String {
        return ""
    }
}

public extension String {
    func decodeRFC4648Base64EncodedString() throws -> Data {
        return Data()
    }
}

extension Array where Element: FixedWidthInteger {
    var leadingZeroBitCount: Int {
        if self.count < 1 {
            return 0
        } else if self[0] != 0 {
            return self[0].leadingZeroBitCount
        } else {
            var bits = self.prefix(while: { b in b == 0 }).count * 8
            if let index = self.firstIndex(where: { b in b != 0 }) {
                bits += self[index].leadingZeroBitCount
            }
            return bits
        }
    }
}

enum RFC4648Error: Error {
    case outOfAlphabetCharacter
    case invalidGroupSize
    case invalidSextet
    case notCanonicalInput
    case noCorrespondingAlphabetCharacter
}

internal enum RFC4648 {
    enum Alphabet {
        case base64
        case base64url
        case base32
        case base32hex
    }

    public static let base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".map { $0 }

    public static func encodeToBase64(_ data: Data) throws -> String {
        let sextets = [UInt8](try [UInt8](data)
            .grouped(3)
            .map { try RFC4648.octetsToNBits($0, n: 6) }
            .joined())
        let encoded = try encode(sextets, withAphabet: base64Alphabet)
        let padded = self.addPaddingCharacters(string: encoded, forEncodingWithGroupSize: 4)
        return String(padded)
    }

    static func addPaddingCharacters(string: [Character], paddingCharacter: Character = "=", forEncodingWithGroupSize groupSize: Int) -> [Character] {
        guard let group = string.grouped(groupSize).last else {
            return []
        }
        return string + Array(repeating: paddingCharacter, count: groupSize - group.count)
    }

    static func encode(_ data: [UInt8], withAphabet alphabet: [Character]) throws -> [Character] {
        return try data.map { byte in
            guard byte < alphabet.count else {
                throw RFC4648Error.noCorrespondingAlphabetCharacter
            }
            return alphabet[Int(byte)]
        }
    }

    public static func decodeBase64(_ string: String) throws -> [UInt8] {
        return [UInt8](try RFC4648
            .decodeAlphabet(string, alphabet: RFC4648.base64Alphabet)
            .grouped(4)
            .map { try RFC4648.sextetGroupToOctets($0) }
            .joined())
    }

    static func decodeAlphabet(_ string: String, alphabet: [Character], paddingCharacter: Character = "=", allowOutOfAlphabetCharacters: Bool = false) throws -> [UInt8] {
        if let i = string.firstIndex(of: paddingCharacter), string.suffix(from: i).contains(where: { $0 != paddingCharacter }) {
            throw RFC4648Error.notCanonicalInput
        }
        return try string
            .filter { $0 != paddingCharacter }
            .map { alphabet.firstIndex(of: $0) }
            .filter { i in
                guard i != nil else {
                    if !allowOutOfAlphabetCharacters {
                        throw RFC4648Error.outOfAlphabetCharacter
                    } else {
                        return false
                    }
                }
                return true
            }
            .map { UInt8($0!) }
    }

    /*
     *
     *      +--first octet--+-second octet--+--third octet--+
     *      |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
     *      +-----------+---+-------+-------+---+-----------+
     *      |5 4 3 2 1 0|5 4 3 2 1 0|5 4 3 2 1 0|5 4 3 2 1 0|
     *      +--1.index--+--2.index--+--3.index--+--4.index--+
     *
     */
    public static func sextetGroupToOctets(_ sextets: [UInt8]) throws -> [UInt8] {
        guard sextets.count <= 4 else {
            throw RFC4648Error.invalidGroupSize
        }

        if sextets.isEmpty { return [] }

        guard sextets.count != 1 else {
            throw RFC4648Error.notCanonicalInput
        }

        guard sextets.allSatisfy({ $0 < 64 }) else {
            throw RFC4648Error.invalidSextet
        }

        var output = [UInt8]()

        let (q1, r1) = sextets[1].quotientAndRemainder(dividingBy: 16)
        output.append(sextets[0] * 4 + q1)

        if sextets.count < 3 {
            guard r1 == 0 else {
                throw RFC4648Error.notCanonicalInput
            }
            return output
        }

        let (q2, r2) = sextets[2].quotientAndRemainder(dividingBy: 4)
        output.append(r1 * 16 + q2)

        if sextets.count < 4 {
            guard r2 == 0 else {
                throw RFC4648Error.notCanonicalInput
            }
            return output
        }

        output.append(r2 * 64 + sextets[3])
        return output
    }

    /*
     *  01234567 89012345 67890123 45678901 23456789
     *  +--------+--------+--------+--------+--------+
     *  |< 1 >< 2| >< 3 ><|.4 >< 5.|>< 6 ><.|7 >< 8 >|
     *  +--------+--------+--------+--------+--------+
     */
    public static func quintetsToOctets(_ input: [UInt8]) throws -> [UInt8] {
        if input.isEmpty { return [] }
        let len = input.count
        guard input.count <= 8 else { throw RFC4648Error.invalidGroupSize }
        guard input.allSatisfy({ $0 < pow2(5) }) else { throw RFC4648Error.invalidSextet }
        let input = input + Array(repeating: UInt8(0), count: 8 - input.count)

        var output = [UInt8]()
        let (q1, r1) = input[1].quotientAndRemainder(dividingBy: pow2(2))
        let (q3, r3) = input[3].quotientAndRemainder(dividingBy: pow2(4))
        let (q4, r4) = input[4].quotientAndRemainder(dividingBy: pow2(1))
        let (q6, r6) = input[6].quotientAndRemainder(dividingBy: pow2(3))
        output.append(input[0] * pow2(3) + q1)
        output.append(r1 * pow2(6) + input[2] * pow2(1) + q3)
        output.append(r3 * pow2(4) + q4)
        output.append(r4 * pow2(7) + input[5] * pow2(2) + q6)
        output.append(r6 * pow2(5) + input[7])

        let outSize = ceil(Double(len * 5) / Double(8))
        return [UInt8](output[0 ..< Int(outSize)])
    }

    public static func octetsToNBits(_ input: [UInt8], n: Int = 5) throws -> [UInt8] {
        if input.isEmpty { return [] }
        let len = input.count
        let l = (lcm(8, n) / 8)
        guard input.count <= l else { throw RFC4648Error.invalidGroupSize }

        let input = input + Array(repeating: UInt8(0), count: l - input.count)
        let n = UInt8(n)
        var output = [UInt8]()
        var rhsOffset: UInt8 = n
        var i = 0
        var octet: UInt8 = input[i]
        var carry: UInt8 = 0

        while true {
            let (q, r) = octet.quotientAndRemainder(dividingBy: pow2(8 - rhsOffset))
            output.append(carry * pow2(rhsOffset) + q)
            rhsOffset = rhsOffset + n
            if rhsOffset < 8 {
                octet = r
                carry = 0
            } else {
                i += 1
                if i < input.count {
                    carry = r
                    octet = input[i]
                } else {
                    output.append(r)
                    break
                }
            }
            rhsOffset = rhsOffset % 8
        }

        let outSize = ceil(Double(8 * len) / Double(n))
        return [UInt8](output[0 ..< Int(outSize)])
    }

    public static func nBitsToOctets(_ input: [UInt8], n: Int = 5) throws -> [UInt8] {
        if input.isEmpty { return [] }
        let len = input.count
        let l = (lcm(8, n) / n)
        guard input.count <= l else { throw RFC4648Error.invalidGroupSize }

        let input = input + Array(repeating: UInt8(0), count: l - input.count)
        let n = UInt8(n)
        var output = [UInt8]()
        var rhsOffset: UInt8 = n

        return []
    }
}

@inlinable internal func pow2(_ x: UInt8) -> UInt8 {
    if x == 0 { return 1 }
    return 2 << (x - 1)
}

func gcd(_ a: Int, _ b: Int) -> Int {
    let r = a % b
    if r != 0 {
        return gcd(b, r)
    } else {
        return b
    }
}

func lcm(_ m: Int, _ n: Int) -> Int {
    return m * n / gcd(m, n)
}
