// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Base58
import Foundation

public enum BasePrefixes: Character, CaseIterable {
    case base32 = "b"
    case base58btc = "z"
}

func multibaseDecode(_ input: String) -> Data? {
    let rest = input[input.index(after: input.startIndex)...]
    print(input[input.startIndex], BasePrefixes.base58btc.rawValue)
    switch input[input.startIndex] {
    case BasePrefixes.base58btc.rawValue:
        return Data(String(rest).base58EncodedStringToBytes())
    default:
        return nil
    }
}

func multibaseEncode(_ data: Data, base: BasePrefixes) -> String? {
    switch base {
    case .base58btc:
        let encoded = [UInt8](data).base58EncodedString()
        guard encoded != nil else {
            return nil
        }
        return String(BasePrefixes.base58btc.rawValue) + encoded!
    default:
        return nil
    }
}
