//
//  BaseViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    private var progressHud: MBProgressHUD?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ttHideNavigationBar = true
        view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }

    func showLoadingAlert(message: String) {
        progressHud?.hide(animated: false)
        progressHud?.isUserInteractionEnabled = false
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud?.color = color(0, 0, 0, 0.8)
        progressHud?.contentColor = UIColor.white
        progressHud?.label.font = CommonUIStyle.Font.pingFangRegular(17)
        progressHud?.label.text = message
        let cycleIndicatorView = CycleIndicatorView()
        cycleIndicatorView.startAnimating()
        progressHud?.customView = cycleIndicatorView
        progressHud?.mode = MBProgressHUDMode.customView
    }

    func dismissLoadingAlert() {
        progressHud?.hide(animated: true)
        progressHud?.removeFromSuperview()
        progressHud = nil
    }

}
