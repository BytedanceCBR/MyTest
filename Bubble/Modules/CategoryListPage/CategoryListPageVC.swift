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

    lazy var conditionPanelView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    lazy var filterConditions: [SearchConditionItem] = { [] }()

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

        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        conditionPanelView.isHidden = true

        EnvContext.shared.client.configCacheSubject
            .map { $0?.filter }
            .map { items in
                let result: [SearchConditionItem] = items?
                    .map(transferSearchConfigFilterItemTo) ?? []
                let panelData: [[Node]] = items?.map {
                    if let options = $0.options {
                        return transferSearchConfigOptionToNode(options: options)
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
    }

    func initSearchConditionItemPanel(
        reload: @escaping () -> Void,
        item: SearchConditionItem,
        data: [Node]) -> (Int) -> Void {
        return generatePanelProviderByItem(reload: reload, item: item, data: data)
    }

    func generatePanelProviderByItem(reload: @escaping () -> Void,
                                     item: SearchConditionItem,
                                     data: [Node]) -> (Int) -> Void {
        switch item.itemId {
        case 1:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructAreaConditionPanel(nodes: data, self.closeConditionPanel { (index, nodes) in
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: parseAreaConditionItemLabel)(nodes)
                }))
        case 2:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructPriceListConditionPanel(nodes: data, self.closeConditionPanel { (index, nodes) in
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: parsePriceConditionItemLabel)(nodes)
                }))
        case 3:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructBubbleSelectCollectionPanel(nodes: data, self.closeConditionPanel { (index, nodes) in
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: parseHorseTypeConditionItemLabel)(nodes)
                }))
        default:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructBubbleSelectCollectionPanel(nodes: data, self.closeConditionPanel { (index, nodes) in
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: parseHorseTypeConditionItemLabel)(nodes)
                }))
        }
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
