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

    let requestPWDLogin: BehaviorRelay<(String?, String?)?> = BehaviorRelay<(String?, String?)?>(value: nil)

    let onResponse: BehaviorRelay<RequestSMSCodeResult?> = BehaviorRelay<RequestSMSCodeResult?>(value: nil)

    let loginResponse: BehaviorRelay<RequestQuickLoginResult?> = BehaviorRelay<RequestQuickLoginResult?>(value: nil)
    
    let pwdLoginResponse: BehaviorRelay<RequestPWDLoginResult?> = BehaviorRelay<RequestPWDLoginResult?>(value: nil)

    private let disposeBag = DisposeBag()

    weak var sendSMSBtn: UIButton?

    weak var phoneInput: UITextField?
    weak var varifyCodeInput: UITextField?

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
        requestPWDLogin
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] in
                self.handlePWDLoginRequest(inputs: $0)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UITextFieldTextDidChange, object: nil)
            .subscribe(onNext: { [unowned self] notification in

                if let input = self.phoneInput?.text, input.count > 11 {
                    self.phoneInput?.text = String(input.prefix(11))
                }
                if let verifyInput = self.varifyCodeInput?.text, verifyInput.count > 6 {
                    self.varifyCodeInput?.text = String(verifyInput.prefix(6))
                }
            })
            .disposed(by: disposeBag)
        
    }

    convenience init(sendSMSBtn: UIButton, phoneInput: UITextField, varifyCodeInput: UITextField) {
        self.init()
        self.sendSMSBtn = sendSMSBtn
        self.phoneInput = phoneInput
        self.varifyCodeInput = varifyCodeInput

        phoneInput.rx.text
                .filter { $0 != nil }
                .map { [unowned self] (text) in
                    text!.count >= 1 && self.timerDisposable == nil
                }
                .bind(to: sendSMSBtn.rx.isEnabled)
                .disposed(by: disposeBag)
    }

    func requestSMSCode(captcha: String? = nil,
                        phoneNumber: String?) {
        if let phoneNumber = phoneNumber {

            if !phoneNumber.hasPrefix("1") || phoneNumber.count > 11 {
                EnvContext.shared.toast.showToast("手机号错误")
                return
            }
            
            
            if EnvContext.shared.client.reachability.connection == .none
            {
                EnvContext.shared.toast.showToast("网络错误")
                return
            }
            
            getSMSVerifyCodeCommand(
                mobileString: phoneNumber,
                bdCodeType: BDAccountStatusChangedReason.mobileSMSCodeLogin.rawValue)
                .subscribe(onNext: { [unowned self] result in
 
                    if let sendBtn = self.sendSMSBtn {
                        DispatchQueue.main.async {
                            self.blockRequestSendMessage(button: sendBtn)
                        }
                    }
                    self.onResponse.accept(.successed)
                    EnvContext.shared.toast.dismissToast()
                    EnvContext.shared.client.accountConfig.userInfo.accept(TTAccount.shared().user())
                    EnvContext.shared.toast.showToast("短信验证码发送成功")
                    
                }, onError: { [unowned self] error in
                    self.onResponse.accept(.error(error))
                    EnvContext.shared.toast.dismissToast()

                    if let theError = error as? NSError {
                    
                        EnvContext.shared.toast.showToast(theError.errorMessageByErrorCode())
                    }else {
                        EnvContext.shared.toast.showToast("加载失败")

                    }
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

        if !mobile.hasPrefix("1") || mobile.count > 11 {
            EnvContext.shared.toast.showToast("手机号错误")
            return
        }
        
        if EnvContext.shared.client.reachability.connection == .none
        {
            EnvContext.shared.toast.showToast("网络错误")
            return
        }
        
        requestQuickLogin(mobile: mobile, smsCode: smsCode)
                .subscribe(onNext: { [unowned self] void in
                    EnvContext.shared.toast.dismissToast()
                    EnvContext.shared.toast.showToast("登录成功")
                    self.onResponse.accept(.successed)
                    self.loginResponse.accept(.successed)
                    EnvContext.shared.client.accountConfig.setUserPhone(phoneNumber: mobile)
                    EnvContext.shared.client.accountConfig.userInfo.accept(TTAccount.shared().user())
                    AddressBookSync.trySyncAddressBook()
                }, onError: { [unowned self] error in
                    self.loginResponse.accept(.error(error))
                    if let theError = error as? NSError {
                        
                        EnvContext.shared.toast.showToast(theError.errorMessageByErrorCode())
                    }else {
                        EnvContext.shared.toast.showToast("加载失败")
                        
                    }                })
                .disposed(by: disposeBag)
    }
    
    func handlePWDLoginRequest(inputs: (String?, String?)?) {
        if let mobile = inputs?.0, let password = inputs?.1 {
            pwdLogin(mobile: mobile, password: password)
        } else {
            assertionFailure()
        }
    }
    
    func pwdLogin(mobile: String, password: String) {
        
        if !mobile.hasPrefix("1") || mobile.count > 11 {
            EnvContext.shared.toast.showToast("手机号错误")
            return
        }
        requestPassordLogin(mobile: mobile, password: password)
            .subscribe(onNext: { [unowned self] void in
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("登录成功")
                self.onResponse.accept(.successed)
                self.loginResponse.accept(.successed)
                EnvContext.shared.client.accountConfig.setUserPhone(phoneNumber: mobile)
                EnvContext.shared.client.accountConfig.userInfo.accept(TTAccount.shared().user())
                //                    AddressBookSync.trySyncAddressBook()
                }, onError: { [unowned self] error in
                    self.loginResponse.accept(.error(error))
                    EnvContext.shared.toast.showToast("加载失败")
            })
            .disposed(by: disposeBag)
    }
    
    

    func blockRequestSendMessage(button: UIButton) {
        let maxElements = 60
        timerDisposable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .map {
                    maxElements - $0
                }
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
                    QuickLoginVC.setVerifyCodeBtn(content: "重新发送", btn: button)
                    button.isEnabled = true
                    
//                    print("isEnabled")
                    
                } else {
                    button.isEnabled = false
                    QuickLoginVC.setVerifyCodeBtn(
                            content: "重新发送(\(count)s)",
                            color: hexStringToUIColor(hex: kFHCoolGrey2Color),
                            status: .disabled,
                            btn: button)
//                    print("disabled")

                }
            }
        }
    }

    deinit {
//        print("deinit")
    }

}


