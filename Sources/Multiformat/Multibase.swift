// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BigInt
import Foundation

public struct Multibase {
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

//        switch self.encoding {
//        case <#pattern#>:
//            <#code#>
//        default:
//            <#code#>
//        }

        self.data = Data()
    }

    static func identifyEncoding(string: String) -> Encoding? {
        guard string.count > 1 else {
            return nil
        }

        return Encoding.allCases.filter { $0.rawValue == string.first! }.first
    }
}
