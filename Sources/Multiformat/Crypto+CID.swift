// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Crypto
import Foundation

public extension Multihash {
    ///  Initialize a Multihash from a SHA256 digest.
    init(digest: SHA256.Digest) {
        self.code = .sha2_256
        self.digest = Data(digest)
    }

    ///  Initialize a Multihash from a SHA512 digest.
    init(digest: SHA512.Digest) {
        self.code = .sha2_512
        self.digest = Data(digest)
    }

    ///  Initialize a Multihash from a generic Digest implementation.
    ///  You must specify the multicodec ID for the hash function used to compute the digest.
    init<T: Digest>(digest: T, type: CodecPrefix) {
        self.code = type
        self.digest = Data(digest)
    }
}

public extension SHA256.Digest {
    /// Convert this hash to a CIDv1 with the specified multicodec. The default multicodec is `.raw`.
    func CIDv1(codec: CodecPrefix = .raw) -> CID {
        CID(version: .v1, codec: codec, hash: Multihash(digest: self))
    }

    /// Convert this hash to a CIDv0. All CIDv0 have multicodec `.dag_pb`.
    func CIDv0() -> CID {
        CID(version: .v0, codec: .dag_pb, hash: Multihash(digest: self))
    }
}

public extension SHA512.Digest {
    /// Convert this hash to a CIDv1 with the specified multicodec. The default multicodec is `.raw`.
    func CIDv1(codec: CodecPrefix = .raw) -> CID {
        CID(version: .v1, codec: codec, hash: Multihash(digest: self))
    }
}
