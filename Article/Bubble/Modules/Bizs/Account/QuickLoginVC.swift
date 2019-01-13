//
// Created by linlin on 2018/7/16.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

@objc
protocol QuickLoginVCDelegate: NSObjectProtocol {
    func loginSuccessed()
}

class NIHLoginVCDelegate: NSObject, QuickLoginVCDelegate {
    var callBack: (()->Void)?

    override init() {

    }

    init(callBack: @escaping ()->Void) {
        self.callBack = callBack
    }

    func loginSuccessed() {
        
        callBack?()
        
    }

}

class QuickLoginVC: BaseViewController, TTRouteInitializeProtocol {
    
    var acceptRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)

    var tracerParams = TracerParams.momoid()

    var loginDelegate: QuickLoginVCDelegate?

    fileprivate var userInteractionObv: NSKeyValueObservation?

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(backBtnImg: #imageLiteral(resourceName: "close"))
        re.title.text = "手机快捷登录"
        re.title.isHidden = true
        return re
    }()
    
    lazy var accountLoginView: UIView = {
        let re = UIView(frame: view.frame)
        return re
    }()
    
    lazy var scrollView: UIScrollView = {
        let re = UIScrollView(frame: view.frame)
        re.keyboardDismissMode = .onDrag
        return re
    }()

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(30)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.textAlignment = .left
        re.text = "手机快捷登录"
        return re
    }()

    lazy var subTitleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .left
        re.text = "未注册手机验证后自动注册"
        return re
    }()
    
    lazy var titleLabelAccountLogin: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(30)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.textAlignment = .left
        re.text = "账号密码登录"
        return re
    }()
    
    var isRouterPoped: Bool = false
    
    lazy var subTitleLabelAccountLogin: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .left
        re.text = "如有账户密码可直接登录"
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
    
    lazy var userInputAccountLogin: UITextField = {
        let re = UITextField()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入账号"
        re.keyboardType = .phonePad
        re.returnKeyType = .done
        return re
    }()

    lazy var singleLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()
    
    lazy var singleLineAccountLogin: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
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
    
    lazy var passwordInputAccountLogin: UITextField = {
        let re = UITextField()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入密码"
        re.isSecureTextEntry = true
        re.returnKeyType = .go
        return re
    }()

    lazy var singleLine2: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()
    
    lazy var singleLine2AccountLogin: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()

    lazy var sendVerifyCodeBtn: UIButton = {
        let re = UIButton()
        QuickLoginVC.setVerifyCodeBtn(content: "获取验证码", btn: re)
        QuickLoginVC.setVerifyCodeBtn(
                content: "获取验证码",
                color: hexStringToUIColor(hex: "#8a9299"),
                status: .disabled,
                btn: re)
        return re
    }()

    lazy var confirmBtn: UIButton = {
        let re = UIButton()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        re.alpha = 0.6
        re.layer.cornerRadius = 23
        let attriStr = NSAttributedString(
                string: "登录",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff"),
                             NSAttributedStringKey.underlineColor: UIColor.clear])
        re.setAttributedTitle(attriStr, for: .normal)
        re.isEnabled = false
        return re
    }()
    
    lazy var confirmAccountBtn: UIButton = {
        let re = UIButton()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        re.alpha = 0.6
        re.layer.cornerRadius = 23

        let attriStr = NSAttributedString(
            string: "登录",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.isEnabled = false
        return re
    }()
    
    lazy var changeLoginTypeBtn: UIButton = {
        let re = UIButton()
        re.layer.cornerRadius = 4
        let attriStr = NSAttributedString(
            string: "使用注册账号密码登陆>>",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")])
        re.setAttributedTitle(attriStr, for: .normal)
        let attriStrSlect = NSAttributedString(
            string: "使用验证码登陆>>",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")])
        re.setAttributedTitle(attriStrSlect, for: .selected)
        
        return re
    }()

    lazy var acceptCheckBox: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "checkbox-checked"), for: .selected)
        re.setImage(UIImage(named: "ic-filter-normal"), for: .normal)
        return re
    }()
    

    lazy var agreementLabel: YYLabel = {
        let re = YYLabel()
        re.numberOfLines = 0
        re.lineBreakMode = NSLineBreakMode.byWordWrapping
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        return re
    }()

    private let disposeBag = DisposeBag()

    private var quickLoginViewModel: QuickLoginViewModel?
    
    private var complete: ((Bool) -> Void)?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput, varifyCodeInput: varifyCodeInput)
    }
    
    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput, varifyCodeInput: varifyCodeInput)
        self.navBar.backBtn.rx.tap.bind { [unowned self] void in
            if let navVC = self.navigationController, navVC.viewControllers.count > 1 {
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
            self.tracerParams = paramsOfMap(params.filter {
                    if let key = $0.key as? String {
                        return key != "delegate"
                    } else {
                        return true
                    }
                } as! [String : Any])
        }
        if let delegate = paramObj?.userInfo.allInfo["delegate"] as? QuickLoginVCDelegate {
            self.complete = { [weak self] (isSuccessed) in
                if isSuccessed {
                    if let navVC = self?.navigationController, navVC.viewControllers.count > 1 {
                        self?.view.endEditing(true)
                        self?.isRouterPoped = true

                        navVC.popViewController(animated: true)
                        delegate.loginSuccessed()
                    } else {
                        self?.view.endEditing(true)
                        self?.isRouterPoped = true
                        self?.dismiss(animated: true, completion: {
                            delegate.loginSuccessed()
                        })
                    }
                }
            }
        }else
        {
            if let delegate = paramObj?.userInfo.allInfo["delegate"] as? TTAcountFLoginDelegate {
                self.complete = {[weak self] (isSuccessed) in
                    if isSuccessed {
                        
                        if let navVC = self?.navigationController, navVC.viewControllers.count > 1 {
                            self?.view.endEditing(true)
                            self?.isRouterPoped = true
                            navVC.popViewController(animated: true)
                            delegate.loginSuccessed()
                        } else {
                            self?.view.endEditing(true)
                            self?.isRouterPoped = true
                            self?.dismiss(animated: true, completion: {
                                delegate.loginSuccessed()
                            })
                        }
                    }
                }
            }
        }
    }
    
    @objc
    public init(complete: ((Bool) -> Void)?, params:[String: Any]? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.complete = complete
        self.hidesBottomBarWhenPushed = true
        self.quickLoginViewModel = QuickLoginViewModel(sendSMSBtn: sendVerifyCodeBtn, phoneInput: phoneInput, varifyCodeInput: varifyCodeInput)
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
        
        userInteractionObv = self.view.observe(\.isUserInteractionEnabled, options: [.new]) { [weak self] (view, value) in
            if let _ = value.newValue {
                self?.view.endEditing(true)
            }
        }
        
        view.addSubview(navBar)
        
        view.addSubview(agreementLabel)
        view.addSubview(acceptCheckBox)

        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
            } else {
                maker.height.equalTo(65)
            }
            maker.top.left.right.equalToSuperview()
        }
        
        navBar.backBtn.snp.updateConstraints { (maker) in
            maker.left.equalTo(22)
            maker.bottom.equalTo(-13)
        }

        view.addSubview(scrollView)

        scrollView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(40)
            maker.left.equalTo(30)
            maker.height.equalTo(42)
        }
        
        let rightView = UIView()
        scrollView.addSubview(rightView)
        rightView.snp.makeConstraints { maker in
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
            maker.width.equalTo(UIScreen.main.bounds.width - 60)
            maker.height.equalTo(1)
            maker.top.equalToSuperview()
        }

        scrollView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(30)
            maker.top.equalTo(titleLabel.snp.bottom).offset(6)
            maker.height.equalTo(20)
        }

        scrollView.addSubview(phoneInput)
        phoneInput.snp.makeConstraints { maker in
            maker.top.equalTo(subTitleLabel.snp.bottom).offset(40)
            maker.height.equalTo(20)
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(rightView)
        }
        
        scrollView.addSubview(singleLine)
        singleLine.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInput.snp.bottom).offset(11)
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(rightView)
            maker.height.equalTo(0.5)
         }

        scrollView.addSubview(varifyCodeInput)
        varifyCodeInput.snp.makeConstraints { maker in
            maker.top.equalTo(phoneInput.snp.bottom).offset(43)
            maker.height.equalTo(20)
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(rightView)
        }

        scrollView.addSubview(sendVerifyCodeBtn)
        sendVerifyCodeBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(varifyCodeInput.snp.centerY)
            maker.right.equalTo(rightView)
            maker.height.equalTo(30)
        }

        scrollView.addSubview(singleLine2)
        singleLine2.snp.makeConstraints { maker in
            maker.top.equalTo(varifyCodeInput.snp.bottom).offset(11)
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(rightView)
            maker.height.equalTo(0.5)
         }

        scrollView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.top.equalTo(varifyCodeInput.snp.bottom).offset(40)
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(rightView)
            maker.height.equalTo(46)
        }
        
