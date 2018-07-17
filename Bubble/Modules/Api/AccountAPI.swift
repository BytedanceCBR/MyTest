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
    case successed
}


func getSMSVerifyCodeCommand(mobileString: String, bdCodeType: Int) -> Observable<RequestSMSCodeResult> {
    let dataDelegate = GetSMSCodeDataDelegate(mobileNumber: mobileString, bdCodeType: bdCodeType)
    return Observable.create { (observer) in
        BDAccount.execute(BDAccountCommandType.getSMSCodeCommand, dataDelegate: dataDelegate, viewDelegate: nil)
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
    
}
