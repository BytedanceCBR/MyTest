//
//  AccountAPI.swift
//  Bubble
//
//  Created by linlin on 2018/7/17.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift

func requestSMSVerifyCode(
        mobileString: String,
        oldMobile: String?,
        bdCodeType: Int,
        captcha: String?,
        unbindExisted: Bool = true) -> Observable<RequestSMSCodeResult> {
    return Observable.create { (observer) in
        BDAccountAPIWrapper.requestSMSCode(
                withMobile: mobileString,
                oldMobile: nil,
                smsCodeType: bdCodeType,
                captcha: captcha,
                unbindExisted: true) { retryTime, captchaImage, error in
            if error != nil, let theError = error as NSError? {
                if theError.code == 1102, let image = captchaImage {
                    observer.onNext(.needCaptchaCode(image))
                    observer.onCompleted()
                } else {
                    observer.onError(error!)
                }
            } else {
                observer.onNext(.successed)
                observer.onCompleted()
            }
        }
        return Disposables.create()
    }
}



func requestQuickLogin(mobile: String, smsCode: String) -> Observable<Void> {
    return Observable.create { (observer) in
        BDAccount.requestQuickLogin(withMobile: mobile, smsCode: smsCode) { error in
            if let error = error {
                observer.onError(error)
            } else {
                observer.onNext(())
                observer.onCompleted()
            }
        }
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


func getSMSVerifyCodeCommand(mobileString: String, bdCodeType: Int) -> Observable<RequestSMSCodeResult> {
    let dataDelegate = GetSMSCodeDataDelegate(mobileNumber: mobileString, bdCodeType: bdCodeType)
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
        BDAccount.execute(BDAccountCommandType.getSMSCodeCommand, dataDelegate: dataDelegate, viewDelegate: delegate)
        return Disposables.create()
    }
}


class GetSMSCodeDataDelegate: NSObject, BDAccountFlowOperationDataDelegate {

    let mobileNumber: String
    let bdCodeType: Int

    init(mobileNumber: String,
         bdCodeType: Int) {
        self.mobileNumber = mobileNumber
        self.bdCodeType = bdCodeType
    }

    func operationRequestParamsCommandType(_ type: BDAccountCommandType, scene: Int) -> [AnyHashable : Any] {
        return [BDAccountFlowParamsPhoneNumberKey: mobileNumber,
                BDAccountFlowParamsSMSCodeTypeKey: BDAccountSMSCodeType.mobileSMSCodeLogin.rawValue]
    }

    deinit {
        print("GetSMSCodeDataDelegate")
    }
}

class AccountViewDelegate: NSObject, BDAccountFlowOperationViewDelegate {

    var onResponse: ((RequestSMSCodeResult) -> Void)?

    func showInputSMSCodeViewRetryTime(_ retryTime: NSNumber?, scene: BDAccountSMSCodeType) {
        onResponse?(.successed)
    }

    func showGetSMSCodeErrorView(_ error: Error?, retryTime: NSNumber?, scene: BDAccountSMSCodeType) {
        onResponse?(.error(error))
    }

    func showGetSMSCodeInputCaptchaImageView(_ captchaImage: UIImage?, retryTime: NSNumber?, error: Error?, scene: BDAccountSMSCodeType) {
        if let image = captchaImage {
            onResponse?(.needCaptchaCode(image))
        } else {
            onResponse?(.error(error))
        }
    }
}
