// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BigInt

public struct Multibase {
    public enum Encoding: Character, CaseIterable {
        case base32 = "b"
        case base58btc = "z"
    }
    
    var encoding: Encoding
    var data: Data
    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//
//    }
//
//    public init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        try container.decode(String.self)
//
//    }
    
    init(_ string: String) throws {
        let encoding = Multibase.identifyEncoding(string: string)
        guard encoding != nil else {
            throw MultiformatError.invalidFormat
        }
        self.encoding = encoding!
        self.data = Data()
    }
    
    static func identifyEncoding(string: String) -> Encoding? {
        guard string.count > 1 else {
            return nil
        }
        
        return Encoding.allCases.filter({ $0.rawValue == string[string.startIndex] }).first
    }
}


func multibaseDecode(_ input: String) -> Data? {
    let rest = input[input.index(after: input.startIndex)...]
    print(input[input.startIndex], Multibase.Encoding.base58btc.rawValue)
    switch input[input.startIndex] {
    case Multibase.Encoding.base58btc.rawValue:
        return Data(String(rest).base58EncodedStringToBytes())
    default:
        return nil
    }
}

func multibaseEncode(_ data: Data, base: Multibase.Encoding) -> String? {
    switch base {
    case .base58btc:
        let encoded = [UInt8](data).base58EncodedString()
        guard encoded != nil else {
            return nil
        }
        return String(Multibase.Encoding.base58btc.rawValue) + encoded!
    default:
        return nil
    }
}

public class BaseN {
    var alphabet: [UInt8]
    var radix: BigUInt {
        return BigUInt(alphabet.count)
    }
    var bitsPerDigit: Double {
        return log2(Double(radix))
    }
    var zero: UInt8 {
        return alphabet[0]
    }
    
    public static let binary = BaseN("01")
    public static let octal = BaseN("01234567")
    public static let hex = BaseN("0123456789ABCDEF")
    public static let base32 = BaseN("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
    public static let base58 = BaseN("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    public static let base64 = BaseN("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

    public init(_ alphabet: String) {
        self.alphabet = [UInt8](alphabet.utf8)
    }
    
    public init(_ alphabet: [UInt8]) {
        self.alphabet = alphabet
    }
    
    public func toData(_ str: String) throws -> Data {
        var i = BigUInt(1)
        var value = BigUInt(0)
        for c in str.reversed() {
            guard c.isASCII, let index = alphabet.firstIndex(of: c.asciiValue!) else {
                throw MultiformatError.notInAlphabet
            }
            value += (i * BigUInt(index))
            i *= radix
        }
        
        let buf = [UInt8](value.serialize())
        let lz = str.prefix(while: {c in c.isASCII && c.asciiValue! == zero}).count
        
        var pads = 0
        while Double(buf.leadingZeroBitCount + (pads * 8)) < Double(lz) * self.bitsPerDigit {
            pads += 1
        }
        
        return Data(Array(repeating: 0, count: pads) + buf)
    }
    
    public func fromData(_ data: Data) throws -> String? {
        var bytes = [UInt8]()
        var integer = BigUInt(data)
        
        while integer > 0 {
            let (quotient, remainder) = integer.quotientAndRemainder(dividingBy: radix)
            bytes.insert(alphabet[Int(remainder)], at: 0)
            integer = quotient
        }
        
        // bitsPerDigit * Digits > LeadingBits iff digits > LZB / bpd
//        print([UInt8](data))
//        print(Double([UInt8](data).leadingZeroBitCount))
//        print(Double([UInt8](data).leadingZeroBitCount) / Double(self.bitsPerDigit))
        let pads = ceil(Double([UInt8](data).leadingZeroBitCount) / Double(self.bitsPerDigit))
        
        let rv = String(bytes: bytes, encoding: .utf8)
        if rv == nil {
            return nil
        } else {
            return String(repeating: Character(Unicode.Scalar(zero)), count: Int(pads)) + rv!
        }
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
}

public class RFC4648 {
    enum Alphabet {
        case base64
        case base64url
        case base32
        case base32hex
    }
    
    public static let base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".map({$0})

    public static func decodeBase64(_ string: String) throws -> [UInt8] {
        return try [UInt8](try RFC4648
                            .decodeAlphabet(string, alphabet: RFC4648.base64Alphabet)
                            .groups(of: 4)
                            .map({ try RFC4648.sextetGroupToOctets($0) })
                            .joined())
    }
    
    static func decodeAlphabet(_ string: String, alphabet: [Character], paddingCharacter: Character = "=", allowOutOfAlphabetCharacters:Bool = false) throws -> [UInt8] {
        if string.suffix(from: string.firstIndex(of: paddingCharacter)).contains(where: { $0 != paddingCharacter }) {
            throw RFC4648Error.notCanonicalInput
        }
        return try string
            .filter({ $0 != paddingCharacter })
            .map({ return alphabet.firstIndex(of: $0) })
            .filter({ i in
                guard i != nil else {
                    if !allowOutOfAlphabetCharacters {
                        throw RFC4648Error.outOfAlphabetCharacter
                    } else {
                        return false
                    }
                }
                return true
            })
            .map({ UInt8($0!) })
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
        
        if sextets.count == 0 { return [] }
        
        guard sextets.count != 1 else {
            throw RFC4648Error.notCanonicalInput
        }
        
        guard sextets.allSatisfy({ $0 < 64 }) else {
            throw RFC4648Error.invalidSextet
        }
        
        var output = Array<UInt8>()
        
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
        
        if input.count == 0 { return [] }
        
        var output = Array<UInt8>()
        
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
}

extension Array {
    public func groups(of size: Int) -> [Array<Element>] {
        var rv = Array<Array<Element>>()
        let range = stride(from: 0, to: self.count, by: size)
        for i in range {
            let end = Swift.min(i+size, self.count)
            rv.append(Array(self[i..<end]))
        }
        return rv
    }
}
