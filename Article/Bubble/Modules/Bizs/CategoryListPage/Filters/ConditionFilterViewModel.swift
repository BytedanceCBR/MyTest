//
//  ConditionFilterViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ConditionPanelView: NSObjectProtocol {

//    var onConfirm: (([Node]) -> Void)? { get set }
//
//    var selectedNode: [Node] { get set }

    var isDisplay: Bool { get set }

    func viewDidDisplay()

    func viewDidDismiss()

    func onDisplay()

    func onDismiss()
}

class BaseConditionPanelView: UIView, ConditionPanelView {

    var isDisplay: Bool = false


    func viewDidDisplay() {

    }

    func viewDidDismiss() {

    }

    func setSelectedConditions(conditions: [String: Any]) {

    }
}

extension ConditionPanelView {

    func onDisplay() {
        isDisplay = true
        viewDidDisplay()
    }

    func onDismiss() {
        isDisplay = false
        viewDidDismiss()
    }
}

class ConditionFilterViewModel {
    
    weak var conditionPanelView: UIView?

    weak var searchFilterPanel: SearchFilterPanel?

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM: SearchAndConditionFilterViewModel

    lazy var filterConditions: [SearchConditionItem] = {
        []
    }()

    var conditionItemViews: [BaseConditionPanelView] = []

    let disposeBag = DisposeBag()

    init(conditionPanelView: UIControl,
         searchFilterPanel: SearchFilterPanel,
         searchAndConditionFilterVM: SearchAndConditionFilterViewModel) {
        self.conditionPanelView = conditionPanelView
        self.searchAndConditionFilterVM = searchAndConditionFilterVM
        self.searchFilterPanel = searchFilterPanel
        conditionPanelView.rx.controlEvent(.touchUpInside)
                .bind { [unowned self] recognizer in
                    self.closeConditionFilterPanel(index: -1)
                }
                .disposed(by: disposeBag)
    }

    func initSearchConditionItemPanel(
            index: Int,
            reload: @escaping () -> Void,
            item: SearchConditionItem,
            data: [Node]) -> (Int) -> Void {
        return generatePanelProviderByItem(
            reload: reload,
            index: index,
            item: item,
            containerView: conditionPanelView!,
            configs: data)
    }

    func setSelectedItem(items: [String: Any]) {
        conditionItemViews.forEach { $0.setSelectedConditions(conditions: items) }
    }

    func generatePanelProviderByItem(reload: @escaping () -> Void,
                                     index: Int,
                                     item: SearchConditionItem,
                                     containerView: UIView?,
                                     configs: [Node]) -> (Int) -> Void {
        let categoryName = item.label
        switch item.itemId {
        case 1:
            let selectedAction: (Int, [Node]) -> Void = { [weak self] (index, selectedNode) in
                self?.closeConditionFilterPanel(index: index)

                //处理条件回调
                guard let `self` = self else {return}
                self.onConditionSelected(
                    reload: reload,
                    categoryName: categoryName,
                    index: index,
                    selectedNode: selectedNode,
                    item: item,
                    conditionLabelParser: parseAreaConditionItemLabel,
                    conditionParser: parseAreaSearchCondition)
            }
            // 构造条件选择面板
            let panel = constructAreaConditionPanelWithContainer(nodes: configs, container: containerView!, action: selectedAction)
            conditionItemViews.append(panel)

            return { [weak self] (index) in
                self?.onOpenConditionPanel(panel: panel, index: index)
            }
        case 2:
            let selectedAction: (Int, [Node]) -> Void = { [weak self] (index, selectedNode) in
                self?.closeConditionFilterPanel(index: index)

                //处理条件回调
                guard let `self` = self else {return}
                self.onConditionSelected(
                    reload: reload,
                    categoryName: categoryName,
                    index: index,
                    selectedNode: selectedNode,
                    item: item, conditionLabelParser: parseAreaConditionItemLabel,
                    conditionParser: parseAreaSearchCondition)
            }
            let panel = constructPriceListConditionPanelWithContainer(
                    index: index,
                    nodes: configs,
                    container: containerView!,
                    action: selectedAction)
            conditionItemViews.append(panel)
            return { [weak self] (index) in
                self?.onOpenConditionPanel(panel: panel, index: index)
            }
        case 3:
            let selectedAction: (Int, [Node]) -> Void = { [weak self] (index, selectedNode) in
                self?.closeConditionFilterPanel(index: index)

                //处理条件回调
                guard let `self` = self else {return}
                self.onConditionSelected(
                        reload: reload,
                        categoryName: categoryName,
                        index: index,
                        selectedNode: selectedNode,
                        item: item, conditionLabelParser: parseHorseTypeConditionItemLabel,
                        conditionParser: parseHorseTypeSearchCondition)
            }
            let panel = constructBubbleSelectCollectionPanelWithContainer(
                    index: index,
                    nodes: configs,
                    container: containerView!,
                    selectedAction)
            conditionItemViews.append(panel)
            return { [weak self] (index) in
                self?.onOpenConditionPanel(panel: panel, index: index)
            }
        default:
            let selectedAction: (Int, [Node]) -> Void = { [weak self] (index, selectedNode) in
                self?.closeConditionFilterPanel(index: index)

                //处理条件回调
                guard let `self` = self else {return}
                self.onConditionSelected(
                        reload: reload,
                        categoryName: categoryName,
                        index: index,
                        selectedNode: selectedNode,
                        item: item, conditionLabelParser: parseMoreConditionItemLabel,
                        conditionParser: parseHorseTypeSearchCondition)
            }
            let panel = constructMoreSelectCollectionPanelWithContainer(
                    index: index,
                    nodes: configs,
                    container: containerView!,
                    selectedAction)
            conditionItemViews.append(panel)
            return { [weak self] (index) in
                self?.onOpenConditionPanel(panel: panel, index: index)
            }
        }
    }

