//
//  TabViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        if let theFont = CommonUIStyle.Font.pingFangRegular(10) {
            UITabBarItem.appearance().setTitleTextAttributes([.font: theFont], for: .normal)
        }

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = true

        let home = HomeViewController()
        home.title = "首页"
        home.tabBarItem.image = #imageLiteral(resourceName: "tab_home")
        home.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab-home-pressed")
        home.tabBarItem.title = "首页"
        self.addChildViewController(home)

        self.tabBar.backgroundColor = hexStringToUIColor(hex: "#ffffff")
        self.tabBar.tintColor = hexStringToUIColor(hex: "#f85959")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
