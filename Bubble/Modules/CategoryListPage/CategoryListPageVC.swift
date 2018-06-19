//
//  CategoryListPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CategoryListPageVC: UIViewController {

    lazy var navBar: SearchNavBar = {
        let result = SearchNavBar()
        result.searchInput.placeholder = "小区/商圈/地铁"
        return result
    }()

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        return result
    }()

    lazy var dataSource: HomeViewTableViewDataSource = {
        HomeViewTableViewDataSource()
    }()

    let onClickFunc = {
        print("onClickFunc")
    }


    lazy var filterConditions: [SearchConditionItem] = {
        [SearchConditionItem(label: "区域", onClick: onClickFunc),
         SearchConditionItem(label: "总价", onClick: onClickFunc),
         SearchConditionItem(label: "户型", onClick: onClickFunc),
         SearchConditionItem(label: "更多", onClick: onClickFunc)]
    }()

    let disposeBag = DisposeBag()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(CommonUIStyle.NavBar.height)
        }

        view.addSubview(searchFilterPanel)
        searchFilterPanel.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(40)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
        }
        tableView.dataSource = dataSource
        registerCell(tableView)
        requestHouseRecommend()
                .subscribe(onNext: { [unowned self] response in
                    if let data = response?.data {
                        self.dataSource.onDataArrived(datas: data)
                        self.tableView.reloadData()
                    }
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)
        searchFilterPanel.setItems(items: filterConditions)
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

    private func registerCell(_ tableView: UITableView) {
        let cellTypeMap: [String: UITableViewCell.Type] = ["item": SingleImageInfoCell.self]
        cellTypeMap.forEach { (e) in
            let (identifier, cls) = e
            tableView.register(cls, forCellReuseIdentifier: identifier)
        }
    }

}
