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

    weak var sendSMSBtn: UIButton?

//    var sourceObservable: Observable<Int>

    init(){

        requestSMS
                .filter { $0 != nil && $0!.isEmpty == false }
                .subscribe(onNext: curry(self.requestSMSCode)(nil))
                .disposed(by: disposeBag)

        requestLogin
                .filter { $0 != nil }
                .subscribe(onNext: self.handleLoginRequest)
                .disposed(by: disposeBag)
    }

    func requestSMSCode(captcha: String? = nil,
                        phoneNumber: String?) {
        if let phoneNumber = phoneNumber {
            if let sendBtn = sendSMSBtn {
                DispatchQueue.main.async {
                    self.blockRequestSendMessage(button: sendBtn)
                }
            }

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

    func blockRequestSendMessage(button: UIButton) {
        let maxElements = 60
        Observable<Int>
                .create { observer in
                    var value = 1
                    let timer = DispatchSource.makeTimerSource(
                            flags: DispatchSource.TimerFlags(rawValue: UInt(0)),
                            queue: DispatchQueue.main)
                    timer.schedule(deadline: DispatchTime.now(), repeating: 1)
                    timer.setEventHandler {
                        if value <= maxElements {
                            observer.onNext(value)
                            value = value + 1
                        }
                    }
                    timer.resume()
                    return Disposables.create {
                        timer.suspend()
                    }
                }
                .map { maxElements - $0 }
                .debug()
                .bind(onNext: curry(setButtonCountDown)(button))
                .disposed(by: disposeBag)
    }
    
    func setButtonCountDown(button: UIButton, count: Int) {
        if count == 0 {
            QuickLoginVC.setVerifyCodeBtn(content: "获取验证码", btn: button)
            button.isEnabled = true
        } else {
            button.isEnabled = false
            QuickLoginVC.setVerifyCodeBtn(
                content: "重新发送(\(count))S",
                color: hexStringToUIColor(hex: "#999999"),
                status: .disabled,
                btn: button)
        }

    }

}


