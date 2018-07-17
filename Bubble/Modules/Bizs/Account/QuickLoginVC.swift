//
// Created by linlin on 2018/7/16.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class QuickLoginVC: BaseViewController {

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
        return re
    }()

    private let disposeBag = DisposeBag()

    private let quickLoginViewModel: QuickLoginViewModel

    var hud: MBProgressHUD?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.quickLoginViewModel = QuickLoginViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
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

        sendVerifyCodeBtn.rx.tap
                .do(onNext: { self.showLoading(title: "正在获取验证码") })
                .withLatestFrom(phoneInput.rx.text)
                .bind(to: quickLoginViewModel.requestSMS).disposed(by: disposeBag)

        let mergeInputs = Observable.combineLatest(phoneInput.rx.text, varifyCodeInput.rx.text)
        confirmBtn.rx.tap
                .do(onNext: { self.showLoading(title: "正在登录中") })
                .withLatestFrom(mergeInputs)
                .bind(to: quickLoginViewModel.requestLogin)
                .disposed(by: disposeBag)

        phoneInput.rx.text
            .filter { $0 != nil }
            .map { $0!.count >= 11 }
            .bind(to: sendVerifyCodeBtn.rx.isEnabled)
            .disposed(by: disposeBag)

        quickLoginViewModel.onResponse
            .bind(onNext: dismissHud())
            .disposed(by: disposeBag)

        EnvContext.shared.client.accountConfig.userInfo
                .filter { $0 != nil }
                .subscribe(onNext: { _ in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.label.text = title
        hud?.mode = MBProgressHUDMode.annularDeterminate
        hud?.show(animated: true)
    }

    func dismissHud() -> (RequestSMSCodeResult?) -> Void {
        return { [weak self] (_) in
            self?.hud?.hide(animated: true)
        }
    }

}
