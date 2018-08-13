//
// Created by leo on 2018/8/13.
//

import Foundation

class ConsoleEventRecord: TracerRecord {

    func recordEvent(key: String, params: [String : Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: params, options: []) as Data,
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print("event: (\(key)) -> \(json)")
        } else {
            assertionFailure("打点数据记录失败")
        }
    }

}
