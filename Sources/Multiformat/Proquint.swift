// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal enum Proquint {
    static let consonants = "bdfghjklmnprstvz".map { $0 }
    static let vowels = "aiou".map { $0 }

    internal static func encode(_ data: Data, separator: Character = "-") throws -> String {
        try [UInt8](data).grouped(2).map(self.wordToProquint).joined(separator: String(separator))
    }

    internal static func decode(_ string: String, separator: Character? = "-") throws -> Data {
        var split: [String]
        if separator == nil {
            split = string.map { $0 }.grouped(5).map { String($0) }
        } else {
            split = string.split(separator: separator!).map { String($0) }
        }

        return try Data(split
            .map(self.pad)
            .map(self.proquintToWord(_:))
            .joined())
    }

    internal static func wordToProquint(_ word: [UInt8]) throws -> String {
        guard word.count <= 2 else {
            throw MultiformatError.invalidGroupSize
        }
        let word = word + [UInt8](repeating: 0, count: 2 - word.count)

        let (c1, r1) = word[0].quotientAndRemainder(dividingBy: pow2(4))
        let (v1, c2u) = r1.quotientAndRemainder(dividingBy: pow2(2))
        let (c2l, r2) = word[1].quotientAndRemainder(dividingBy: pow2(6))
        let (v2, c3) = r2.quotientAndRemainder(dividingBy: pow2(4))
        let c2 = c2u * pow2(2) + c2l

        let rv = [consonants[Int(c1)], vowels[Int(v1)], consonants[Int(c2)], vowels[Int(v2)], consonants[Int(c3)]]

        return rv.reduce("") { $0 + String($1) }
    }

    internal static func proquintToWord(_ string: String) throws -> [UInt8] {
        guard string.count == 5 else {
            throw MultiformatError.invalidFormat
        }

        let I = try string.map { try charIndex($0) }
        let (u, l) = I[2].quotientAndRemainder(dividingBy: pow2(2))

        return [
            I[0] * pow2(4) + I[1] * pow2(2) + u,
            l * pow2(6) + I[3] * pow2(4) + I[4],
        ]
    }

    private static func charIndex(_ c: Character) throws -> UInt8 {
        if let consI = consonants.firstIndex(of: c) {
            return UInt8(consI)
        } else if let vowlI = vowels.firstIndex(of: c) {
            return UInt8(vowlI)
        } else {
            throw MultiformatError.outOfAlphabetCharacter
        }
    }

    private static func pad(_ string: String) throws -> String {
        guard string.count <= 5 else {
            throw MultiformatError.invalidGroupSize
        }
        var rv = string

        for i in string.count ..< 5 {
            if (i % 2) == 0 {
                rv.append(self.consonants[0])
            } else {
                rv.append(self.vowels[0])
            }
        }
        return rv
    }
}
