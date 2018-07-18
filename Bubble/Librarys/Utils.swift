//
// Created by linlin on 2018/7/18.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

class Utils {
    private init() {

    }
}

extension Utils {
    //拨打电话
    class func telecall(phoneNumber: String) {
        let phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        let callStr = "telprompt://\(phoneNumber)"
        guard let url = URL(string: callStr) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
