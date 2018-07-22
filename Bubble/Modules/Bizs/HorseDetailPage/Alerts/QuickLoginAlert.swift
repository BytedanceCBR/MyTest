//
// Created by linlin on 2018/7/20.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
class QuickLoginAlertViewModel {

    weak var quickLoginAlert: BubbleAlertController?

    private let disposeBag = DisposeBag()

    private let quickLoginVM: QuickLoginViewModel

    var hud: MBProgressHUD?

    init(title: String, subTitle: String, alert: BubbleAlertController) {
        self.quickLoginAlert = alert
        self.quickLoginVM = QuickLoginViewModel()

        alert.setCustomerTitlteView(title: title)
        let panel = createQuickLoginPanel(title: title, subTitle: subTitle)
        alert.setCustomerPanel(view: panel)
        let theHud = MBProgressHUD()
        self.hud = theHud
        panel.addSubview(theHud)
    }

    fileprivate func createQuickLoginPanel(title: String, subTitle: String) -> QuickLoginPanel {
        let re = QuickLoginPanel()
        re.subTitleView.text = subTitle
        // 绑定输入电话后激活发送短信按钮
        re.phoneTextField.rx.text
                .map { $0 != nil && $0!.count >= 11 }
                .bind(to: re.sendSmsCodeBtn.rx.isEnabled)
                .disposed(by: disposeBag)

        // 设置确认按钮状态
        Observable
                .combineLatest(re.phoneTextField.rx.text, re.verifyCodeTextField.rx.text)
                .skip(1)
                .map { (e) -> Bool in
                    let (phone, code) = e
                    return phone?.count ?? 0 >= 11 && code?.count ?? 0 > 3
                }
                .bind(onNext: curry(self.enableConfirmBtn)(re.confirmBtn))
                .disposed(by: disposeBag)

        re.sendSmsCodeBtn.rx.tap
                .do(onNext: { [unowned self] in
                    self.showLoading(title: "正在获取验证码")
                    self.quickLoginVM.blockRequestSendMessage(button: re.sendSmsCodeBtn)
                })
                .withLatestFrom(re.phoneTextField.rx.text)
                .bind(to: quickLoginVM.requestSMS).disposed(by: disposeBag)

        let mergeInputs = Observable.combineLatest(re.phoneTextField.rx.text, re.verifyCodeTextField.rx.text)
        re.confirmBtn.rx.tap
                .do(onNext: { self.showLoading(title: "正在登录中") })
                .withLatestFrom(mergeInputs)
                .bind(to: quickLoginVM.requestLogin)
                .disposed(by: disposeBag)

        quickLoginVM.onResponse
                .bind(onNext: self.handleResposne)
                .disposed(by: disposeBag)


        EnvContext.shared.client.accountConfig.userInfo
                .filter { $0 != nil }
                .bind { [unowned self] _ in
                    self.quickLoginAlert?.dismiss(animated: true)
                }
                .disposed(by: disposeBag)

        return re
    }

    func enableConfirmBtn(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        if isEnabled {
            button.alpha = 1
        } else {
            button.alpha = 0.6
        }
    }

    func showLoading(title: String) {
        hud?.label.text = title
        hud?.mode = MBProgressHUDMode.determinate
        hud?.show(animated: true)
    }

    func handleResposne(result: RequestSMSCodeResult?) {
        hud?.hide(animated: true)
    }

}

fileprivate class QuickLoginPanel: UIView {

    lazy var subTitleView: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#707070")
        re.numberOfLines = 0
        return re
    }()

    lazy var phoneInputView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.layer.cornerRadius = 4
        return re
    }()

    lazy var verifyCodeInputView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.layer.cornerRadius = 4
        return re
    }()

    lazy var phoneTextField: UITextField = {
        let re = UITextField()
        re.keyboardType = .phonePad
        re.placeholder = "请输入手机号"
        return re
    }()

    lazy var verifyCodeTextField: UITextField = {
        let re = UITextField()
        re.keyboardType = .numberPad
        re.placeholder = "请输入验证码"
        return re
    }()

    lazy var sendSmsCodeBtn: UIButton = {
        let re = UIButton()
        QuickLoginVC.setVerifyCodeBtn(content: "获取验证码", btn: re)
        QuickLoginVC.setVerifyCodeBtn(
                content: "获取验证码",
                color: hexStringToUIColor(hex: "#999999"),
                status: .disabled,
                btn: re)
        return re
    }()

    lazy var disclaimer: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#cacaca")
        re.text = "新用户将自动注册，并视为同意《xxxx 用户协议》"
        return re
    }()

    lazy var confirmBtn: UIButton = {
        let re = UIButton()
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#f85656")
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
            maker.top.equalTo(17)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
        }

        addSubview(phoneInputView)
        phoneInputView.snp.makeConstraints { maker in
            maker.top.equalTo(subTitleView.snp.bottom).offset(14)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(40)
        }

        phoneInputView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(17)
        }

        addSubview(verifyCodeInputView)
        verifyCodeInputView.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInputView.snp.bottom).offset(10)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(40)
        }
        verifyCodeInputView.addSubview(verifyCodeTextField)
        verifyCodeTextField.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(17)
        }

        verifyCodeInputView.addSubview(sendSmsCodeBtn)
        sendSmsCodeBtn.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.height.equalTo(15)
            maker.right.equalTo(-10)
        }

        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(46)
        }

        addSubview(disclaimer)
        disclaimer.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.top.equalTo(verifyCodeInputView.snp.bottom).offset(6)
            maker.bottom.equalTo(confirmBtn.snp.top).offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
