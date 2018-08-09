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

class CategoryListPageVC: BaseViewController, TTRouteInitializeProtocol {

    let disposeBag = DisposeBag()
    
    var suggestionParams: String?

    lazy var navBar: CategorySearchNavBar = {
        let result = CategorySearchNavBar()
        result.searchInput.placeholder = "请输入小区/商圈/地铁"
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

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        re.label.text = "没有找到相关的信息，换个条件试试吧~"
        return re
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    private var categoryListViewModel: CategoryListViewModel?

    private let isOpenConditionFilter: Bool

    var queryString = ""

    let associationalWord: String?
    
    var hasMore: Bool = true

    init(isOpenConditionFilter: Bool, associationalWord: String? = nil) {
        self.isOpenConditionFilter = isOpenConditionFilter
        self.associationalWord = associationalWord
        super.init(nibName: nil, bundle: nil)
    }

    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        self.isOpenConditionFilter = false
        self.associationalWord = nil
        super.init(nibName: nil, bundle: nil)
        if let theHouseType = paramObj?.allParams["house_type"] as? String {
            houseType.accept(HouseType(rawValue: Int(theHouseType)!) ?? .secondHandHouse)
        }

        queryString = paramObj?.allParams
            .filter({ (e) -> Bool in
                let (key, _) = e
                return "\(key)" != "house_type"
            })
            .enumerated()
            .map({ (e) -> String in
                let (_, ele) = e
                return "&\(ele.0)=\(ele.1)"
            })
            .reduce("", { (result, item) -> String in
                "\(result)\(item)"
            }) ?? ""
        self.navBar.backBtn.rx.tap.bind { void in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let associationalWord = self.associationalWord {
            self.navBar.searchInput.placeholder = associationalWord
        }
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: conditionPanelView,
            searchFilterPanel: searchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false

        UIApplication.shared.statusBarStyle = .default
        self.categoryListViewModel = CategoryListViewModel(tableView: self.tableView, navVC: self.navigationController)
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(CommonUIStyle.NavBar.height - 20)
            } else {
                maker.bottom.equalTo(view.snp.top).offset(CommonUIStyle.NavBar.height)
            }
        }

        navBar.searchAreaBtn.rx.tap
                .subscribe(onNext: { void in
                    let vc = SuggestionListVC()
                    vc.houseType.accept(self.houseType.value)
                    vc.navBar.searchable = true
                    vc.navBar.canSelectType = false
                    let nav = self.navigationController
                    nav?.pushViewController(vc, animated: true)
                    vc.navBar.backBtn.rx.tap
                            .subscribe(onNext: { [weak nav] void in
                                nav?.popViewController(animated: true)
                            })
                            .disposed(by: self.disposeBag)
                    vc.onSuggestSelect = { [weak nav, unowned self] (query, condition, associationalWord) in
                        nav?.popViewController(animated: true)
                        self.suggestionParams = condition
                        self.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator { q in
                            q + query
                        }
                        self.searchAndConditionFilterVM.sendSearchRequest()
                        self.navBar.searchInput.placeholder = associationalWord
                        //TODO 处理条件变更后的设置
                    }
                })
                .disposed(by: disposeBag)

        navBar.searchTypeBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    if self.navBar.canSelectType {
                        self.displayPopupMenu()
                    }
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
            maker.left.right.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }

        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }

        bindLoadMore()

        bindSearchRequest()

        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }
        conditionPanelView.isHidden = true

        houseType.subscribe(onNext: { [weak self] (type) in
                    self?.navBar.searchTypeLabel.text = type.stringValue()
                    self?.searchAndConditionFilterVM.sendSearchRequest()
                })
                .disposed(by: disposeBag)

        Observable
                .zip(houseType, EnvContext.shared.client.configCacheSubject)
                .filter { (e) in
                    let (_, config) = e
                    return config != nil
                }
                .map { (e) -> ([SearchConfigFilterItem]?) in
                    let (type, config) = e
                    switch type {
                        case HouseType.newHouse:
                            return config?.courtFilter
                        case HouseType.secondHandHouse:
                            return config?.filter
                        case HouseType.neighborhood:
                            return config?.neighborhoodFilter
                        default:
                            return config?.filter
                    }
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
                            !self.footIndicatorView.isAnimating && self.hasMore {
                        self.footIndicatorView.loadingIndicator.isHidden = false
                        self.footIndicatorView.message.text = "正在努力加载中"
                        self.footIndicatorView.startAnimating()
                        self.loadData()
                    }
                })
                .disposed(by: disposeBag)
        self.categoryListViewModel?.onDataLoaded = { [unowned self] (hasMore, count) in
            self.footIndicatorView.stopAnimating()
            self.hasMore = hasMore
            if hasMore == false {
                self.footIndicatorView.message.text = " -- END -- "
                self.footIndicatorView.loadingIndicator.isHidden = true
            }
        }
    }

    @objc func loadData() {
        categoryListViewModel?.pageableLoader?()
    }

    func bindSearchRequest() {
        searchAndConditionFilterVM.queryCondition
                .map { [unowned self] (result) in
                    "house_type=\(self.houseType.value.rawValue)" + result + self.queryString
                }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .debug("queryCondition")
                .subscribe(onNext: { [unowned self] query in
                    self.categoryListViewModel?.requestData(houseType: self.houseType.value, query: query, condition: self.suggestionParams)
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
