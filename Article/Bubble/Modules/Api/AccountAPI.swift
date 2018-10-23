//
//  AccountAPI.swift
//  Bubble
//
//  Created by linlin on 2018/7/17.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift

func requestQuickLogin(mobile: String, smsCode: String) -> Observable<Void> {
    return Observable.create { (observer) in
        
        if  mobile.count != 11 || !isPureInt(string: mobile)
        {
            EnvContext.shared.toast.showToast("手机号错误")
            return Disposables.create()
        }
        
//        if  smsCode.count != 4 || !isPureInt(string: smsCode)
//        {
//            EnvContext.shared.toast.showToast("验证码错误")
//            return Disposables.create()
//        }
        
        TTAccountManager.startQuickLogin(withPhoneNumber: mobile, code: smsCode, captcha: nil, completion: { (image, number, error) in
            if let error = error {
                observer.onError(error)
            } else {
                observer.onNext(())
                observer.onCompleted()
            }
        })
        /*
        BDAccount.requestQuickLogin(withMobile: mobile, smsCode: smsCode) { error in
            if let error = error {
                observer.onError(error)
            } else {
                observer.onNext(())
                observer.onCompleted()
            }
        }
        */
        return Disposables.create()
    }
}

func requestPassordLogin(mobile: String, password: String) -> Observable<Void> {
    return Observable.create { (observer) in
        TTAccountManager.startLogin(withPhoneNumber: mobile, password: password, captcha: nil, completion: { (image, error) in
            if let error = error {
                observer.onError(error)
            } else {
                observer.onNext(())
                observer.onCompleted()
            }
        })

//        BDAccount.requestPWDLogin(withMobile: mobile, password: password, completion: { error in
//            if let error = error {
//                observer.onError(error)
//            } else {
//                observer.onNext(())
//                observer.onCompleted()
//            }
//        })

        return Disposables.create()
    }
}


enum RequestSMSCodeResult {
    case needCaptchaCode(UIImage)
    case error(Error?)
    case successed
}

enum RequestQuickLoginResult {
    case needCaptchaCode(UIImage)
    case error(Error?)
    case successed
}
enum RequestPWDLoginResult {
    case needCaptchaCode(UIImage)
    case error(Error?)
    case successed
}

func getSMSVerifyCodeCommand(mobileString: String, bdCodeType: Int) -> Observable<RequestSMSCodeResult> {
//    let dataDelegate = GetSMSCodeDataDelegate(mobileNumber: mobileString, bdCodeType: bdCodeType)
    let delegate = AccountViewDelegate()
    return Observable.create { (observer) in
        delegate.onResponse = { (result) in
            switch result {
            case let .error(error):
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onCompleted()
                }
            case .needCaptchaCode:
                observer.onNext(result)
                observer.onCompleted()
            case .successed:
                observer.onNext(result)
                observer.onCompleted()
            }
        }
//        BDAccount.execute(BDAccountCommandType.getSMSCodeCommand, dataDelegate: dataDelegate, viewDelegate: delegate) TTASMSCodeScenarioPhoneLogin
        
        if  mobileString.count != 11 || !isPureInt(string: mobileString)
        {
            EnvContext.shared.toast.showToast("手机号错误")
            return Disposables.create()
        }
        
        TTAccountManager.startSendCode(withPhoneNumber: mobileString, captcha: nil, type: TTASMSCodeScenarioType.quickLogin, unbindExist: false, completion: {(number, image, error) in
//            print("sms number = \(String(describing: number))")
            delegate.onResponse?(.successed)
        })
        
        /*
        [TTAccountManager startSendCodeWithPhoneNumber:mobileString captcha:captchaString type:TTASMSCodeScenarioBindPhone unbindExist:NO completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
            StrongSelf;
            if (!error) {
            [self dismissWaitingIndicator];
            [self refreshSMSCodeButtonStatusWithRetryDuration:[retryTime doubleValue]];
            } else {
            if ([error.userInfo[@"error_code"] intValue] == TTAccountErrCodeHasRegistered) {
            [self dismissWaitingIndicator];
            [self switchBindMobile:error]; /* 解绑并绑定手机号 */
            } else if (captchaImage) {
            [self dismissWaitingIndicator];
            [self showCaptchaViewWithImage:captchaImage error:error forSMSCodeOp:YES];
            } else {
            [self dismissWaitingIndicatorWithError:error];
            }
            }
            }];
        */
        return Disposables.create()
    }
}

func isPureInt(string: String) -> Bool {
    
    let scan: Scanner = Scanner(string: string)
    
    var val:Int = 0
    
    return scan.scanInt(&val) && scan.isAtEnd
    
}

/*
class GetSMSCodeDataDelegate: NSObject, BDAccountFlowOperationDataDelegate {

    let mobileNumber: String
    let bdCodeType: Int

    init(mobileNumber: String,
         bdCodeType: Int) {
        self.mobileNumber = mobileNumber
        self.bdCodeType = bdCodeType
    }
    @objc //add by zjing,getSMSVerifyCodeCommand未加debug时这个方法没被调用导致功能有问题
    func operationRequestParamsCommandType(_ type: BDAccountCommandType, scene: Int) -> [AnyHashable : Any] {
        return [BDAccountFlowParamsPhoneNumberKey: mobileNumber,
                BDAccountFlowParamsSMSCodeTypeKey: BDAccountSMSCodeType.mobileSMSCodeLogin.rawValue]
    }

    deinit {
        print("GetSMSCodeDataDelegate")
    }
}
 */

class AccountViewDelegate: NSObject
{
    var onResponse: ((RequestSMSCodeResult) -> Void)?
}

/*
class AccountViewDelegate: NSObject, BDAccountGetSMSCodeViewDelegate {

    var onResponse: ((RequestSMSCodeResult) -> Void)?

    @objc
    func showInputSMSCodeViewRetryTime(_ retryTime: NSNumber?, scene: BDAccountSMSCodeType) {
        onResponse?(.successed)
    }

    @objc
    func showGetSMSCodeErrorView(_ error: Error?, retryTime: NSNumber?, scene: BDAccountSMSCodeType) {
        onResponse?(.error(error))
    }
    
    @objc
    func showGetSMSCodeInputCaptchaImageView(_ captchaImage: UIImage?, retryTime: NSNumber?, error: Error?, scene: BDAccountSMSCodeType) {
        if let image = captchaImage {
            onResponse?(.needCaptchaCode(image))
        } else {
            onResponse?(.error(error))
        }
    }
}
 */
