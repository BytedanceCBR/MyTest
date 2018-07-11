//
//  BaseSubPageViewController.swift
//  Bubble
//
//  Created by linlin on 2018/7/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class BaseSubPageViewController: BaseViewController {

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        return re
    }()

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        return re
    }()

    private lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
        }

        self.view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomBar.snp.top)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
