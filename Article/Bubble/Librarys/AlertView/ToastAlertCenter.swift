//
// Created by linlin on 2018/7/23.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class ToastAlertCenter {
    lazy var toastAlert: ToastAlertView = {
        let re = ToastAlertView(frame: UIScreen.main.bounds)
        re.isUserInteractionEnabled = false
        return re
    }()

    init() {

    }

    func showToast(_ message: String, duration: TimeInterval = 1) {
        var style = ToastStyle()
        UIApplication.shared.keyWindow?.addSubview(toastAlert)
        toastAlert.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
        style.messageColor = .white
        toastAlert.makeToast(
            message,
            duration: duration,
            position: .center,
            style: style) { [weak self] didTap in
                
                self?.dismissToast()
            }

    }

    func showLoadingToast(_ message: String) {
        self.dismissToast()
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(toastAlert)
            toastAlert.snp.makeConstraints { maker in
                maker.top.bottom.left.right.equalToSuperview()
            }
            toastAlert.hideProgressHud()
            toastAlert.showProgressHud(message)
        }
    }
    
    func dismissToast() {
        toastAlert.hideProgressHud()
        toastAlert.hideAllToasts()
        toastAlert.removeFromSuperview()

    }
}

class ToastAlertView: UIView {

    private var progressHud: MBProgressHUD?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showProgressHud(_ message: String) {
        progressHud?.hide(animated: false)

        progressHud = MBProgressHUD.showAdded(to: self, animated: true)
        progressHud?.color = color(0, 0, 0, 0.8)
        progressHud?.contentColor = UIColor.white
        progressHud?.label.font = CommonUIStyle.Font.pingFangRegular(17)
        progressHud?.label.text = message
        let cycleIndicatorView = CycleIndicatorView()
        cycleIndicatorView.startAnimating()
        progressHud?.customView = cycleIndicatorView
        progressHud?.mode = MBProgressHUDMode.customView
    }

    func hideProgressHud() {
        progressHud?.hide(animated: true)
        progressHud?.removeFromSuperview()
        progressHud = nil
    }
}