//        view.addSubview(changeLoginTypeBtn)
//        changeLoginTypeBtn.isHidden = true
//        changeLoginTypeBtn.snp.makeConstraints { maker in
//            maker.top.equalTo(confirmBtn.snp.bottom).offset(2)
//            maker.left.equalTo(30)
//            maker.right.equalTo(-30)
//            maker.height.equalTo(46)
//        }
//        let generalBizConfig = EnvContext.shared.client.generalBizconfig
//        if let isFLogin =  generalBizConfig.generalCacheSubject.value?.reviewInfo?.isFLogin, isFLogin == true {
//            changeLoginTypeBtn.isHidden = false
//        }


        setAgreementContent()

        scrollView.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(agreementLabel.snp.top).offset(-20)

        }
        
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
                .withLatestFrom(mergeInputs)
                .bind(onNext: { [unowned self] (e) in
                    self.view.endEditing(true)
                    if self.acceptCheckBox.isSelected == false {
                        EnvContext.shared.toast.showToast("请阅读并同意好多房用户协议")
                    } else {
                        self.showLoading(title: "正在登录中")
                        recordEvent(key: TraceEventName.click_login, params: self.tracerParams)
                        self.quickLoginViewModel?.requestLogin.accept(e)
                    }
                })
                //                    .bind(to: quickLoginViewModel.requestLogin)
                .disposed(by: disposeBag)

            
