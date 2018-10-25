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
        

        if alertType == .alertTypeSendPhone
        {
            setupUIForSendPhone()
        }else
        {
            setupUI()
        }
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        bgView.addGestureRecognizer(tap)
        bgView.isUserInteractionEnabled = true
        
        
        setCustomerPanel(view: sendPhoneView)
        
        sendPhoneView.snp.makeConstraints { maker in
            maker.height.equalTo(200)
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
    }

    private func setupUI() {
        
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        bgView.addGestureRecognizer(tap)
        bgView.isUserInteractionEnabled = true
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
            .subscribe(onNext: { [unowned self] notification in
                let userInfo = notification.userInfo!
                let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                
                let animations:(() -> Void) = { [unowned self] in
                    
                    let offsetY = keyBoardBounds.height - (UIScreen.main.bounds.height - self.contentView.bottom)
                    self.contentView.top -= offsetY
                    
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


class NHSendPhoneNumberPanel: UIView {
    
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
            maker.height.equalTo(46)
        }
        
        
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
        //需要在下一个loop唤醒键盘
        DispatchQueue.main.async {
            self.phoneTextField.becomeFirstResponder()
        }
        confirmBtn.isEnabled = true
        
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
       
    }
    
    func hideErrorText()
    {
        errorLineView.isHidden = true
        errorTextLabel.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
