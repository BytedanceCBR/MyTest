//
// Created by leo on 2018/8/13.
//

import Foundation

class ConsoleEventRecord: TracerRecord {

    func recordEvent(key: String, params: [String : Any]) {
        if #available(iOS 11.0, *) {
            if let data = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted, .sortedKeys]) as Data,
                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print("event: (\(key)) -> \(json)")
            } else {
                assertionFailure("打点数据记录失败")
            }
        } else {
            if let data = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted]) as Data,
                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print("event: (\(key)) -> \(json)")
            } else {
                assertionFailure("打点数据记录失败")
            }
        }
    }

}
