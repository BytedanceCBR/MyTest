//
//  HomeViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class HomeViewController: UIViewController, UITableViewDelegate {

    private var tableView: UITableView!

    private let dataSource: HomeViewTableViewDataSource!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    let disposeBag = DisposeBag()

    init() {
        self.dataSource = HomeViewTableViewDataSource()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.tableView = UITableView()
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        tableView.dataSource = dataSource
        tableView.delegate = self
        let headerView = HomeHeaderSearchView(frame: CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: 120))
        tableView.tableHeaderView = headerView
        registerCell(tableView)
        headerView.snp.makeConstraints { (make) in
            make.top.width.equalToSuperview()
            make.height.equalTo(120)
        }
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        let throttle = offsetCriticalPointThrottle(-1)
        let observer = CGPointObserver(hiddenSearchItemByContentOffset(headerView: headerView))
            .join(adjustNavBarByContentOffset(navController: self.navigationController))
            .filter { throttle($0.y) }
        tableView.rx.contentOffset
            .subscribe(onNext: observer.observe)
            .disposed(by: disposeBag)

        let searchView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width - 20,
            height: 44))
        self.navigationItem.titleView = searchView

        let searchBar = SearchUITextField()
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    private func registerCell(_ tableView: UITableView) {
        let cellTypeMap: [String: UITableViewCell.Type] = ["item": MultiImageInfoCell.self]
        cellTypeMap.forEach { (e) in
            let (identifier, cls) = e
            tableView.register(cls, forCellReuseIdentifier: identifier)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView")
        let detailPage = HorseDetailPageVC()
    }

}
