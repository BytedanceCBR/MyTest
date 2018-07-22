//
//  BaseViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
    }
}
