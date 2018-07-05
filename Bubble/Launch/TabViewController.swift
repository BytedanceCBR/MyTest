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
        UITabBarItem.appearance().setTitleTextAttributes([.font: CommonUIStyle.Font.pingFangRegular(10)], for: .normal)

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = true

        let home = HomeViewController()
        home.title = "首页"
        home.tabBarItem.image = #imageLiteral(resourceName: "tab-home")
        home.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab-home-pressed")
        home.tabBarItem.title = "首页"
        self.addChildViewController(home)

        let chatVC = ChatVC()
        chatVC.title = "消息"
        chatVC.tabBarItem.image = #imageLiteral(resourceName: "tab-message")
        chatVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab-message-pressed")
        chatVC.tabBarItem.title = "消息"
        self.addChildViewController(chatVC)

        let mineVC = MineVC()
        mineVC.title = "我的"
        mineVC.tabBarItem.image = #imageLiteral(resourceName: "tab-mine")
        mineVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab-mine-pressed")
        mineVC.tabBarItem.title = "我的"
        self.addChildViewController(mineVC)

        self.tabBar.backgroundColor = hexStringToUIColor(hex: "#ffffff")
        self.tabBar.tintColor = hexStringToUIColor(hex: "#f85959")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
