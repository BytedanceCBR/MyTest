//
//  BaseViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.ttHideNavigationBar = true
        view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()

    }
}
