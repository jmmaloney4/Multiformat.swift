// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Crypto
import Foundation
import VarInt

/// A struct representing a Multihash as defined in [multiformats/multihash](https://github.com/multiformats/multihash).
public struct Multihash: Equatable, Hashable, Codable {
    public let code: CodecPrefix
    public let digest: Data

    /// Return the multihash encoded to data.
    public var bytes: Data {
        var data = Data(repeating: 0, count: 0)
        data.append(contentsOf: putUVarInt(self.code.rawValue))
        data.append(contentsOf: putUVarInt(UInt64(self.digest.count)))
        data.append(self.digest)
        return data
    }

    /// Parse the given data as a multihash.
    public init(_ data: Data) throws {
        var buffer = [UInt8](data)
        guard buffer.count > 2 else { throw MultiformatError.invalidFormat }

        let (c, i) = uVarInt(buffer)
        guard let code = CodecPrefix(rawValue: c) else {
            throw MultiformatError.invalidFormat
        }
        buffer = [UInt8](buffer[i...])

        let (l, j) = uVarInt(buffer)
        buffer = [UInt8](buffer[j...])
        let hash = Data(buffer)
        guard hash.count == l else {
            throw MultiformatError.invalidDigestLength
        }
        self.init(code: code, hash: hash)
    }

    /// Directly construct a Multihash with the given multicodec hash function code and digest.
    public init(code: CodecPrefix, hash: Data) {
        self.code = code
        self.digest = hash
    }

    /// Hash the given data with the specified hash function. Currently only `.sha2_256` and `.sha2_512` are supported.
    public init(hashing data: Data, withHash hashfunc: CodecPrefix) throws {
        switch hashfunc {
        case .sha2_256:
            self.init(code: .sha2_256, hash: Data(SHA256.hash(data: data)))
        case .sha2_512:
            self.init(code: .sha2_512, hash: Data(SHA512.hash(data: data)))
        default:
            throw MultiformatError.notImplemented
        }
    }
}
