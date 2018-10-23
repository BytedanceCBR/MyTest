//
// Created by linlin on 2018/7/20.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
class QuickLoginAlertViewModel {

    weak var quickLoginAlert: NIHNoticeAlertView?

    weak var alertContentPanel: QuickLoginPanel?

    private let disposeBag = DisposeBag()

    private var quickLoginVM: QuickLoginViewModel?

    var onLoginSuccess: ((RequestQuickLoginResult) -> Void)?

    init(title: String, subTitle: String, alert: NIHNoticeAlertView) {
        
        self.quickLoginAlert = alert

        self.quickLoginAlert?.setCustomerTitlteView(title: title)
        
        self.quickLoginVM = QuickLoginViewModel()
        let panel = createQuickLoginPanel(title: title, subTitle: subTitle)
        alert.setCustomerPanel(view: panel)
        self.quickLoginVM?.sendSMSBtn = panel.sendSmsCodeBtn
        self.quickLoginVM?.phoneInput = panel.phoneTextField
        self.quickLoginVM?.varifyCodeInput = panel.verifyCodeTextField
        panel.phoneTextField.rx.text
            .filter { $0 != nil }
            .map { [unowned self] (text) in
                text!.count >= 1 && self.quickLoginVM?.timerDisposable == nil
            }
            .bind(to: panel.sendSmsCodeBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        //需要在下一个loop唤醒键盘
        DispatchQueue.main.async {
            panel.phoneTextField.becomeFirstResponder()
        }
    }

    fileprivate func createQuickLoginPanel(title: String, subTitle: String) -> QuickLoginPanel {
        let re = QuickLoginPanel()
        re.subTitleView.text = subTitle

        re.acceptCheckBox.rx.tap.subscribe { [weak re] event in
            re?.acceptCheckBox.isSelected = !(re?.acceptCheckBox.isSelected ?? false)
            if re?.acceptCheckBox.isSelected == false {
                EnvContext.shared.toast.showToast("请阅读并同意好多房用户协议")
            }
            re?.acceptRelay.accept(re?.acceptCheckBox.isSelected ?? true)

            }
            .disposed(by: disposeBag)
        // 设置确认按钮状态
        Observable
                .combineLatest(re.phoneTextField.rx.text, re.verifyCodeTextField.rx.text, re.acceptRelay.asObservable())
                .skip(1)
                .map { (e) -> Bool in
                    let (phone, code, _) = e
                    return phone?.count ?? 0 >= 11 && code?.count ?? 0 > 3
                }
                .bind(onNext: curry(self.enableConfirmBtn)(re.confirmBtn))
                .disposed(by: disposeBag)

        let paramsGetter = self.recordClickVerifyCode()
        
        if let quickLoginVM = self.quickLoginVM {
            re.sendSmsCodeBtn.rx.tap
                .do(onNext: {

                    paramsGetter()
                })
                .withLatestFrom(re.phoneTextField.rx.text)
                .bind(to: quickLoginVM.requestSMS).disposed(by: disposeBag)
            
            let mergeInputs = Observable.combineLatest(re.phoneTextField.rx.text, re.verifyCodeTextField.rx.text)
            re.confirmBtn.rx.tap
                .do(onNext: { [unowned self] in

                    if let tracerParams = self.quickLoginAlert?.tracerParams {
                        
                        recordEvent(key: TraceEventName.click_login, params: tracerParams)
                    }
                    
                })
                .withLatestFrom(mergeInputs)
                .bind(onNext: { [unowned re] (e) in
                    if re.acceptCheckBox.isSelected == false {
                        EnvContext.shared.toast.showToast("请阅读并同意好多房用户协议")
                    } else {
                        quickLoginVM.requestLogin.accept(e)
                    }
                })
//                .bind(to: quickLoginVM.requestLogin)
                .disposed(by: disposeBag)
            
        }

        quickLoginVM?.onResponse
                .bind(onNext: self.handleResposne)
                .disposed(by: disposeBag)


        EnvContext.shared.client.accountConfig.userInfo
                .filter { $0 != nil }
                .bind { [unowned self] _ in
                    self.quickLoginAlert?.dismiss()
                }
                .disposed(by: disposeBag)

        return re
    }
    
    func recordClickVerifyCode() -> (() -> Void) {
        var executed = 0
        return { [unowned self] in
            let tempExecuted = executed
            if executed == 0 {
                executed = 1
            }
            
            recordEvent(key: TraceEventName.click_verifycode, params: (self.quickLoginAlert?.tracerParams ?? TracerParams.momoid()) <|> toTracerParams(tempExecuted, key: "is_resent"))

        }
    }

    func enableConfirmBtn(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        if isEnabled {
            button.alpha = 1
        } else {
            button.alpha = 0.6
        }
    }

    func handleResposne(result: RequestSMSCodeResult?) {

    }

}

class QuickLoginPanel: UIView {
    
    let acceptRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)

    let leftMarge: CGFloat = 20
    let rightMarge: CGFloat = -20

