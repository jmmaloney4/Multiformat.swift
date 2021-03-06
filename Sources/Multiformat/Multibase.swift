// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Data {
    /// Decodes the given string based on its multibase prefix.
    init(fromMultibaseEncodedString string: String) throws {
        self.init(try Multibase.decode(string))
    }

    /// Decodes the given string as the given encoding. String should not have a multibase prefix character.
    init(fromMultibaseEncodedString string: String, withEncoding encoding: Multibase.Encoding) throws {
        self.init(try Multibase.decode(string, withEncoding: encoding))
    }

    /// Encode the data as a multibase string with the given encoding. If prefix is false, do not prefix it with a multibase code character.
    func multibaseEncodedString(_ encoding: Multibase.Encoding, prefix: Bool = true) throws -> String {
        try Multibase.encode(self, withEncoding: encoding, prefix: prefix)
    }
}

public enum Multibase {
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

    /// Identify the encoding of the given string based on the multibase prefix character.
    public static func identifyEncoding(string: String) -> Encoding? {
        guard !string.isEmpty else {
            return nil
        }

        return Encoding.allCases.filter { $0.rawValue == string.first! }.first
    }

    internal static func decode(_ string: String) throws -> Data {
        let encoding = Multibase.identifyEncoding(string: String(string.prefix(1)))
        guard encoding != nil else {
            throw MultiformatError.invalidFormat
        }

        let index = string.index(after: string.startIndex)
        let input = String(string[index...])

        return try Multibase.decode(input, withEncoding: encoding!)
    }

    internal static func decode(_ input: String, withEncoding encoding: Encoding) throws -> Data {
        switch encoding {
        case .base64, .base64pad:
            return try RFC4648.decode(input, as: .base64)
        case .base64url, .base64urlpad:
            return try RFC4648.decode(input, as: .base64url)
        case .base58btc:
            return try input.base58EncodedData()
        case .base32, .base32pad:
            return try RFC4648.decode(input, as: .base32)
        case .base32hex, .base32hexpad:
            return try RFC4648.decode(input, as: .base32hex)
        case .base32upper, .base32padupper:
            return try RFC4648.decode(input, as: .base32)
        case .base32hexupper, .base32hexpadupper:
            return try RFC4648.decode(input, as: .base64)
        case .base16:
            return try RFC4648.decode(input, as: .base16)
        case .base16upper:
            return try RFC4648.decode(input, as: .base16upper)
        case .base8:
            return try RFC4648.decode(input, as: .octal)
        case .base2:
            return try RFC4648.decode(input, as: .binary)
        case .identity:
            return Data(input.utf8)
        case .proquint:
            return try Proquint.decode(self.stripProquintPrefix(input))
        default: throw MultiformatError.notImplemented
        }
    }

    internal static func encode(_ data: Data, withEncoding encoding: Encoding, prefix: Bool = true) throws -> String {
        var rv: String
        switch encoding {
        case .base64:
            rv = try RFC4648.encode(data, to: .base64, pad: false)
        case .base64pad:
            rv = try RFC4648.encode(data, to: .base64, pad: true)
        case .base64url:
            rv = try RFC4648.encode(data, to: .base64url, pad: false)
        case .base64urlpad:
            rv = try RFC4648.encode(data, to: .base64url, pad: true)
        case .base58btc:
            rv = data.base58EncodedString()
        case .base32:
            rv = try RFC4648.encode(data, to: .base32, pad: false)
        case .base32pad:
            rv = try RFC4648.encode(data, to: .base32, pad: true)
        case .base32upper:
            rv = try RFC4648.encode(data, to: .base32, pad: false).uppercased()
        case .base32padupper:
            rv = try RFC4648.encode(data, to: .base32, pad: true).uppercased()
        case .base32hex:
            rv = try RFC4648.encode(data, to: .base32hex, pad: false)
        case .base32hexpad:
            rv = try RFC4648.encode(data, to: .base32hex, pad: true)
        case .base32hexupper:
            rv = try RFC4648.encode(data, to: .base32hex, pad: false).uppercased()
        case .base32hexpadupper:
            rv = try RFC4648.encode(data, to: .base32hex, pad: true).uppercased()
        case .base16:
            rv = try RFC4648.encode(data, to: .base16, pad: false)
        case .base16upper:
            rv = try RFC4648.encode(data, to: .base16, pad: false).uppercased()
        case .base8:
            rv = try RFC4648.encode(data, to: .octal, pad: false)
        case .base2:
            rv = try RFC4648.encode(data, to: .binary, pad: false)
        case .identity:
            guard let s = String(data: data, encoding: .utf8) else {
                throw MultiformatError.invalidFormat
            }
            rv = s
        default: throw MultiformatError.notImplemented
        }
        if prefix {
            rv = String(encoding.rawValue) + rv
        }
        return rv
    }

    private static func stripProquintPrefix(_ string: String) -> String {
        var rv = string
        if string.hasPrefix("pro-") {
            rv.removeFirst(4)
        } else if string.hasPrefix("ro-") {
            rv.removeFirst(3)
        }
        return rv
    }

    private static func addProquintPrefix(_ string: String) -> String {
        "pro-" + string
    }
}