    func onOpenConditionPanel(panel: BaseConditionPanelView, index: Int) {
//        print("open")
        self.resetAllSearchFilterPanelState()
        let currentDisplayItem = self.conditionItemViews.first(where: { $0.isDisplay })
        if let currentDisplayItem = currentDisplayItem, currentDisplayItem != panel {
            currentDisplayItem.onDismiss()
            currentDisplayItem.isHidden = true
        }
        if !panel.isDisplay {
            self.conditionPanelView?.isHidden = false
            panel.isHidden = false
            panel.onDisplay()
            self.setSearchFilterPanelState(index: index, isExpand: true)
        } else {
            self.conditionPanelView?.isHidden = true
            panel.isHidden = true
            panel.onDismiss()
            self.setSearchFilterPanelState(index: index, isExpand: false)
        }
    }

    func setSearchFilterPanelState(index: Int, isExpand: Bool) {
        if self.searchFilterPanel?.items.count ?? 0 > index {
            self.searchFilterPanel?.items[index].isExpand = isExpand
            self.searchFilterPanel?.items[index].isHighlighted = isExpand || (self.searchFilterPanel?.items[index].isSeted ?? false)
        }
        searchFilterPanel?.refresh()
    }

    func resetAllSearchFilterPanelState() {
        self.searchFilterPanel?.items.forEach({ (item) in
            item.isExpand = false
            item.isHighlighted = false || item.isSeted
        })
    }

    func onConditionSelected(
        reload: @escaping () -> Void,
        categoryName: String,
        index: Int,
        selectedNode: [Node],
        item: SearchConditionItem,
        conditionLabelParser: @escaping (String, [Node]) -> ConditionItemType,
        conditionParser: ([Node]) -> (String) -> String) {
        var conditions = self.searchAndConditionFilterVM.conditionTracer.value
        conditions[index] = selectedNode
        self.searchAndConditionFilterVM.conditionTracer.accept(conditions)

        self.searchAndConditionFilterVM.addCondition(index: index, condition: conditionParser(selectedNode))
        setConditionItemTypeByParser(
            item: item,
            reload: reload,
            parser: { nodes in
                conditionLabelParser(categoryName, nodes)
            })(selectedNode)
    }

    func closeConditionFilterPanel(index: Int) {
        if let view  = self.conditionItemViews.first(where: { $0.isDisplay }) {
            view.onDismiss()
            view.isHidden = true
        }
        self.conditionPanelView?.isHidden = true
        if index == -1 { // 魔法数字，清除所有面板状态
            self.conditionItemViews.enumerated().forEach { (e) in
                let (offset, _) = e
                self.setSearchFilterPanelState(index: offset, isExpand: false)
            }
        } else {
            self.setSearchFilterPanelState(index: index, isExpand: false)
        }
    }

//    private func closeConditionPanel(_ apply: @escaping ConditionSelectAction) -> ConditionSelectAction {
//        return { [weak self] (index, nodes) -> Void in
//            apply(index, nodes)
//            self?.closeConditionPanel()
//        }
//    }

//    private func closeConditionPanel() {
//        self.conditionPanelView?.subviews.forEach { view in
//            if let conditonView = view as? ConditionPanelView {
//                conditonView.viewDidDismiss()
//            }
//            view.removeFromSuperview()
//        }
//        self.conditionPanelView?.isHidden = true
//        self.reloadConditionPanel()
//    }

//    func dissmissConditionPanel() {
//        if let item = searchFilterPanel?.selectedItem() {
//            item.isExpand = false
//            if !item.isSeted {
//                item.isHighlighted = false
//            }
//        }
//
//        self.closeConditionPanel()
//    }

    func reloadConditionPanel() -> Void {
        searchFilterPanel?.setItems(items: filterConditions)
        self.conditionPanelState.isShowPanel = false
    }
}
