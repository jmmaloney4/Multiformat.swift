// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import VarInt

public enum MultiformatError: Error {
    case notImplemented
    case outOfAlphabetCharacter
    case invalidGroupSize
    case invalidNTet
    case invalidN
    case notCanonicalInput
    case noCorrespondingAlphabetCharacter
    case invalidFormat
    case multibaseDecodeError
    case unknownMulticodec
    case unknownMultihash
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
        do {
            switch self.version {
            case .v0:
                return "\(try self.hash.bytes.multibaseEncodedString(.base58btc, prefix: false))"
            case .v1:
                var data = Data()
                data.append(contentsOf: putUVarInt(UInt64(self.version.rawValue)))
                data.append(contentsOf: putUVarInt(self.codec.rawValue))
                data.append(self.hash.bytes)
                return try data.multibaseEncodedString(.base32)
            }
        } catch {
            return "<\(error)>"
        }
    }

    init(_ string: String) throws {
        var data: Data
        if string.count == 46, string.hasPrefix("Qm") {
            data = try Data(fromMultibaseEncodedString: String(string[string.startIndex...]), withEncoding: .base58btc)
        } else {
            data = try Data(fromMultibaseEncodedString: string)
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
                throw MultiformatError.invalidFormat
            }
            buf = [UInt8](buf[c1...])

            let (codecid, c2) = uVarInt(buf)
            let codec = CodecPrefix(rawValue: codecid)
            guard codec != nil else {
                throw MultiformatError.unknownMulticodec
            }
            self.codec = codec!
            buf = [UInt8](buf[c2...])

            self.hash = try Multihash(Data(buf))
        }
    }

    public func CIDv1() -> CID {
        switch self.version {
        case .v0:
            var rv = self
            rv.version = .v0
            return rv
        case .v1:
            return self
        }
    }
}
