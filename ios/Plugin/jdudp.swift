import Foundation

@objc public class jdudp: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
