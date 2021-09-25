// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BigInt
import Foundation

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

        return Encoding.allCases.filter { $0.rawValue == string[string.startIndex] }.first
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
