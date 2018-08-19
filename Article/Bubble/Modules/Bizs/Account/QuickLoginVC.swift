//
// Created by linlin on 2018/7/16.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

protocol QuickLoginVCDelegate {
    func loginSuccessed()
}

class QuickLoginVC: BaseViewController, TTRouteInitializeProtocol {
    
    var acceptRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)

    var tracerParams = TracerParams.momoid()

    var loginDelegate: QuickLoginVCDelegate?

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(backBtnImg: #imageLiteral(resourceName: "close"))
        return re
    }()

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(30)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.textAlignment = .left
        re.text = "手机快捷登录"
        return re
    }()

    lazy var subTitleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.textAlignment = .left
        re.text = "未注册手机验证后自动注册"
        return re
    }()

    lazy var phoneInput: UITextField = {
        let re = UITextField()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入手机号"
        re.keyboardType = .phonePad
        re.returnKeyType = .done
        return re
    }()

    lazy var singleLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    lazy var varifyCodeInput: UITextField = {
        let re = UITextField()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入验证码"
        re.keyboardType = .numberPad
        re.returnKeyType = .go
        return re
    }()

    lazy var singleLine2: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    lazy var sendVerifyCodeBtn: UIButton = {
        let re = UIButton()
        QuickLoginVC.setVerifyCodeBtn(content: "获取验证码", btn: re)
        QuickLoginVC.setVerifyCodeBtn(
                content: "获取验证码",
                color: hexStringToUIColor(hex: "#999999"),
                status: .disabled,
                btn: re)
        return re
    }()

    lazy var confirmBtn: UIButton = {
        let re = UIButton()
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#f85656")
        re.alpha = 0.6
        let attriStr = NSAttributedString(
                string: "登录",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.isEnabled = false
        return re
    }()

    lazy var acceptCheckBox: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "checkbox-checked"), for: .selected)
        re.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        return re
    }()

    lazy var agreementLabel: YYLabel = {
        let re = YYLabel()
        re.numberOfLines = 0
        re.lineBreakMode = NSLineBreakMode.byWordWrapping
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        return re
    }()

    private let disposeBag = DisposeBag()

    private var quickLoginViewModel: QuickLoginViewModel?
    
    private var complete: ((Bool) -> Void)?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput)
    }
    
    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput)
        self.navBar.backBtn.rx.tap.bind { [unowned self] void in
            if let navVC = self.navigationController,navVC.viewControllers.count > 1 {
                self.view.endEditing(true)
                navVC.popViewController(animated: true)
            } else {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: {
                })
            }
        }.disposed(by: disposeBag)
        
        let userInfo = paramObj?.userInfo
        if let params = userInfo?.allInfo {
            self.tracerParams = paramsOfMap(params as! [String : Any])
        }
        
    }
    
    @objc
    public init(complete: ((Bool) -> Void)?, params:[String: Any]? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.complete = complete
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput)
        self.navBar.backBtn.rx.tap.bind { [unowned self] void in
            if let navVC = self.navigationController,navVC.viewControllers.count > 1 {
                self.complete?(false)
                self.view.endEditing(true)
                navVC.popViewController(animated: true)
            } else {
                self.complete?(false)
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: {
                })
            }
        }.disposed(by: disposeBag)
        
        if let theParams = params {
            self.tracerParams = paramsOfMap(theParams)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
            } else {
                maker.height.equalTo(65)
            }
            maker.top.left.right.equalToSuperview()
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom).offset(40)
            maker.left.equalTo(30)
            maker.height.equalTo(42)
            maker.width.equalTo(180)
        }

        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(30)
            maker.top.equalTo(titleLabel.snp.bottom).offset(6)
            maker.height.equalTo(20)
        }

        view.addSubview(phoneInput)
        phoneInput.snp.makeConstraints { maker in
            maker.top.equalTo(subTitleLabel.snp.bottom).offset(40)
            maker.height.equalTo(20)
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
        }

        view.addSubview(singleLine)
        singleLine.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInput.snp.bottom).offset(11)
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
            maker.height.equalTo(0.5)
         }

        view.addSubview(varifyCodeInput)
        varifyCodeInput.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInput.snp.bottom).offset(40)
            maker.height.equalTo(20)
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
        }

        view.addSubview(sendVerifyCodeBtn)
        sendVerifyCodeBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(varifyCodeInput.snp.centerY)
            maker.right.equalTo(-30)
            maker.height.equalTo(30)
        }

        view.addSubview(singleLine2)
        singleLine2.snp.makeConstraints { maker in
            maker.top.equalTo(varifyCodeInput.snp.bottom).offset(11)
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
            maker.height.equalTo(0.5)
         }

        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.top.equalTo(varifyCodeInput.snp.bottom).offset(31)
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
            maker.height.equalTo(46)
        }

        view.addSubview(agreementLabel)
        agreementLabel.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            } else {
                maker.bottom.equalTo(-25)
            }
            maker.left.equalTo(77)
            maker.right.equalTo(-60)
        }

        view.addSubview(acceptCheckBox)
        acceptCheckBox.snp.makeConstraints { maker in
            maker.right.equalTo(agreementLabel.snp.left).offset(-3)
            maker.height.width.equalTo(20)
            maker.top.equalTo(agreementLabel.snp.top).offset(-0.5)
        }

        setAgreementContent()

        if let quickLoginViewModel = self.quickLoginViewModel {
            let paramsGetter = self.recordClickVerifyCode()
            sendVerifyCodeBtn.rx.tap
                    .do(onNext: { [unowned self] in
                        
                        self.showLoading(title: "正在获取验证码")
                        recordEvent(key: TraceEventName.click_verifycode, params: self.tracerParams <|> paramsGetter())

                    })
                    .withLatestFrom(phoneInput.rx.text)
                    .bind(to: quickLoginViewModel.requestSMS)
                    .disposed(by: disposeBag)

            let mergeInputs = Observable.combineLatest(phoneInput.rx.text, varifyCodeInput.rx.text)
            

            confirmBtn.rx.tap
                    .do(onNext: { [unowned self] in
                        self.showLoading(title: "正在登录中")
                        recordEvent(key: TraceEventName.click_login, params: self.tracerParams)
                    })
                    .withLatestFrom(mergeInputs)
                    .bind(to: quickLoginViewModel.requestLogin)
                    .disposed(by: disposeBag)

            quickLoginViewModel.onResponse
                    .bind(onNext: dismissHud())
                    .disposed(by: disposeBag)
        }

        EnvContext.shared.client.accountConfig.userInfo
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] _ in
                if let navVC = self.navigationController {
                    self.complete?(true)
                    self.view.endEditing(true)
                    navVC.popViewController(animated: true)
                } else {
                    self.complete?(true)
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: {
                    })
                }
            })
            .disposed(by: disposeBag)

        
        acceptCheckBox.rx.tap.subscribe { [unowned self] event in
            
            self.acceptCheckBox.isSelected = !self.acceptCheckBox.isSelected
            self.acceptRelay.accept(self.acceptCheckBox.isSelected)
            }
            .disposed(by: disposeBag)
       
        Observable
            .combineLatest(phoneInput.rx.text, varifyCodeInput.rx.text, acceptRelay.asObservable())
            .skip(1)
            .map { (e) -> Bool in
                let (phone, code,isSelected) = e
                return phone?.count ?? 0 >= 11 && code?.count ?? 0 > 3 && isSelected
            }
            .bind(onNext: { [unowned self] isEnabled in
                self.enableConfirmBtn(button: self.confirmBtn, isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)
        
        recordEvent(key: TraceEventName.login_page, params: self.tracerParams)

    }
    
    func recordClickVerifyCode() -> (() -> TracerParams) {
        var executed = 0
        return {
            let tempExecuted = executed
            if executed == 0 {
                executed = 1
            }
            return TracerParams.momoid() <|> toTracerParams(tempExecuted, key: "is_resent")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = agreementLabel.sizeThatFits(CGSize(width: view.frame.width - 120, height: 1000))
        agreementLabel.snp.remakeConstraints { maker in
            maker.right.equalTo(-60)
            maker.height.equalTo(size.height)
            maker.left.equalTo(77)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            } else {
                maker.bottom.equalTo(-25)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    static func setVerifyCodeBtn(
            content: String,
            color: UIColor = hexStringToUIColor(hex: "#222222"),
            status: UIControlState = .normal,
            btn: UIButton) {
        let attriStr = NSAttributedString(
                string: content,
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(14),
                             NSAttributedStringKey.foregroundColor: color])
        btn.setAttributedTitle(attriStr, for: status)
    }

    func showLoading(title: String) {
        phoneInput.resignFirstResponder()
        varifyCodeInput.resignFirstResponder()
        EnvContext.shared.toast.showLoadingToast(title)
    }

    func dismissHud() -> (RequestSMSCodeResult?) -> Void {
        return { (_) in
            EnvContext.shared.toast.dismissToast()
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

    private func setAgreementContent() {
        
        self.acceptCheckBox.isSelected = true
        let attrText = NSMutableAttributedString(string: "我已阅读并同意 《好多房用户使用协议》及《隐私协议》")
        attrText.addAttributes(commonTextStyle(), range: NSRange(location: 0, length: attrText.length))
        attrText.yy_setTextHighlight(
                NSRange(location: 8, length: 11),
                color: hexStringToUIColor(hex: "#f85959"),
                backgroundColor: nil,
                userInfo: nil,
                tapAction: { (_, text, range, _) in
                    if let url = "https://m.quduzixun.com/f100/download/user_agreement.html&title=好多房用户协议&hide_more=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://webview?url=\(url)"))
                    }
                })

        attrText.yy_setTextHighlight(
                NSRange(location: 20, length: 6),
                color: hexStringToUIColor(hex: "#f85959"),
                backgroundColor: nil,
                userInfo: nil,
                tapAction: { (_, text, range, _) in
                    if let url = "https://m.quduzixun.com/f100/download/private_policy.html&title=隐私声明&hide_more=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://webview?url=\(url)"))
                    }
                })
        agreementLabel.attributedText = attrText
        
        
    }

    deinit {
        print("deinit QuickLoginVC")
    }

}

func openQuickLoginVC(disposeBag: DisposeBag) {
    let vc = QuickLoginVC()
    vc.navBar.backBtn.rx.tap
        .subscribe(onNext: { void in
            EnvContext.shared.rootNavController.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
    EnvContext.shared.rootNavController.pushViewController(vc, animated: true)
}

fileprivate func commonTextStyle() -> [NSAttributedStringKey: Any] {
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#999999"),
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(13)]
}
