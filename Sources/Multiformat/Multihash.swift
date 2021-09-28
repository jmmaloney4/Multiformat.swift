// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import VarInt

public enum MultihashError: Error {
    case invalidFormat
    case invalidDigestLength
}

public struct Multihash {
    public let code: CodecPrefix
    public let digest: Data

    public var bytes: Data {
        var data = Data(repeating: 0, count: 0)
        data.append(contentsOf: putUVarInt(self.code.rawValue))
        data.append(contentsOf: putUVarInt(UInt64(self.digest.count)))
        data.append(self.digest)
        return data
    }

    public init(_ data: Data) throws {
        var buffer = [UInt8](data)
        guard buffer.count > 2 else { throw MultihashError.invalidFormat }

        let (c, i) = uVarInt(buffer)
        guard let code = CodecPrefix(rawValue: c) else {
            throw MultihashError.invalidFormat
        }
        buffer = [UInt8](buffer[i...])

        let (l, j) = uVarInt(buffer)
        buffer = [UInt8](buffer[j...])
        let hash = Data(buffer)
        guard hash.count == l else {
            throw MultihashError.invalidDigestLength
        }
        self.init(code: code, hash: hash)
    }

    public init(code: CodecPrefix, hash: Data) {
        self.code = code
        self.digest = hash
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
