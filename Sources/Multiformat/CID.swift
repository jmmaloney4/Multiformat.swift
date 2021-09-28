// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Base58
import Foundation
import Multihash
import VarInt

enum CIDError: Error {
    case multibaseDecodeError
    case invalidFormat
    case unknownMulticodec
    case unknownMultihash
}

enum MultiformatError: Error {
    // Multibase Errors
    case invalidFormat
    case notInAlphabet
}

public struct CID {
    public enum Version: Int {
        case v0 = 0
        case v1 = 1
    }

    var version: Version
    var codec: CodecPrefixes
    var hash: Multihash

    init?(_ string: String) throws {
        var data: Data?
        if string.count == 46, string.hasPrefix("Qm") {
            data = Data(string.base58EncodedStringToBytes())
        } else {
            let mb = try Multibase(string)
            data = mb.data
        }
        guard data != nil else {
            throw CIDError.multibaseDecodeError
        }
        try self.init(data!)
    }

    init?(_ data: Data) throws {
        if data.count == 34, data.prefix(2) == Data([0x12, 0x20]) {
            // CIDv0
            self.version = .v0
            self.codec = .dag_pb
            self.hash = Multihash(code: .sha2256, hash: data[data.startIndex.advanced(by: 2)...])
        } else {
            // CIDv1
            self.version = .v1

            // Decode CID version
            var buf = [UInt8](data)
            let (cidv, c1) = uVarInt(buf)
            guard cidv == self.version.rawValue else {
                throw CIDError.invalidFormat
            }
            buf = [UInt8](buf[c1...])

            let (codecid, c2) = uVarInt(buf)
            let codec = CodecPrefixes(rawValue: codecid)
            guard codec != nil else {
                throw CIDError.unknownMulticodec
            }
            self.codec = codec!
            buf = [UInt8](buf[c2...])

            let (hashTypeCode, c3) = uVarInt(buf)
            buf = [UInt8](buf[c3...])
            let hashType = Type(rawValue: UInt8(hashTypeCode))
            guard hashType != nil else {
                throw CIDError.unknownMultihash
            }
            self.hash = Multihash(code: hashType!, hash: Data(buf))
        }
    }
}
