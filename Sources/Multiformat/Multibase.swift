// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BigInt
import Foundation

public enum MultibaseError: Error {
    case notImplemented
}

public struct Multibase: CustomStringConvertible {
    public enum Encoding: Character, CaseIterable {
        case identity = "\0"
        case base2 = "0"
        case base8 = "7"
        case base10 = "9"
        case base16 = "f"
        case base16upper = "F"
        case base32hex = "v"
        case base32hexupper = "V"
        case base32hexpad = "t"
        case base32hexpadupper = "T"
        case base32 = "b"
        case base32upper = "B"
        case base32pad = "c"
        case base32padupper = "C"
        case base32z = "h"
        case base36 = "k"
        case base36upper = "K"
        case base58btc = "z"
        case base58flickr = "Z"
        case base64 = "m"
        case base64pad = "M"
        case base64url = "u"
        case base64urlpad = "U"
        case proquint = "p"
    }

    var encoding: Encoding
    var data: Data

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(try self.stringRepresentation())
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }

    init(_ string: String) throws {
        let encoding = Multibase.identifyEncoding(string: String(string.prefix(1)))
        guard encoding != nil else {
            throw MultiformatError.invalidFormat
        }
        self.encoding = encoding!

        let index = string.index(after: string.startIndex)
        let input = String(string[index...])

        switch self.encoding {
        case .base64, .base64pad:
            self.data = try RFC4648.decode(input, as: .base64)
        case .base64url, .base64urlpad:
            self.data = try RFC4648.decode(input, as: .base64url)
        case .base58btc:
            self.data = Data(input.base58EncodedStringToBytes())
        case .base32, .base32pad:
            self.data = try RFC4648.decode(input.uppercased(), as: .base32)
        case .base32hex, .base32hexpad:
            self.data = try RFC4648.decode(input.uppercased(), as: .base32hex)
        case .base32upper, .base32padupper:
            self.data = try RFC4648.decode(input, as: .base32)
        case .base32hexupper, .base32hexpadupper:
            self.data = try RFC4648.decode(input, as: .base64)
        case .base16:
            self.data = try RFC4648.decode(input, as: .base16)
        case .base16upper:
            self.data = try RFC4648.decode(input, as: .base16upper)
        case .base8:
            self.data = try RFC4648.decode(input, as: .octal)
        case .base2:
            self.data = try RFC4648.decode(input, as: .binary)
        case .identity:
            self.data = Data(input.utf8)
        default: throw MultibaseError.notImplemented
        }
    }

    public var description: String {
        do {
            return try self.stringRepresentation()
        } catch {
            return "<" + error.localizedDescription + ">"
        }
    }

    public func stringRepresentation() throws -> String {
        switch self.encoding {
        case .base64:
            return try RFC4648.encode(self.data, to: .base64, pad: false)
        case .base64pad:
            return try RFC4648.encode(self.data, to: .base64, pad: true)
        case .base64url:
            return try RFC4648.encode(self.data, to: .base64url, pad: false)
        case .base64urlpad:
            return try RFC4648.encode(self.data, to: .base64url, pad: true)
        case .base32:
            return try RFC4648.encode(self.data, to: .base32, pad: false)
        case .base32pad:
            return try RFC4648.encode(self.data, to: .base32, pad: true)
        case .base32upper:
            return try RFC4648.encode(self.data, to: .base32, pad: false).uppercased()
        case .base32padupper:
            return try RFC4648.encode(self.data, to: .base32, pad: true).uppercased()
        case .base32hex:
            return try RFC4648.encode(self.data, to: .base32hex, pad: false)
        case .base32hexpad:
            return try RFC4648.encode(self.data, to: .base32hex, pad: true)
        case .base32hexupper:
            return try RFC4648.encode(self.data, to: .base32hex, pad: false).uppercased()
        case .base32hexpadupper:
            return try RFC4648.encode(self.data, to: .base32hex, pad: true).uppercased()
        case .base16:
            return try RFC4648.encode(self.data, to: .base16, pad: false)
        case .base16upper:
            return try RFC4648.encode(self.data, to: .base16, pad: false).uppercased()
        case .base8:
            return try RFC4648.encode(self.data, to: .octal, pad: false)
        case .base2:
            return try RFC4648.encode(self.data, to: .binary, pad: false)
        default: throw MultibaseError.notImplemented
        }
    }

    static func identifyEncoding(string: String) -> Encoding? {
        guard !string.isEmpty else {
            return nil
        }

        return Encoding.allCases.filter { $0.rawValue == string.first! }.first
    }
}
