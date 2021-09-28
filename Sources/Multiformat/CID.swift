// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
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

public struct CID: CustomStringConvertible {
    public enum Version: Int {
        case v0 = 0
        case v1 = 1
    }

    var version: Version
    var codec: CodecPrefix
    var hash: Multihash

    public var description: String {
        switch self.version {
        case .v0:
            return "Qm\(self.hash.digest.base58EncodedString()!)"
        case .v1:
            return ""
        }
    }

    init(_ string: String) throws {
        var data: Data
        if string.count == 46, string.hasPrefix("Qm") {
            data = Data(string.base58EncodedStringToBytes())
        } else {
            let mb = try Multibase(string)
            data = mb.data
        }
        try self.init(data)
    }

    init(_ data: Data) throws {
        if data.count == 34, data.prefix(2) == Data([0x12, 0x20]) {
            // CIDv0
            self.version = .v0
            self.codec = .dag_pb
            self.hash = Multihash(code: .sha2_256, hash: data[data.startIndex.advanced(by: 2)...])
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
            let codec = CodecPrefix(rawValue: codecid)
            guard codec != nil else {
                throw CIDError.unknownMulticodec
            }
            self.codec = codec!
            buf = [UInt8](buf[c2...])

            self.hash = try Multihash(Data(buf))
        }
    }
}
