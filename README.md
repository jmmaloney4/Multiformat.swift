# Multiformat.swift

![Build](https://github.com/jmmaloney4/Multiformat.swift/actions/workflows/build.yaml/badge.svg)

A Swift implementation of most of the multiformat specifications. 

| Spec                                                      | Status |
|-----------------------------------------------------------|--------|
| [multiaddr](https://github.com/multiformats/multiaddr)    | ❌ |
| [multibase](https://github.com/multiformats/multibase)    | ✅ |
| [multicodec](https://github.com/multiformats/multicodec)  | ✅ |
| [multihash](https://github.com/multiformats/multihash)    | ✅ |
| [multistream](https://github.com/multiformats/multibase)  | ❌ |
| [CID](https://github.com/multiformats/cid)                | ✅ |

# Install

Add the following to your `Package.swift`

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "AwesomeIPFSProject",
  dependencies: [
    .package(url: "https://github.com/jmmaloney4/Multiformat.swift.git", from: "0.1.0")
  ],
  targets: [
    .target(name: "AwesomeIPFSProject", dependencies: ["Multiformat"])
  ]
)
```

# Usage

### CID

```swift
let cid = CID("bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a")
print(cid.version) // .v1
print(cid.codec) // .raw
print(cid.hash.code) // .sha2_256
print(cid.hash.digest)  // Data([203, 11, 180, 190, 173, 250, 237, 102, 74, 18, 240, 220, 170, 110, 157, 192, 31, 252, 194, 31, 60, 154, 226, 27, 28, 146, 93, 87, 75, 136, 126, 216])
                        // Or CB0BB4BEADFAED664A12F0DCAA6E9DC01FFCC21F3C9AE21B1C925D574B887ED8
print(cid.encoded(base: .base32)) // bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a
```

### Multibase

```swift
let data = Data(fromMultibaseEncodedString: "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw==")
// Data([0x4D, 0x75, 0x6C, 0x74, 0x69, 0x62, 0x61, 0x73, 0x65, 0x20, 0x69, 0x73, 0x20, 0x61, 0x77, 0x65, 0x73, 0x6F, 0x6D, 0x65, 0x21, 0x20, 0x5C, 0x6F, 0x2F])
print(data.multibaseEncodedString(.base64pad, prefix: false)) // "TXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw=="
```

### Multihash

```swift
let data = Data(fromMultibaseEncodedString: "da2a4b6ff630c695987abe290c276658fb83d6c4b46fa3313892cd4dd04a8a93", withEncoding: .base16)
let hash = Multihash(code: .sha2_256, data: data)
```

## Update Multicodec Table

```
curl -X GET https://raw.githubusercontent.com/multiformats/multicodec/master/table.csv | ./update_table.py
```

## External Documentation

### RFC 4648

[/ipfs/bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a](https://ipfs.io/ipfs/bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a)

### Proquints

[/ipfs/bafybeib5jsyi5igjwhi7hzkfebpvnq2ykbwpxeaaxlkyfyxqvcecoao4qa](https://ipfs.io/ipfs/bafybeib5jsyi5igjwhi7hzkfebpvnq2ykbwpxeaaxlkyfyxqvcecoao4qa)
