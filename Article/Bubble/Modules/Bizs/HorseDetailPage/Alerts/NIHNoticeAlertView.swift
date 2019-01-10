//
//  NIHNoticeAlertView.swift
//  Article
//
//  Created by 张静 on 2018/8/28.
//

import UIKit
import RxSwift
import RxCocoa

enum NIHNoticeAlertType: Int{
    case alertTypeNormal = 1
    case alertTypeSendPhone = 2
}

class NIHNoticeAlertView: UIView {

    private let disposeBag = DisposeBag()
    var tracerParams: TracerParams?
    weak var titleView: UIView?

    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = color(0, 0, 0, 0.35)
        return re
    }()
    
    lazy var contentView: UIView = {
        let re = UIView()
        return re
    }()
    
    lazy var sendPhoneView: NHSendPhoneNumberPanel = {
        let re = NHSendPhoneNumberPanel(subTitle: self.subTitleStr)
        return re
    }()
    
    var titleStr: String
    
    var subTitleStr: String
    
    init(alertType: NIHNoticeAlertType = .alertTypeNormal,title: String = "询底价", subTitle: String = "随时获取房源最新动态",confirmBtnTitle: String = "提交") {
        self.titleStr = title
        subTitleStr = subTitle
        super.init(frame: UIScreen.main.bounds)
        
        setupUIForSendPhone()

        sendPhoneView.subTitleView.text = subTitle
        
        let attriStr = NSAttributedString(
            string: confirmBtnTitle,
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff")])
        sendPhoneView.confirmBtn.setAttributedTitle(attriStr, for: .normal)
    }
    
    private func setupUIForSendPhone()
    {
        
        setCustomerTitlteView(title: titleStr)
        
        addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
            
        }
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.width.equalTo(280*CommonUIStyle.Screen.widthScale)
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.resignTextFieldResponder))
        bgView.addGestureRecognizer(tap)
        bgView.isUserInteractionEnabled = true
        
        
        setCustomerPanel(view: sendPhoneView)
        
        sendPhoneView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
            .subscribe(onNext: { [unowned self] notification in
                let userInfo = notification.userInfo!
                let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                let animations:(() -> Void) = { [unowned self] in
                    let contentViewHeight = self.contentView.height
                    let tempOffset = UIScreen.main.bounds.height - keyBoardBounds.origin.y
                    if (tempOffset > 0) {
                        let offsetKeybord:CGFloat = 30.0
                        let offset = (UIScreen.main.bounds.height - (UIScreen.main.bounds.height - keyBoardBounds.origin.y) - contentViewHeight) - offsetKeybord
                        self.contentView.top = offset
                    } else {
                        let offset = (UIScreen.main.bounds.height - (UIScreen.main.bounds.height - keyBoardBounds.origin.y) - contentViewHeight) / 2
                        self.contentView.top = offset
                    }
                }
                
                if duration > 0 {
                    let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                    UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
                }else{
                    animations()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showFrom(_ parentView: UIView) {
        
        parentView.addSubview(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.bgView.alpha = 1
            self.contentView.alpha = 1
            
        })
        
        if let theTracerParams = self.tracerParams {
            
            // 登录
            recordEvent(key: TraceEventName.login_page, params: theTracerParams)
        }
        
    }

    @objc func resignTextFieldResponder() {
        self.sendPhoneView.phoneTextField.resignFirstResponder()
    }
    
    @objc func dismiss() {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.bgView.alpha = 0
            self.contentView.alpha = 0

        }) { (isCompleted) in
            
            self.removeFromSuperview()
        }

    }
    
    deinit {
//        print("NIHNoticeAlertView deinit")
    }
}

extension NIHNoticeAlertView {
    func setCustomerTitlteView(title: String) {
        let titleView = BubbleAlertTitleView()
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
        }
        titleView.title.text = title
        
        titleView.closeBtn.rx.tap.bind(onNext: { [unowned self] in
            
            self.dismiss()
        }).disposed(by: disposeBag)
        self.titleView = titleView
    }
    
    @objc func tapAction() {
        
    }
    
    
    func setCustomerPanel(view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { maker in
            if let titleView = self.titleView {
                maker.top.equalTo(titleView.snp.bottom)
            } else {
                maker.top.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().priority(.high)
        }
        
    }
    
}


class NHSendPhoneNumberPanel: UIView,UITextFieldDelegate {
    
    let acceptRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    
    let disposeBag = DisposeBag()

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
    
    lazy var errorLineView: UIView = {
        let re = UIView()
        re.backgroundColor =  hexStringToUIColor(hex: kFHCoralColor)
        re.isHidden = false
        return re
    }()
    
