//
//  CategoryListPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class CategoryListPageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.sendSubview(toBack: navigationController.navigationBar)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
        }
    }

}
