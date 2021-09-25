//
//  File.swift
//
//
//  Created by Jack Maloney on 9/24/21.
//

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
            .map { try RFC4648.octetGroupToSextets($0) }
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

    public static func octetGroupToSextets(_ input: [UInt8]) throws -> [UInt8] {
        guard input.count <= 3 else {
            throw RFC4648Error.invalidGroupSize
        }

        if input.isEmpty { return [] }

        var output = [UInt8]()

        let (q0, r0) = input[0].quotientAndRemainder(dividingBy: 4)
        output.append(q0)

        var o1 = r0 * 16
        if input.count == 1 {
            output.append(o1)
            return output
        }
        let (q1, r1) = input[1].quotientAndRemainder(dividingBy: 16)
        o1 += q1
        output.append(o1)

        var o2 = r1 * 4
        if input.count == 2 {
            output.append(o2)
            return output
        }
        let (q2, r2) = input[2].quotientAndRemainder(dividingBy: 64)
        o2 += q2
        output.append(o2)
        output.append(r2)

        return output
    }
    
    public static func octetGroupToNBitGroup(_ input: [UInt8], n: Int) throws -> [UInt8] {
        if input.isEmpty { return [] }
        let l = lcm(n, 8)
        guard input.count <= (l / 8) else {
            throw RFC4648Error.invalidGroupSize
        }

        var output = [UInt8]()
        var offset = 0
        var q: UInt8 = 0, r: UInt8 = 0
        for b in input {
            offset = (offset + n) % 8
            let s = UInt8(8 - offset)
            let carry = r * pow2(s)
            print(offset, s, carry)
            output[output.count - 1] += carry
            (q, r) = b.quotientAndRemainder(dividingBy: pow2(UInt8(8 - offset)))
            output.append(carry + q)
        }

        return output
    }
}

internal func pow2(_ x: UInt8) -> UInt8 {
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
