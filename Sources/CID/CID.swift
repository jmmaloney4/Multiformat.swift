// Copyright © 2021 Jack Maloney. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Multihash
import VarInt

public struct CID {
    public enum Version: Int {
        case v0 = 0
        case v1 = 1
    }

    var version: Version
    var codec: UInt64
    var hash: Multihash
}
