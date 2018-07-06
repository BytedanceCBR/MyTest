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
        return result
    }()


    lazy var conditionPanelView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    lazy var filterConditions: [SearchConditionItem] = {
        []
    }()

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    private var categoryListViewModel: CategoryListViewModel?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadConditionPanel() -> Void {
        searchFilterPanel.setItems(items: filterConditions)
        self.conditionPanelState.isShowPanel = false
    }

    func closeConditionPanel(_ apply: @escaping ConditionSelectAction) -> ConditionSelectAction {
        return { [weak self] (index, nodes) -> Void in
            self?.conditionPanelView.subviews.forEach { view in
                view.removeFromSuperview()
            }
            self?.conditionPanelView.isHidden = true
            apply(index, nodes)
            self?.reloadConditionPanel()
        }

    }

    func openConditionPanel(state: ConditionPanelState, apply: @escaping ConditionFilterPanelGenerator) -> (Int) -> Void {
        return { [weak self] (index) in
            if state.isShowPanel, state.currentIndex == index {
                self?.conditionPanelView.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                self?.conditionPanelView.isHidden = true
                state.isShowPanel = false
            } else if state.isShowPanel, state.currentIndex != index {
                self?.conditionPanelView.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                apply(index, self?.conditionPanelView)
                state.isShowPanel = true
            } else if state.isShowPanel != true {
                apply(index, self?.conditionPanelView)
                self?.conditionPanelView.isHidden = false
                state.isShowPanel = true
            }
            state.currentIndex = index
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: conditionPanelView,
            searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
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
        bindSearchRequest()
        searchFilterPanel.setItems(items: filterConditions)

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
                        self?.reloadConditionPanel()
                    }
                    zip(items.0, items.1).forEach({ (e) in
                        let (item, nodes) = e
                        item.onClick = self.initSearchConditionItemPanel(reload: reload, item: item, data: nodes)
                    })
                    self.filterConditions = items.0
                    self.reloadConditionPanel()
                })
                .disposed(by: disposeBag)
        self.searchAndConditionFilterVM.sendSearchRequest()

    }

    func bindSearchRequest() {
        searchAndConditionFilterVM.queryCondition
                .map { [weak self] (result) in
                    result + "&house_type=\(self?.houseType.value.rawValue ?? HouseType.secondHandHouse.rawValue)"
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

    func initSearchConditionItemPanel(
            reload: @escaping () -> Void,
            item: SearchConditionItem,
            data: [Node]) -> (Int) -> Void {
        return generatePanelProviderByItem(reload: reload, item: item, configs: data)
    }

    func generatePanelProviderByItem(reload: @escaping () -> Void,
                                     item: SearchConditionItem,
                                     configs: [Node]) -> (Int) -> Void {
        switch item.itemId {
        case 1:
            return openConditionPanel(
                    state: self.conditionPanelState,
                    apply: constructAreaConditionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                        self.searchAndConditionFilterVM.addCondition(index: index, condition: parseAreaSearchCondition(nodePath: nodes))
                        setConditionItemTypeByParser(
                                item: item,
                                reload: reload,
                                parser: parseAreaConditionItemLabel)(nodes)
                    }))
        case 2:
            return openConditionPanel(
                    state: self.conditionPanelState,
                    apply: constructPriceListConditionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                        self.searchAndConditionFilterVM.addCondition(index: index, condition: parsePriceSearchCondition(nodePath: nodes))
                        setConditionItemTypeByParser(
                                item: item,
                                reload: reload,
                                parser: parsePriceConditionItemLabel)(nodes)
                    }))
        case 3:
            return openConditionPanel(
                    state: self.conditionPanelState,
                    apply: constructBubbleSelectCollectionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                        self.searchAndConditionFilterVM.addCondition(index: index, condition: parseHorseTypeSearchCondition(nodePath: nodes))
                        setConditionItemTypeByParser(
                                item: item,
                                reload: reload,
                                parser: parseHorseTypeConditionItemLabel)(nodes)
                    }))
        default:
            return openConditionPanel(
                    state: self.conditionPanelState,
                    apply: constructMoreSelectCollectionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                        self.searchAndConditionFilterVM.addCondition(index: index, condition: parseHorseTypeSearchCondition(nodePath: nodes))
                        setConditionItemTypeByParser(
                                item: item,
                                reload: reload,
                                parser: parseMoreConditionItemLabel)(nodes)
                    }))
        }
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