    lazy var subTitleView: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.numberOfLines = 0
        return re
    }()

    lazy var phoneInputView: UIView = {
        let re = UIView()
        re.lu.addBottomBorder()
        return re
    }()

    lazy var verifyCodeInputView: UIView = {
        let re = UIView()
        re.lu.addBottomBorder()
        return re
    }()

    lazy var phoneTextField: UITextField = {
        let re = UITextField()
        re.keyboardType = .phonePad
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入手机号"
        return re
    }()

    lazy var verifyCodeTextField: UITextField = {
        let re = UITextField()
        re.keyboardType = .numberPad
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入验证码"
        return re
    }()

    lazy var sendSmsCodeBtn: UIButton = {
        let re = UIButton()
        QuickLoginVC.setVerifyCodeBtn(content: "获取验证码", btn: re)
        QuickLoginVC.setVerifyCodeBtn(
                content: "获取验证码",
                color: hexStringToUIColor(hex: "#a1aab3"),
                status: .disabled,
                btn: re)
        return re
    }()

    
    lazy var acceptCheckBox: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "checkbox-checked"), for: .selected)
        re.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        return re
    }()
    
    lazy var disclaimer: YYLabel = {
        let re = YYLabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.numberOfLines = 0
        re.lineBreakMode = NSLineBreakMode.byWordWrapping
        return re
    }()

    lazy var confirmBtn: UIButton = {
        let re = UIButton()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        re.layer.cornerRadius = 24
        re.alpha = 0.6
        let attriStr = NSAttributedString(
                string: "确认",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.isEnabled = false
        return re
    }()


    init() {
        super.init(frame: CGRect.zero)

        addSubview(subTitleView)
        subTitleView.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.left.equalTo(leftMarge)
            maker.right.equalTo(rightMarge)
        }

        addSubview(phoneInputView)
        phoneInputView.snp.makeConstraints { maker in
            maker.top.equalTo(subTitleView.snp.bottom).offset(20)
            maker.left.equalTo(leftMarge)
            maker.right.equalTo(rightMarge)
            maker.height.equalTo(40)
        }

        phoneInputView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(17)
        }

        addSubview(verifyCodeInputView)
        verifyCodeInputView.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInputView.snp.bottom).offset(10)
            maker.left.equalTo(leftMarge)
            maker.right.equalTo(rightMarge)
            maker.height.equalTo(40)
        }
        verifyCodeInputView.addSubview(verifyCodeTextField)
        verifyCodeTextField.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(17)
        }

        verifyCodeInputView.addSubview(sendSmsCodeBtn)
        sendSmsCodeBtn.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.height.equalTo(15)
            maker.right.equalTo(-10)
        }

        addSubview(acceptCheckBox)
        addSubview(disclaimer)

        acceptCheckBox.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.height.width.equalTo(20)
            maker.top.equalTo(disclaimer.snp.top).offset(4)
        }
        acceptCheckBox.isSelected = true
        

        
        let attrText = NSMutableAttributedString(string: "我已阅读并同意 《好多房用户使用协议》及《隐私协议》")
        
        let commonTextStyle = {
            return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHCoolGrey2Color),
                    NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(13)]
        }

        attrText.addAttributes(commonTextStyle(), range: NSRange(location: 0, length: attrText.length))
        attrText.yy_setTextHighlight(
            NSRange(location: 8, length: 11),
            color: hexStringToUIColor(hex: "#299cff"),
            backgroundColor: nil,
            userInfo: nil,
            tapAction: { (_, text, range, _) in
                if let url = "\(EnvContext.networkConfig.host)/f100/download/user_agreement.html&title=好多房用户协议&hide_more=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://webview?url=\(url)"))
                }
        })

        attrText.yy_setTextHighlight(
            NSRange(location: 20, length: 6),
            color: hexStringToUIColor(hex: "#299cff"),
            backgroundColor: nil,
            userInfo: nil,
            tapAction: { (_, text, range, _) in
                if let url = "\(EnvContext.networkConfig.host)/f100/download/private_policy.html&title=隐私声明&hide_more=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://webview?url=\(url)"))
                }
        })
        disclaimer.attributedText = attrText
        disclaimer.isUserInteractionEnabled = true

        let re = UILabel()
        re.text = "我已阅读并同意 《好多房用户使用协议》及《隐私协议》"
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.numberOfLines = 0
        re.width = 270 - acceptCheckBox.right - 5 - 20
        re.sizeToFit()
        re.isUserInteractionEnabled = true

        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.right.equalTo(rightMarge)
            maker.top.equalTo(verifyCodeInputView.snp.bottom).offset(20)
            maker.height.equalTo(46)
        }

        disclaimer.snp.makeConstraints { maker in
            maker.left.equalTo(acceptCheckBox.snp.right).offset(2)
            maker.right.equalTo(-20)
            maker.top.equalTo(confirmBtn.snp.bottom).offset(40)
            maker.height.equalTo(re.height)
            maker.bottom.equalTo(-15)
        }        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
