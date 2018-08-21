//
// Created by leo on 2018/8/5.
//

import Foundation

extension Utils {
    //当前设备是否是模拟器
    static var isSimulator: Bool = TARGET_OS_SIMULATOR != 0

    static var appName = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
    static var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
//    static var appBeta: String {
//        let beta = appVersion.lf.matchingStrings(regex: "[a-zA-Z]+(\\d+)").first?[1] ?? "0"
//        return beta
//    }
    static var buildVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""

//    static var userAgent: String = {
//        let appVersionStr = appVersion.lf.matchingStrings(regex: "\\d+\\.\\d+\\.\\d+").first?.first ?? "1.0.0"
//        let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
//        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion) like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile Lark/\(appVersionStr)"
//    }()
}
