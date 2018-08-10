//
//  BubbleAlertViewController.swift
//  Bubble
//
//  Created by linlin on 2018/7/20.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class BubbleAlertController: UIAlertController {

    var lastY:CGFloat = 0
    
    lazy var contentView: UIView = {
        let re = UIView()
        return re
    }()

    var titleView: UIView?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.layer.cornerRadius = 6
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.width.equalTo(270)
            maker.centerX.equalToSuperview()
            maker.width.equalToSuperview()

        }
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
            .subscribe(onNext: { notification in
                let userInfo = notification.userInfo!
                let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                
                let animations:(() -> Void) = { [unowned self] in

                    let offsetY = keyBoardBounds.height - (UIScreen.main.bounds.height - self.view.bottom)
                    self.view.frame = CGRect(x: self.view.origin.x, y: self.view.origin.y - offsetY, width: self.view.width, height: self.view.height)
                    self.lastY = offsetY
                    
                    
                }
                
                if duration > 0 {
                    let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                    UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
                }else{
                    animations()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .subscribe(onNext: { notification in
                let userInfo = notification.userInfo!

                let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                
                let animations:(() -> Void) = { [unowned self] in
                    
                    self.view.frame = CGRect(x: self.view.origin.x, y: self.view.origin.y + self.lastY, width: self.view.width, height: self.view.height)
                    
                    
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
}

extension BubbleAlertController {
    func setCustomerTitlteView(title: String) {
        let titleView = BubbleAlertTitleView()
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
        }
        titleView.title.text = title
        titleView.closeBtn.rx.tap.bind(onNext: onClose).disposed(by: disposeBag)
        self.titleView = titleView
    }

    func onClose() {
        self.dismiss(animated: true)
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

class BubbleAlertTitleView: UIView {

    lazy var title: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(20)
        re.textColor = hexStringToUIColor(hex: "#000000")
        re.textAlignment = .center
        return re
    }()

    lazy var closeBtn: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "icon-close"), for: .normal)
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(title)
        title.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(30)
            maker.bottom.equalTo(-14)
        }

        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { maker in
            maker.height.width.equalTo(40)
            maker.top.equalTo(8)
            maker.right.equalTo(-8)
        }
        self.lu.addBottomBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
