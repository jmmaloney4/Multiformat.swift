# CID.swift

```swift
let cid = CID("bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a")
print(cid.version) // .v1
print(cid.codec) // .raw
print(cid.hash.code) // .sha2_256
print(cid.hash.digest)  // Data([203, 11, 180, 190, 173, 250, 237, 102, 74, 18, 240, 220, 170, 110, 157, 192, 31, 252, 194, 31, 60, 154, 226, 27, 28, 146, 93, 87, 75, 136, 126, 216])
                        // Or CB0BB4BEADFAED664A12F0DCAA6E9DC01FFCC21F3C9AE21B1C925D574B887ED8
```

## Multibase

```swift
let data = Data(fromMultibaseEncodedString: "MTXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw==")
// Data([0x4D, 0x75, 0x6C, 0x74, 0x69, 0x62, 0x61, 0x73, 0x65, 0x20, 0x69, 0x73, 0x20, 0x61, 0x77, 0x65, 0x73, 0x6F, 0x6D, 0x65, 0x21, 0x20, 0x5C, 0x6F, 0x2F])
print(data.multibaseEncodedString(.base64pad, prefix: false)) // "TXVsdGliYXNlIGlzIGF3ZXNvbWUhIFxvLw=="
```

## Update Multicodec Table

```
curl -X GET https://raw.githubusercontent.com/multiformats/multicodec/master/table.csv | ./update_table.py
```

## Documentation

### RFC 4648

[/ipfs/bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a](https://ipfs.io/ipfs/bafkreiglbo2l5lp25vteuexq3svg5hoad76mehz4tlrbwheslvluxcd63a)

### Proquints

[/ipfs/bafybeib5jsyi5igjwhi7hzkfebpvnq2ykbwpxeaaxlkyfyxqvcecoao4qa](https://ipfs.io/ipfs/bafybeib5jsyi5igjwhi7hzkfebpvnq2ykbwpxeaaxlkyfyxqvcecoao4qa)