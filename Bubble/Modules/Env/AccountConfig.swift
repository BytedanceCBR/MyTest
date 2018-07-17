//
// Created by linlin on 2018/7/17.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class AccountConfig {

    let userInfo: BehaviorRelay<BDAccountUser?> = BehaviorRelay<BDAccountUser?>(value: nil)

    init() {

    }

    func loadAccount() {
        userInfo.accept(BDAccount.shared().user)
    }

    static func setupAccountConfig(did: String, iid: String, appId: String) {
        let conf = BDAccountConfiguration.default()
        conf.domain = EnvContext.networkConfig.host
        conf.getDeviceIdBlock = {
            did
        }
        conf.getInstallIdBlock = {
            iid
        }
        conf.ssAppId = appId

        conf.networkParamsHandler = {
            return [:]
        }

        BDAccount.shared().accountConf = conf
    }
}
