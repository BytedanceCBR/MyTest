//
//  NIHNoticeAlertView.swift
//  Article
//
//  Created by 张静 on 2018/8/28.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    init() {
        super.init(frame: UIScreen.main.bounds)

        setupUI()
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