//            changeLoginTypeBtn.rx.tap.subscribe { [weak self] event in
//
//                self?.setUpAccountLoginView()
//            } .disposed(by: disposeBag)
//

            quickLoginViewModel.onResponse
                    .bind(onNext: dismissHud())
                    .disposed(by: disposeBag)
        }

        EnvContext.shared.client.accountConfig.userInfo
            .filter { $0 != nil }.throttle(1, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                if let navVC = self.navigationController {
                    self.complete?(true)
                    self.view.endEditing(true)
                    if !self.isRouterPoped
                    {
                        navVC.popViewController(animated: true)
                    }
                } else {
                    self.complete?(true)
                    self.view.endEditing(true)
                    if !self.isRouterPoped
                    {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                    
                }
            })
            .disposed(by: disposeBag)


        acceptCheckBox.rx.tap.subscribe { [weak self] event in

            self?.acceptCheckBox.isSelected = !(self?.acceptCheckBox.isSelected ?? false)
            if self?.acceptCheckBox.isSelected == false {
                EnvContext.shared.toast.showToast("请阅读并同意好多房用户协议")
            }
            self?.acceptRelay.accept(self?.acceptCheckBox.isSelected ?? true)
            }
            .disposed(by: disposeBag)

        Observable
            .combineLatest(phoneInput.rx.text, acceptRelay.asObservable())
            .skip(1)
            .map { (e) -> Bool in
                let (phone, _) = e
                return phone?.count ?? 0 >= 1
            }
            .bind(onNext: { [unowned self] isEnabled in
                self.enableConfirmBtn(button: self.confirmBtn, isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)

        let paramsDict = self.tracerParams.paramsGetter([:])
        if paramsDict.count > 0 {
            recordEvent(key: TraceEventName.login_page, params: tracerParams)

        }
        handleKeyboardState()
        navBar.title.isHidden = true

    }

    func handleKeyboardState() {

        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
            .subscribe(onNext: { [weak self] notification in
                let userInfo = notification.userInfo!
                
                let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                
                UIView.animate(withDuration: duration, animations: {
                    
                    UIView.setAnimationBeginsFromCurrentState(true)
                    UIView.setAnimationDuration(duration)
                    UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve) ?? UIViewAnimationCurve.easeIn)
                    self?.scrollView.contentOffset = CGPoint(x: 0, y: 120)
                    self?.navBar.title.isHidden = false
                    
                })
                
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .subscribe(onNext: { [weak self] notification in
                let userInfo = notification.userInfo!
                
                let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                
                UIView.animate(withDuration: duration, animations: {
                    
                    UIView.setAnimationBeginsFromCurrentState(true)
                    UIView.setAnimationDuration(duration)
                    UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve) ?? UIViewAnimationCurve.easeIn)
                    self?.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    self?.navBar.title.isHidden = true
                    
                })
                
            })
            .disposed(by: disposeBag)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.ttStatusBarStyle = UIStatusBarStyle.default.rawValue
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }

