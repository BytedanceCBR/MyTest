//
// Created by linlin on 2018/7/16.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class QuickLoginViewModel {

    let requestSMS: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    let requestLogin: BehaviorRelay<(String?, String?)?> = BehaviorRelay<(String?, String?)?>(value: nil)

    let onResponse: BehaviorRelay<RequestSMSCodeResult?> = BehaviorRelay<RequestSMSCodeResult?>(value: nil)

    private let disposeBag = DisposeBag()

    init(){
        requestSMS
                .filter { $0 != nil && $0!.isEmpty == false }
                .subscribe(onNext: curry(requestSMSCode)(nil))
                .disposed(by: disposeBag)

        requestLogin
                .filter { $0 != nil }
                .subscribe(onNext: handleLoginRequest)
                .disposed(by: disposeBag)
    }

    func requestSMSCode(captcha: String? = nil,
                        phoneNumber: String?) {
        if let phoneNumber = phoneNumber {
            getSMSVerifyCodeCommand(
                mobileString: phoneNumber,
                bdCodeType: BDAccountStatusChangedReason.mobileSMSCodeLogin.rawValue)
                .debug()
                .subscribe(onNext: { [unowned self] result in
                    self.onResponse.accept(.successed)
                    EnvContext.shared.client.accountConfig.userInfo.accept(BDAccount.shared().user)
                }, onError: { error in
                    self.onResponse.accept(.error(error))
                })
                .disposed(by: disposeBag)
        } else {
            assertionFailure()
        }
    }

    func handleLoginRequest(inputs: (String?, String?)?) {
        if let mobile = inputs?.0, let smsCode = inputs?.1 {
            quickLogin(mobile: mobile, smsCode: smsCode)
        } else {
            assertionFailure()
        }
    }

    func quickLogin(mobile: String, smsCode: String) {
        requestQuickLogin(mobile: mobile, smsCode: smsCode)
                .debug()
                .subscribe(onNext: { [unowned self] void in
                    EnvContext.shared.client.accountConfig.userInfo.accept(BDAccount.shared().user)
                    self.onResponse.accept(.successed)
                }, onError: { error in

                })
                .disposed(by: disposeBag)
    }

}


