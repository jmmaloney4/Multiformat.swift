// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal enum RFC4648 {
    internal enum Alphabet: String {
        case binary = "01"
        case octal = "01234567"
        case base16 = "0123456789abcdef"
        case base16upper = "0123456789ABCDEF"
        case base32 = "abcdefghijklmnopqrstuvwxyz234567"
        case base32hex = "0123456789abcdefghijklmnopqrstuv"
        case base32upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        case base32hexupper = "0123456789ABCDEFGHIJKLMNOPQRSTUV"
        case base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        case base64url = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

        func asChars() -> [Character] {
            self.rawValue.map { $0 }
        }

        func bitsPerCharacter() -> Int {
            Int(truncating: NSNumber(value: log2(Double(self.asChars().count))))
        }
    }

    internal static func encode(_ data: Data, to alphabet: Alphabet, pad: Bool = true) throws -> String {
        let n = alphabet.bitsPerCharacter()
        let l = lcm(8, n)
        // Input Group Size
        let ig = l / 8
        // Output Group Size
        let og = l / n
        let ntets = [UInt8](try [UInt8](data)
            .grouped(ig)
            .map { try RFC4648.octetGroupToNTets($0, n: n) }
            .joined())
        var rv = try encode(ntets, withAphabet: alphabet.asChars())
        if pad {
            rv = self.addPaddingCharacters(string: rv, forEncodingWithGroupSize: og)
        }
        return String(rv)
    }

    internal static func decode(_ string: String, as alphabet: Alphabet) throws -> Data {
        let n = alphabet.bitsPerCharacter()
        let l = lcm(8, n)
        // Input Group Size
        let ig = l / n
        let octets = [UInt8](try RFC4648
            .decodeAlphabet(string, alphabet: alphabet.asChars())
            .grouped(ig)
            .map { try RFC4648.nTetGroupToOctets($0, n: n) }
            .joined())
        return Data(octets)
    }

    // MARK: Internal Code

    internal static func addPaddingCharacters(string: [Character], paddingCharacter: Character = "=", forEncodingWithGroupSize groupSize: Int) -> [Character] {
        guard let group = string.grouped(groupSize).last else {
            return []
        }
        return string + Array(repeating: paddingCharacter, count: groupSize - group.count)
    }

    internal static func encode(_ data: [UInt8], withAphabet alphabet: [Character]) throws -> [Character] {
        try data.map { byte in
            guard byte < alphabet.count else {
                throw MultiformatError.noCorrespondingAlphabetCharacter
            }
            return alphabet[Int(byte)]
        }
    }

    internal static func decodeAlphabet(_ string: String, alphabet: [Character], paddingCharacter: Character = "=", allowOutOfAlphabetCharacters: Bool = false) throws -> [UInt8] {
        if let i = string.firstIndex(of: paddingCharacter), string.suffix(from: i).contains(where: { $0 != paddingCharacter }) {
            throw MultiformatError.notCanonicalInput
        }
        return try string
            .filter { $0 != paddingCharacter }
            .map { alphabet.firstIndex(of: $0) }
            .filter { i in
                guard i != nil else {
                    if !allowOutOfAlphabetCharacters {
                        throw MultiformatError.outOfAlphabetCharacter
                    } else {
                        return false
                    }
                }
                return true
            }
            .map { UInt8($0!) }
    }

    /*
     *  Base 64:
     *
     *      +--first octet--+-second octet--+--third octet--+
     *      |7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|7 6 5 4 3 2 1 0|
     *      +-----------+---+-------+-------+---+-----------+
     *      |5 4 3 2 1 0|5 4 3 2 1 0|5 4 3 2 1 0|5 4 3 2 1 0|
     *      +--1.index--+--2.index--+--3.index--+--4.index--+
     *
     *  Base 32:
     *
     *      01234567 89012345 67890123 45678901 23456789
     *      +--------+--------+--------+--------+--------+
     *      |< 1 >< 2| >< 3 ><|.4 >< 5.|>< 6 ><.|7 >< 8 >|
     *      +--------+--------+--------+--------+--------+
     *
     *  Base 2:
     *      012345678
     *
     */
    internal static func octetGroupToNTets(_ input: [UInt8], n: Int) throws -> [UInt8] {
        guard n > 0, n <= 8 else { throw MultiformatError.invalidN }
        if input.isEmpty { return [] }
        let len = input.count
        let l = (lcm(8, n) / 8)
        guard input.count <= l else { throw MultiformatError.invalidGroupSize }

        let input = input + Array(repeating: UInt8(0), count: l - input.count)
        let n = UInt8(n)
        var output = [UInt8]()
        var offset: UInt8 = n
        var i = 0
        var octet: UInt8 = input[i]
        var carry: UInt8 = 0

        while true {
            let (q, r) = octet.quotientAndRemainder(dividingBy: pow2(8 - offset))
            output.append(carry * pow2(offset) + q)
            offset = offset + n
            if offset < 8 {
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
            offset = offset % 8
        }

        let outSize = ceil(Double(8 * len) / Double(n))
        return [UInt8](output[0 ..< Int(outSize)])
    }

    internal static func nTetGroupToOctets(_ input: [UInt8], n: Int) throws -> [UInt8] {
        // Check for basic failure modes
        guard n > 0, n <= 8 else { throw MultiformatError.invalidN }
        if input.isEmpty { return [] }
        let m = (lcm(8, n) / n)
        guard input.count <= m else { throw MultiformatError.invalidGroupSize }

        // Pad out input with zeros
        let l = input.count
        let input = input + Array(repeating: UInt8(0), count: l - input.count)

        let n = UInt8(n)
        // Index into output array
        var j: Int = 0
        var output = [UInt8](repeating: 0, count: lcm(8, Int(n)) / 8)
        // Offset Mod 8
        var offset: UInt8 = 0
        // Quotient and Remainder
        var q: UInt8 = 0, r: UInt8 = 0

        for i in input {
            if i >= pow2(n) { throw MultiformatError.invalidNTet }

            // Handle carry. Take the least significant part of the n-tet (r) and
            // move it to the most significant part of the next output byte.
            output[j] += r * pow2(8 - offset)
            // We have handled the remainder now.
            r = 0

            offset += n
            if offset < 8 {
                // We have not crossed a byte boundary, so the entire input n-tet is in the current output byte.
                output[j] += i * pow2(8 - offset)
            } else {
                // We have crossed a byte boundary, we need to split the most and least significant halves of the input n-tet
                (q, r) = i.quotientAndRemainder(dividingBy: pow2(offset - 8))
                output[j] += q
                j += 1
            }

            offset = offset % 8
        }

        let outSize = Int(floor(Double(l * Int(n)) / Double(8)))

        guard r == 0, output[outSize...].allSatisfy({ $0 == 0 }) else {
            throw MultiformatError.notCanonicalInput
        }

        return [UInt8](output[0 ..< outSize])
    }
}

// MARK: Utility Functions

internal func pow2(_ x: UInt8) -> UInt8 {
    if x == 0 { return 1 }
    return 2 << (x - 1)
}

private func gcd(_ a: Int, _ b: Int) -> Int {
    let r = a % b
    if r != 0 {
        return gcd(b, r)
    } else {
        return b
    }
}

private func lcm(_ m: Int, _ n: Int) -> Int {
    m * n / gcd(m, n)
}

internal extension Array {
    func grouped(_ size: Int) -> [[Element]] {
        var rv = [[Element]]()
        let range = stride(from: 0, to: self.count, by: size)
        for i in range {
            let end = Swift.min(i + size, self.count)
            rv.append(Array(self[i ..< end]))
        }
        return rv
    }
}
