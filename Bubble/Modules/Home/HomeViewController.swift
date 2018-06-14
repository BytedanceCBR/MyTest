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

    private var navBar: BubbleNavigationBar!

    private let dataSource: HomeViewTableViewDataSource!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    let disposeBag = DisposeBag()

    lazy var slidePageViewPanel: SlidePageViewPanel = {
        SlidePageViewPanel()
    }()

    lazy var headerViewPanel: UIView = {
        UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.frame.width,
                height: 327))
//        UIView()
    }()

    lazy var suspendSearchBar: SearchUITextField = {
        SearchUITextField()
    }()

    lazy var homeSpringBoard: HomeSpringBoard = {
        HomeSpringBoard()
    }()


    var homeSpringBoardViewModel: HomeSpringBoardViewModel!

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
        registerCell(tableView)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        setupNormalNavBar()

        let stateControl = HomeHeaderStateControl()
        stateControl.onStateChanged = { (state) in
            switch state {
            case .suspend:
                UIView.animate(withDuration: 0.3, animations: {
                    self.navBar.isHidden = true
                    self.suspendSearchBar.isHidden = false
                })
            default:
                UIView.animate(withDuration: 0.3, animations: {
                    self.navBar.isHidden = false
                    self.suspendSearchBar.isHidden = true
                })
            }
        }
        tableView.rx.contentOffset
                .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
                .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView = headerViewPanel
        setupHeaderSlidePanel(tableView: tableView)
        setupHomeSpringBoard()
    }

    private func setupNormalNavBar() {
        navBar = BubbleNavigationBar()
        navBar.isHidden = true
        self.view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44 + 20)
        }
    }

    private func setupHeaderSlidePanel(tableView: UITableView) {
        headerViewPanel.addSubview(slidePageViewPanel)
        slidePageViewPanel.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(211)
        }
        slidePageViewPanel.slidePageView.itemProvider = {
            [WebImageItemView(),
             WebImageItemView(),
             WebImageItemView()]
        }
        slidePageViewPanel.slidePageView.loadData()
        headerViewPanel.addSubview(suspendSearchBar)
        suspendSearchBar.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().offset(20)
            maker.width.equalToSuperview().offset(-40)
            maker.height.equalTo(24)
        }
    }

    private func setupHomeSpringBoard() {
        headerViewPanel.addSubview(homeSpringBoard)
        homeSpringBoard.snp.makeConstraints { [unowned slidePageViewPanel] maker in
            maker.top.equalTo(slidePageViewPanel.snp.bottom)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(8)
            maker.right.equalToSuperview().offset(-8)
            maker.height.equalTo(116)
         }
        homeSpringBoardViewModel = HomeSpringBoardViewModel(springBoard: homeSpringBoard)
        homeSpringBoardViewModel.loadData()
        slidePageViewPanel.startCarousel()
    }

    private func registerCell(_ tableView: UITableView) {
        let cellTypeMap: [String: UITableViewCell.Type] = ["item": SingleImageInfoCell.self]
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
        let detailPage = HorseDetailPageVC()
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}

class BubbleNavigationBar: UIView {

    let searchBar: SearchUITextField

    init() {
        searchBar = SearchUITextField()
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(28)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
