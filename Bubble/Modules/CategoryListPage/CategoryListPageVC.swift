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
        return ConditionAggregator { $0 }
    }
}

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

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

    lazy var conditionPanelView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    lazy var filterConditions: [SearchConditionItem] = {
        var result: [SearchConditionItem] = []
        var item = SearchConditionItem(label: "区域")
        item.onClick = openConditionPanel(
            state: conditionPanelState,
            apply: constructAreaConditionPanel(self.closeConditionPanel { [weak self] (index, nodes) in
                print(nodes)
                if !nodes.isEmpty {
                    item.label = nodes.last!.label
                    item.isHighlighted = true
                    self?.reloadConditionPanel()
                }
            }))
        result.append(item)

        var item1 = SearchConditionItem(
            label: "总价")
        item1.onClick = openConditionPanel(
            state: conditionPanelState,
            apply: constructPriceListConditionPanel(self.closeConditionPanel { [weak self] (index, nodes) in
                print(nodes)
                if !nodes.isEmpty {
                    item1.label = nodes.last?.label ?? "总价"
                    item1.isHighlighted = true
                    self?.reloadConditionPanel()
                }
            }))
        result.append(item1)

        var item2 = SearchConditionItem(
                label: "户型",
                onClick: openConditionPanel(
                        state: conditionPanelState,
                        apply: constructBubbleSelectCollectionPanel(self.closeConditionPanel { [weak self] (index, nodes) in
                            print(nodes)
                            self?.reloadConditionPanel()
                        })))
        result.append(item2)

        var item3 = SearchConditionItem(
                label: "更多",
                onClick: openConditionPanel(
                        state: conditionPanelState,
                        apply: constructBubbleSelectCollectionPanel(self.closeConditionPanel { [weak self] (index, nodes) in
                            print(nodes)
                            self?.reloadConditionPanel()
                        })))
        result.append(item3)
        return result
    }()

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

        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        conditionPanelView.isHidden = true
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
