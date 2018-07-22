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

class ConditionPanelState {
    var currentIndex: Int
    var isShowPanel: Bool

    init() {
        self.currentIndex = -1
        self.isShowPanel = false
    }
}

typealias ConditionSelectAction = (Int, [Node]) -> Void

typealias ConditionPathParser = ([Node], String) -> String

typealias ConditionFilterPanelGenerator = (Int, UIView?) -> Void

struct ConditionAggregator {
    let aggregator: (String) -> String
}

extension ConditionAggregator {
    static func monoid() -> ConditionAggregator {
        return ConditionAggregator {
            $0
        }
    }
}

class CategoryListPageVC: UIViewController {

    let disposeBag = DisposeBag()

    lazy var navBar: CategorySearchNavBar = {
        let result = CategorySearchNavBar()
        result.searchInput.placeholder = "小区/商圈/地铁"
        result.searchTypeLabel.text = houseType.value.stringValue()
        return result
    }()

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView(frame: CGRect.zero, style: .plain)
        result.separatorStyle = .none
        result.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return result
    }()


    lazy var conditionPanelView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    lazy var footIndicatorView: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        return indicator
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    private var categoryListViewModel: CategoryListViewModel?

    private let isOpenConditionFilter: Bool

    init(isOpenConditionFilter: Bool) {
        self.isOpenConditionFilter = isOpenConditionFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: conditionPanelView,
            searchFilterPanel: searchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false

        UIApplication.shared.statusBarStyle = .default
        self.categoryListViewModel = CategoryListViewModel(tableView: self.tableView)
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(CommonUIStyle.NavBar.height)
        }

        navBar.searchAreaBtn.rx.tap
                .subscribe(onNext: { void in
                    let vc = SuggestionListVC()
                    let nav = self.navigationController ?? EnvContext.shared.rootNavController
                    nav.pushViewController(vc, animated: true)
                    vc.navBar.backBtn.rx.tap
                            .subscribe(onNext: { [weak nav] void in
                                nav?.popViewController(animated: true)
                            })
                            .disposed(by: self.disposeBag)
                    vc.onSuggestSelect = { [weak self, weak nav] (condition) in
                        nav?.popViewController(animated: true)
                        self?.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator {
                            condition($0)
                        }
                    }
                })
                .disposed(by: disposeBag)

        navBar.searchTypeBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.displayPopupMenu()
                })
                .disposed(by: disposeBag)

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

        bindLoadMore()

        bindSearchRequest()

        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        conditionPanelView.isHidden = true

        houseType.subscribe(onNext: { [weak self] (type) in
                    self?.navBar.searchTypeLabel.text = type.stringValue()
                    self?.searchAndConditionFilterVM.sendSearchRequest()
                })
                .disposed(by: disposeBag)

        EnvContext.shared.client.configCacheSubject
                .map {
                    $0?.filter
                }
                .map { items in
                    let result: [SearchConditionItem] = items?
                            .map(transferSearchConfigFilterItemTo) ?? []
                    let panelData: [[Node]] = items?.map {
                        if let options = $0.options {
                            return transferSearchConfigOptionToNode(
                                    options: options,
                                    isSupportMulti: $0.supportMulti)
                        } else {
                            return []
                        }
                    } ?? []
                    return (result, panelData)
                }
                .subscribe(onNext: { [unowned self] (items: ([SearchConditionItem], [[Node]])) in
                    let reload: () -> Void = { [weak self] in
                        self?.conditionFilterViewModel?.reloadConditionPanel()
                    }
                    zip(items.0, items.1).forEach({ (e) in
                        let (item, nodes) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(reload: reload, item: item, data: nodes)
                    })
                    self.conditionFilterViewModel?.filterConditions = items.0
                    self.conditionFilterViewModel?.reloadConditionPanel()
                })
                .disposed(by: disposeBag)
        self.searchAndConditionFilterVM.sendSearchRequest()

    }
    
    func bindLoadMore() {
        tableView.tableFooterView = footIndicatorView
        tableView.rx.didScroll
                .throttle(0.3, latest: false, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self, unowned tableView] void in
                    if tableView.contentOffset.y > 0 &&
                            tableView.contentSize.height - tableView.frame.height - tableView.contentOffset.y <= 0 &&
                            !self.footIndicatorView.isAnimating {
                        self.footIndicatorView.startAnimating()
                        self.loadData()
                    }
                })
                .disposed(by: disposeBag)
        self.categoryListViewModel?.onDataLoaded = { [unowned self] _ in
            self.footIndicatorView.stopAnimating()
        }
    }

    @objc func loadData() {
        categoryListViewModel?.pageableLoader?()
    }

    func bindSearchRequest() {
        searchAndConditionFilterVM.queryCondition
                .map { [weak self] (result) in
                    "house_type=\(self?.houseType.value.rawValue ?? HouseType.secondHandHouse.rawValue)" + result
                }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    self.categoryListViewModel?.requestData(houseType: self.houseType.value, query: query)
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func displayPopupMenu() {
        let menuItems = [HouseType.secondHandHouse,
                         HouseType.newHouse,
                         HouseType.neighborhood]

        let popupMenuItems = menuItems.map { type -> PopupMenuItem in
            let result = PopupMenuItem(label: type.stringValue(), isSelected: self.houseType.value == type)
            result.onClick = { [weak self] in
                self?.houseType.accept(type)
                self?.popupMenuView?.removeFromSuperview()
                self?.popupMenuView = nil
            }
            return result
        }
        popupMenuView = PopupMenuView(targetView: navBar.searchTypeBtn, menus: popupMenuItems)
        view.addSubview(popupMenuView!)
        popupMenuView?.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        popupMenuView?.showOnTargetView()
    }

}