    lazy var errorTextLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoralColor)
        re.numberOfLines = 0
        re.text = "手机格式错误"
        return re
    }()
    
    lazy var phoneTextField: UITextField = {
        let re = UITextField()
        re.keyboardType = .phonePad
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.placeholder = "请输入手机号"
        if let phonenum = EnvContext.shared.client.sendPhoneNumberCache?.object(forKey: "phonenumber") as? String
        {
            // 显示 151*****010
            var tempPhone:String = phonenum
            if tempPhone.count == 11 {
                var temp:String = tempPhone
                tempPhone = "\(temp.prefix(3))*****\(temp.suffix(3))"
                self.origin_phoneNumber = phonenum
            }
            re.text = tempPhone
        }
        return re
    }()
    
    var origin_phoneNumber:String? = nil // 原有手机号
    // 当前输入手机号(有*号的特殊处理)
    var currentInputPhoneNumber:String? {
        get {
            if (self.origin_phoneNumber != nil) {
                return self.origin_phoneNumber
            }
            return self.phoneTextField.text
        }
    }
    
    
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
    
    // 隐私保护声明
    lazy var infoProtectedDecBtn: UIButton = {
        let re = UIButton()
        re.backgroundColor = UIColor.clear
        re.titleLabel?.font = CommonUIStyle.Font.pingFangRegular(10)
        re.setTitle("提交即视为同意《个人信息保护声明》", for: .normal)
        re.setTitle("提交即视为同意《个人信息保护声明》", for: .highlighted)
        re.setTitleColor(hexStringToUIColor(hex: "#a1aab3"), for: .normal)
        re.setTitleColor(hexStringToUIColor(hex: "#a1aab3"), for: .highlighted)
        return re
    }()
    
    
    init(subTitle: String) {
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
        
        
        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.right.equalTo(rightMarge)
            maker.top.equalTo(phoneInputView.snp.bottom).offset(20)
            maker.height.equalTo(40)
            maker.bottom.equalTo(self).offset(-40);
        }
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UITextFieldTextDidChange, object: nil)
            .subscribe(onNext: { [unowned self] notification in
                
                if let input = self.phoneTextField.text, input.count > 11 {
                    self.phoneTextField.text = String(input.prefix(11))
                }
            
            })
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text
            .filter { $0 != nil }
            .map { (text) in
                text!.count >= 1
            }
            .bind(onNext: { [unowned self] isEnabled in
                if isEnabled
                {
                    self.hideErrorText()
                }
                self.enableConfirmBtn(button: self.confirmBtn, isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)
        
        phoneTextField.delegate = self
        
        if let _ = self.origin_phoneNumber {
            // 有手机号，不弹出弹窗
        } else {
            //需要在下一个loop唤醒键盘
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.phoneTextField.becomeFirstResponder()
            }
        }
        confirmBtn.isEnabled = true
        
        addSubview(infoProtectedDecBtn)
        infoProtectedDecBtn.snp.makeConstraints { maker in
            maker.centerX.equalTo(self).offset(1)
            maker.height.equalTo(15)
            maker.bottom.equalTo(self).offset(-13);
        }
        infoProtectedDecBtn.addTarget(self, action: #selector(infoBtnClick(button:)), for: .touchUpInside)
    }
    
    @objc func infoBtnClick(button:UIButton) {
        self.phoneTextField.resignFirstResponder()
        let openUrl = "snssdk1370://webview_oc"
        let info: [String: Any] = ["url": "https://www.baidu.com", "title": "测试页面"]
        let userInfo = TTRouteUserInfo(info: info)
        TTRoute.shared()?.openURL(byViewController: URL(string: openUrl), userInfo: userInfo)
    }
    
    func enableConfirmBtn(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        if isEnabled {
            button.alpha = 1
        } else {
            button.alpha = 0.6
        }
    }
    
    func showErrorText()
    {
    
        if self.subviews.contains(errorLineView) && self.subviews.contains(errorTextLabel) {
            errorLineView.isHidden = false
            errorTextLabel.isHidden = false
            return
        }
        
       addSubview(errorLineView)
    
       errorLineView.snp.makeConstraints{ maker in
            maker.left.equalTo(phoneInputView)
            maker.right.equalTo(phoneInputView)
            maker.bottom.equalTo(phoneInputView.snp.bottom)
            maker.height.equalTo(1)
       }
      
       addSubview(errorTextLabel)
       
       errorTextLabel.snp.makeConstraints{ maker in
            maker.right.equalTo(phoneInputView)
            maker.centerY.equalTo(phoneInputView)
            maker.height.equalTo(24)
            maker.width.equalTo(80)
        }
        
       errorLineView.isHidden = false
       errorTextLabel.isHidden = false
       
    }
    
    func hideErrorText()
    {
        errorLineView.isHidden = true
        errorTextLabel.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 开始编辑
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let pn = self.origin_phoneNumber {
            // 有手机号，显示原来的手机号
            self.phoneTextField.text = pn
            self.origin_phoneNumber = nil
        }
        return true
    }
}
