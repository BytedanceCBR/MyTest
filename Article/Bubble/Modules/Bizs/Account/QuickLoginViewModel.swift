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

    let loginResponse: BehaviorRelay<RequestQuickLoginResult?> = BehaviorRelay<RequestQuickLoginResult?>(value: nil)

    private let disposeBag = DisposeBag()

    weak var sendSMSBtn: UIButton?

    weak var phoneInput: UITextField?

    var timerDisposable: Disposable?

    init() {
        requestSMS
                .filter { $0 != nil && $0!.isEmpty == false }
                .subscribe(onNext: { [unowned self] s in
                    self.requestSMSCode(captcha: nil, phoneNumber: s)
                })
                .disposed(by: disposeBag)

        requestLogin
                .filter { $0 != nil }
                .subscribe(onNext: { [unowned self] in
                    self.handleLoginRequest(inputs: $0)
                })
                .disposed(by: disposeBag)
    }

    convenience init(sendSMSBtn: UIButton, phoneInput: UITextField) {
        self.init()
        self.sendSMSBtn = sendSMSBtn
        self.phoneInput = phoneInput
        phoneInput.rx.text
                .filter { $0 != nil }
                .map { [unowned self] (text) in
                    text!.count >= 11 && self.timerDisposable == nil
                }
                .bind(to: sendSMSBtn.rx.isEnabled)
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

            EnvContext.shared.toast.showLoadingToast("请求短信验证码")
            getSMSVerifyCodeCommand(
                mobileString: phoneNumber,
                bdCodeType: BDAccountStatusChangedReason.mobileSMSCodeLogin.rawValue)
                .debug()
                .subscribe(onNext: { [unowned self] result in
                    EnvContext.shared.toast.dismissToast()
                    self.onResponse.accept(.successed)
                    EnvContext.shared.client.accountConfig.userInfo.accept(BDAccount.shared().user)
                    EnvContext.shared.toast.showToast("短信验证码发送成功")
                }, onError: { [unowned self] error in
                    self.onResponse.accept(.error(error))
                    EnvContext.shared.toast.dismissToast()
                    EnvContext.shared.toast.showToast("短信发送请求失败")
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
        EnvContext.shared.toast.showLoadingToast("正在登录")
        requestQuickLogin(mobile: mobile, smsCode: smsCode)
                .debug()
                .subscribe(onNext: { [unowned self] void in
                    EnvContext.shared.toast.dismissToast()
                    EnvContext.shared.toast.showToast("登录成功")
                    EnvContext.shared.client.accountConfig.userInfo.accept(BDAccount.shared().user)
                    self.onResponse.accept(.successed)
                    self.loginResponse.accept(.successed)
                    EnvContext.shared.client.accountConfig.setUserPhone(phoneNumber: mobile)
                }, onError: { [unowned self] error in
                    self.loginResponse.accept(.error(error))
                    EnvContext.shared.toast.showToast("登录失败")
                })
                .disposed(by: disposeBag)
    }

    func blockRequestSendMessage(button: UIButton) {
        let maxElements = 60
        timerDisposable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .map {
                    maxElements - $0
                }
                .debug("blockRequestSendMessage")
                .bind(onNext: setButtonCountDown(button: button))
        disposeBag.insert(timerDisposable!)
    }

    func setButtonCountDown(button: UIButton) -> (Int) -> Void {
        return { [unowned self, weak button] (count) in
            if count == 0 {
                self.timerDisposable?.dispose()
                self.timerDisposable = nil
            }
            if let button = button {
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
    }

    deinit {
        print("deinit")
    }

}


