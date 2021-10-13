// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Crypto
import CryptoKit
import Foundation

public extension Multihash {
    init(digest: SHA256.Digest) {
        self.code = .sha2_256
        self.digest = Data(digest)
    }

    init(digest: SHA512.Digest) {
        self.code = .sha2_512
        self.digest = Data(digest)
    }

    init<T: Digest>(digest: T, type: CodecPrefix) {
        self.code = type
        self.digest = Data(digest)
    }
}

public extension SHA256.Digest {
    func CIDv1(codec: CodecPrefix = .raw) -> CID {
        CID(version: .v1, codec: codec, hash: Multihash(digest: self))
    }
}

public extension SHA512.Digest {
    func CIDv1(codec: CodecPrefix = .raw) -> CID {
        CID(version: .v1, codec: codec, hash: Multihash(digest: self))
    }
}
