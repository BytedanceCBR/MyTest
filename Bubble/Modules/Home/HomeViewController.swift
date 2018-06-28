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

    private let sectionHeader: CGFloat = 38

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    }()

    lazy var suspendSearchBar: HomePageSearchPanel = {
        let result = HomePageSearchPanel(frame: CGRect.zero)
        result.layer.shadowRadius = 4
        result.layer.shadowColor = hexStringToUIColor(hex: "#000000").cgColor
        result.layer.shadowOffset = CGSize(width: 0, height: 4)
        result.layer.shadowOpacity = 0.06
        return result
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
        requestHouseRecommend()
                .subscribe(onNext: { [unowned self] response in
                    if let data = response?.data?.items {
                        self.dataSource.onDataArrived(datas: data)
                        self.tableView.reloadData()
                    }
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)

        self.automaticallyAdjustsScrollViewInsets = false

        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
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
                    UIApplication.shared.statusBarStyle = .lightContent
                })
            default:
                UIView.animate(withDuration: 0.3, animations: {
                    self.navBar.isHidden = false
                    self.suspendSearchBar.isHidden = true
                    UIApplication.shared.statusBarStyle = .default
                })
            }
        }
        stateControl.onContentOffsetChanged = { [weak self] (state, offset) in
            self?.navBar.alpha = (1 - (139 - offset.y) / 139) * 2
        }
        tableView.rx.contentOffset
                .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
                .disposed(by: disposeBag)
        bindSearchEvent()

        EnvContext.shared.client.locationManager.currentCity
                .subscribe(onNext: { [unowned self] (reGeo) in
                    if let reGeo = reGeo {
                        self.suspendSearchBar.countryLabel.text = reGeo.city
                        self.navBar.suspendSearchBar.countryLabel.text = reGeo.city
                    }
                })
                .disposed(by: disposeBag)

        EnvContext.shared.client.currentSelectedCityId
                .map { i -> String in
                    if let cityList = EnvContext.shared.client.generalCacheSubject.value?.cityList {
                        return cityList.first {
                            $0.cityId == i
                        }?.name ?? "选择城市"
                    } else {
                        return "选择城市"
                    }
                }
                .subscribe(onNext: { i in
                    self.suspendSearchBar.countryLabel.text = i
                    self.navBar.suspendSearchBar.countryLabel.text = i
                })
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
            make.height.equalTo(52 + 20)
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
            maker.top.equalToSuperview().offset(28)
            maker.height.equalTo(40)
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
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
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailPage = HorseDetailPageVC()
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CategorySectionView()
    }

    private func bindSearchEvent() {
        suspendSearchBar.changeCountryBtn.rx.tap
                .subscribe(onNext: openCountryList)
                .disposed(by: disposeBag)
        suspendSearchBar.searchBtn.rx.tap
                .subscribe(onNext: openSearchPanel)
                .disposed(by: disposeBag)
        navBar.suspendSearchBar.changeCountryBtn.rx.tap
                .subscribe(onNext: openCountryList)
                .disposed(by: disposeBag)
        navBar.suspendSearchBar.searchBtn.rx.tap
                .subscribe(onNext: openSearchPanel)
                .disposed(by: disposeBag)
    }
}


extension HomeViewController {
    private func openCountryList() {
        print("openCountryList")
        let vc = CountryListVC()
        vc.onClose = { _ in
            EnvContext.shared.rootNavController.popViewController(animated: true)
        }
        vc.onItemSelect
                .subscribe(onNext: { i in
                    EnvContext.shared.client.currentSelectedCityId.accept(i)
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: self.disposeBag)
        EnvContext.shared.rootNavController.pushViewController(vc, animated: true)
    }

    private func openSearchPanel() {
        print("openSearchPanel")
        let vc = CategoryListPageVC()
        vc.houseType.accept(HouseType.secondHandHouse)
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(vc, animated: true)
    }
}

class BubbleNavigationBar: UIView {

    lazy var suspendSearchBar: HomePageSearchPanel = {
        let result = HomePageSearchPanel(frame: CGRect.zero, isHighlighted: true)
        result.isHighlighted = true
        return result
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(suspendSearchBar)
        suspendSearchBar.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(28)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
