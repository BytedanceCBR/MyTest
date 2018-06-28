//
//  HorseDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import Charts
class HorseDetailPageVC: BaseViewController {

    lazy var slidePageViewPanel: SlidePageViewPanel = {
        SlidePageViewPanel()
    }()

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false

        self.view.backgroundColor = UIColor.white
        self.view.addSubview(slidePageViewPanel)
        slidePageViewPanel.slidePageView.itemProvider = {
            [WebImageItemView(),
             WebImageItemView(),
             WebImageItemView()]
        }
        slidePageViewPanel.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(247)
        }
        slidePageViewPanel.slidePageView.loadData()
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
