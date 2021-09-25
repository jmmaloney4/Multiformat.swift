import Foundation

public extension Array {
    func grouped(_ size: Int) -> [[Element]] {
        var rv = [[Element]]()
        let range = stride(from: 0, to: self.count, by: size)
        for i in range {
            let end = Swift.min(i + size, self.count)
            rv.append(Array(self[i ..< end]))
        }
        return rv
    }
}