//    func setUpAccountLoginView()
//    {
//        if changeLoginTypeBtn.isSelected
//        {
//            accountLoginView.isHidden = true
//        }else
//        {
//            if !view.subviews.contains(accountLoginView)
//            {
//                //账户密码登录容器
//                accountLoginView.backgroundColor = UIColor.white
//                view.addSubview(accountLoginView)
//
//                accountLoginView.snp.makeConstraints { maker in
//                    maker.top.equalTo(titleLabel.snp.top)
//                    maker.left.equalTo(0)
//                    maker.bottom.equalTo(confirmBtn.snp.bottom)
//                    maker.width.equalTo(view)
//                }
//
//                //账户密码登录按钮
//                accountLoginView.addSubview(confirmAccountBtn)
//                confirmAccountBtn.snp.makeConstraints { maker in
//                    maker.bottom.equalTo(accountLoginView.snp.bottom).offset(0)
//                    maker.left.equalTo(30)
//                    maker.right.equalTo(-30)
//                    maker.height.equalTo(46)
//                }
//
//                //账户密码登录子控价title
//                accountLoginView.addSubview(titleLabelAccountLogin)
//                titleLabelAccountLogin.snp.makeConstraints { maker in
//                    maker.top.equalTo(0)
//                    maker.left.equalTo(30)
//                    maker.height.equalTo(42)
//                    maker.width.equalTo(240)
//                }
//
//                //账户密码登录subtitle
//                accountLoginView.addSubview(subTitleLabelAccountLogin)
//                subTitleLabelAccountLogin.snp.makeConstraints { maker in
//                    maker.left.equalTo(30)
//                    maker.top.equalTo(titleLabelAccountLogin.snp.bottom).offset(6)
//                    maker.height.equalTo(20)
//                }
//
//                //账户输入
//                accountLoginView.addSubview(userInputAccountLogin)
//                userInputAccountLogin.snp.makeConstraints { maker in
//                    maker.top.equalTo(subTitleLabelAccountLogin.snp.bottom).offset(40)
//                    maker.height.equalTo(20)
//                    maker.left.equalTo(30)
//                    maker.right.equalTo(-30)
//                }
//
//                //账户分割线
//                accountLoginView.addSubview(singleLineAccountLogin)
//                singleLineAccountLogin.snp.makeConstraints { maker in
//                    maker.top.equalTo(userInputAccountLogin.snp.bottom).offset(11)
//                    maker.left.equalTo(30)
//                    maker.right.equalTo(-30)
//                    maker.height.equalTo(0.5)
//                }
//
//                //密码输入
//                accountLoginView.addSubview(passwordInputAccountLogin)
//                passwordInputAccountLogin.snp.makeConstraints { maker in
//                    maker.top.equalTo(userInputAccountLogin.snp.bottom).offset(40)
//                    maker.height.equalTo(20)
//                    maker.left.equalTo(30)
//                    maker.right.equalTo(-30)
//                }
//
//                //密码分割线
//                accountLoginView.addSubview(singleLine2AccountLogin)
//                singleLine2AccountLogin.snp.makeConstraints { maker in
//                    maker.top.equalTo(passwordInputAccountLogin.snp.bottom).offset(11)
//                    maker.left.equalTo(30)
//                    maker.right.equalTo(-30)
//                    maker.height.equalTo(0.5)
//                }
//
//                //监听用户输入操作及内容
//                Observable
//                    .combineLatest(userInputAccountLogin.rx.text, passwordInputAccountLogin.rx.text, acceptRelay.asObservable())
//                    .skip(1)
//                    .map { (e) -> Bool in
//                        let (userAcc, passWord,isSelected) = e
//                        return userAcc?.count ?? 0 >= 1 && passWord?.count ?? 0 > 1 && isSelected
//                    }
//                    .bind(onNext: { [unowned self] isEnabled in
//                        self.enableConfirmBtn(button: self.confirmAccountBtn, isEnabled: isEnabled)
//                    })
//                    .disposed(by: disposeBag)
//
//                if let quickLoginViewModel = self.quickLoginViewModel {
//                    let mergeInputsAcc = Observable.combineLatest(userInputAccountLogin.rx.text, passwordInputAccountLogin.rx.text)
//
//                    //账号密码登录Action
//                    confirmAccountBtn.rx.tap
//                        .do(onNext: { [unowned self] in
//                            self.showLoading(title: "正在登录中")
//                        })
//                        .withLatestFrom(mergeInputsAcc)
//                        .bind(to: quickLoginViewModel.requestPWDLogin) // 账号密码登录
//                        .disposed(by: disposeBag)
//
//                }
//            }else
//            {
//                accountLoginView.isHidden = false
//            }
//        }
//
//        changeLoginTypeBtn.isSelected = !changeLoginTypeBtn.isSelected
//    }
    
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
//        let width = view.frame.width - 45 - 3 - 30 //最终计算结果的宽度 acceptCheckBox.right + 偏移3 + 控件右边距
//        let size = agreementLabel.sizeThatFits(CGSize(width: width, height: 1000))
//        agreementLabel.snp.remakeConstraints { maker in
//            maker.right.equalTo(-30)
//            maker.height.equalTo(size.height)
//            maker.left.equalTo(acceptCheckBox.snp.right).offset(3)
//        }
//
//        acceptCheckBox.snp.remakeConstraints { maker in
//            maker.left.equalToSuperview().offset(30)
//            maker.height.width.equalTo(15)
//            maker.top.equalTo(agreementLabel).offset(1.5)
//        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        self.view.endEditing(true)
//    }

    static func setVerifyCodeBtn(
            content: String,
            color: UIColor = hexStringToUIColor(hex: kFHDarkIndigoColor),
            status: UIControlState = .normal,
            btn: UIButton) {
        let attriStr = NSAttributedString(
                string: content,
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(14),
                             NSAttributedStringKey.foregroundColor: color,
                             NSAttributedStringKey.underlineColor: UIColor.clear])
        btn.setAttributedTitle(attriStr, for: status)
    }

    func showLoading(title: String) {
        phoneInput.resignFirstResponder()
        varifyCodeInput.resignFirstResponder()
//        EnvContext.shared.toast.showLoadingToast(title)
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
                    if let url = "\(EnvContext.networkConfig.host)/f100/download/private_policy.html&title=隐私协议&hide_more=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://webview?url=\(url)"))
                    }
                })
        agreementLabel.attributedText = attrText
        
        let width = view.frame.width - 45 - 3 - 30 //最终计算结果的宽度 acceptCheckBox.right + 偏移3 + 控件右边距
        let size = agreementLabel.sizeThatFits(CGSize(width: width, height: 1000))
        agreementLabel.snp.remakeConstraints { maker in
            maker.right.equalTo(-30)
            maker.height.equalTo(size.height)
            maker.left.equalTo(acceptCheckBox.snp.right).offset(3)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            } else {
                maker.bottom.equalTo(-25)
            }
        }
    
        acceptCheckBox.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(30)
            maker.height.width.equalTo(15)
            maker.top.equalTo(agreementLabel).offset(1.5)
        }
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
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHCoolGrey2Color),
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(13)]
}
