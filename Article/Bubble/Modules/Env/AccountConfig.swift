//
// Created by linlin on 2018/7/17.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountConfig: NSObject {

    let userInfo: BehaviorRelay<TTAccountUserEntity?> = BehaviorRelay<TTAccountUserEntity?>(value: nil)

    private let KEY_USER_PHONE = "user_phone_key"

    override init() {
        super.init()
        TTAccountMulticast.sharedInstance().registerDelegate(self)
    }

    func loadAccount() {
        userInfo.accept(TTAccount.shared().user())
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
    
    func setUserPhone(phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: KEY_USER_PHONE)
        UserDefaults.standard.synchronize()
    }

    func getUserPhone() -> String? {
        return UserDefaults.standard.string(forKey: KEY_USER_PHONE)
    }
}

extension AccountConfig: TTAccountMulticastProtocol {
    
    func onAccountLogin() {
        userInfo.accept(TTAccount.shared().user())
    }

    func onAccountLogout() {
        userInfo.accept(nil)
    }
}
