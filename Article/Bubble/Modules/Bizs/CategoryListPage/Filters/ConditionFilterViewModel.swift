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

    var conditionLabelSetter: (([Node]) -> Void)? { get set }

    func viewDidDisplay()

    func viewDidDismiss()

    func onDisplay()

    func onDismiss()

    func selectedNodes() -> [Node]
}

class BaseConditionPanelView: UIView, ConditionPanelView {

    var isDisplay: Bool = false

    var conditionParser: (([Node]) -> (String) -> String)?

    var conditionLabelParser: ((String, [Node]) -> ConditionItemType)?

    var conditionLabelSetter: (([Node]) -> Void)?

    func viewDidDisplay() {

    }

    func viewDidDismiss() {

    }

    func setSelectedConditions(conditions: [String: Any]) {

    }

    func selectedNodes() -> [Node] {
        return []
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

    weak var searchSortBtn: UIButton?

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM: SearchAndConditionFilterViewModel

    lazy var filterConditions: [SearchConditionItem] = {
        []
    }()

    var conditionItemViews: [Int: BaseConditionPanelView] = [:]

    let disposeBag = DisposeBag()

    var conditionPanelWillDisplay: (() -> Void)?

    weak var sortPanelView: SortConditionPanel? {
        didSet {
            sortPanelView?.didSelect = { [weak self] node in
                self?.searchAndConditionFilterVM.searchSortCondition = node
                if let node = node, node.rankType != "default" {
                    self?.searchSortBtn?.isSelected = true
                } else {
                    self?.searchSortBtn?.isSelected = false
                }
                if self?.sortPanelView?.isHidden == false {
                    self?.openOrCloseSortPanel()
                }
            }
        }
    }

    init(conditionPanelView: UIControl,
         searchFilterPanel: SearchFilterPanel,
         searchAndConditionFilterVM: SearchAndConditionFilterViewModel) {
        self.conditionPanelView = conditionPanelView
        self.searchAndConditionFilterVM = searchAndConditionFilterVM
        self.searchFilterPanel = searchFilterPanel
        conditionPanelView.rx.controlEvent(.touchUpInside)
                .bind { [unowned self] recognizer in
                    self.setSortBtnSelectedWhenClosePanel()
                    if self.sortPanelView?.isHidden ?? true {
                        // do nothing
                    } else {
                        self.sortPanelView?.isHidden = true
                    }
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
        FHFilterRedDotManager.shared.setSelectedConditions(conditions: items)
        conditionItemViews.forEach { $0.value.setSelectedConditions(conditions: items) }
    }

    func pullConditionsFromPanels(udpateFilterOnly: Bool = false) {
        conditionItemViews
            .sorted(by: { (left, right) -> Bool in
                left.key < right.key
            })
            .enumerated()
            .forEach { [unowned self] (e) in
                let (index, ele) = e
                if let conditionParser = ele.value.conditionParser {
                    let selectedNode = ele.value.selectedNodes()
                    self.searchAndConditionFilterVM.addCondition(index: index,
                                                                 udpateFilterOnly: udpateFilterOnly,
                                                                 condition: conditionParser(selectedNode))
                }
        }
    }

    func openOrCloseSortPanel() {
        self.closeConditionFilterPanel(index: -1)
        setSortBtnSelected()

        if sortPanelView?.isHidden == true {
            self.conditionPanelView?.isHidden = false
            self.sortPanelView?.isHidden = false
        } else {
            self.conditionPanelView?.isHidden = true
            self.sortPanelView?.isHidden = true
        }
    }

    func setSortBtnSelected() {
        let isHidden = self.sortPanelView?.isHidden ?? true
        //当前视图在关闭状态
        if isHidden == true {
            if let sortCondition = self.searchAndConditionFilterVM.searchSortCondition,
                sortCondition.rankType != "default" {
                self.searchSortBtn?.isSelected = true
            }
        } else { //当前视图在打开状态
            setSortBtnSelectedWhenClosePanel()
        }
    }

    fileprivate func setSortBtnSelectedWhenClosePanel() {
        if let sortCondition = self.searchAndConditionFilterVM.searchSortCondition,
            sortCondition.rankType != "default" {
            self.searchSortBtn?.isSelected = true
        } else {
            self.searchSortBtn?.isSelected = false
        }
    }

    func cleanSortCondition() {
        self.searchSortBtn?.isSelected = false
        self.sortPanelView?.removeSelected()
        if sortPanelView?.isHidden == false {
            sortPanelView?.isHidden = true
        }
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
            panel.conditionParser = parseAreaSearchCondition
            panel.conditionLabelParser = parseAreaConditionItemLabel
            panel.conditionLabelSetter = { (nodes) in
                setConditionItemTypeByParser(
                    item: item,
                    reload: reload,
                    parser: { nodes in
                        parseAreaConditionItemLabel(label: categoryName, nodePath: nodes)
                })(nodes)
            }
            conditionItemViews[index] = panel

            return { [weak self, weak panel] (index) in
                if let panel = panel {
                    self?.onOpenConditionPanel(panel: panel, index: index)
                }
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
                    conditionParser: parsePriceSearchCondition)
            }
            let panel = constructPriceBubbleSelectCollectionPanelWithContainer(
                    index: index,
                    nodes: configs,
                    container: containerView!,
                    selectedAction)
            panel.conditionParser = parsePriceSearchCondition
            panel.conditionLabelParser = parseAreaConditionItemLabel
            panel.conditionLabelSetter = { (nodes) in
                setConditionItemTypeByParser(
                    item: item,
                    reload: reload,
                    parser: { nodes in
                        parseAreaConditionItemLabel(label: categoryName, nodePath: nodes)
                })(nodes)
            }
            conditionItemViews[index] = panel
            return { [weak self, weak panel] (index) in
                if let panel = panel {
                    self?.onOpenConditionPanel(panel: panel, index: index)
                }
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
            panel.conditionParser = parseHorseTypeSearchCondition
            panel.conditionLabelParser = parseHorseTypeConditionItemLabel
            panel.conditionLabelSetter = { (nodes) in
                setConditionItemTypeByParser(
                    item: item,
                    reload: reload,
                    parser: { nodes in
                        parseHorseTypeConditionItemLabel(label: categoryName, nodePath: nodes)
                })(nodes)
            }
            conditionItemViews[index] = panel
            return { [weak self, weak panel] (index) in
                if let panel = panel {
                    self?.onOpenConditionPanel(panel: panel, index: index)
                }
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
            panel.conditionParser = parseHorseTypeSearchCondition
            panel.conditionLabelParser = parseMoreConditionItemLabel
            panel.conditionLabelSetter = { (nodes) in
                setConditionItemTypeByParser(
                    item: item,
                    reload: reload,
                    parser: { nodes in
                        parseMoreConditionItemLabel(label: categoryName, nodePath: nodes)
                })(nodes)
            }
            conditionItemViews[index] = panel
            return { [weak self, weak panel] (index) in
                if let panel = panel {
                    self?.onOpenConditionPanel(panel: panel, index: index)
                }
            }
        }
    }

    func onOpenConditionPanel(panel: BaseConditionPanelView, index: Int) {
        self.resetAllSearchFilterPanelState()
        let currentDisplayItem = self.conditionItemViews.first(where: { $0.value.isDisplay })?.value
        if let currentDisplayItem = currentDisplayItem,
            currentDisplayItem != panel {
            currentDisplayItem.onDismiss()
            currentDisplayItem.isHidden = true
        }
        if !panel.isDisplay {
            conditionPanelWillDisplay?()
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
        setSortBtnSelectedWhenClosePanel()
        self.sortPanelView?.isHidden = true
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

        self.searchAndConditionFilterVM.addCondition(index: index, udpateFilterOnly: false, condition: conditionParser(selectedNode))
        setConditionItemTypeByParser(
            item: item,
            reload: reload,
            parser: { nodes in
                conditionLabelParser(categoryName, nodes)
            })(selectedNode)
    }

    func closeConditionFilterPanel(index: Int) {
        if let view  = self.conditionItemViews.first(where: { $0.value.isDisplay })?.value {
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

    func reloadConditionPanel() -> Void {
        searchFilterPanel?.setItems(items: filterConditions)
        self.conditionPanelState.isShowPanel = false
    }
}

func getNoneFilterCondition(params: [String: Any], conditionsKeys: Set<String>) -> [String: Any] {
    return params.filter { !conditionsKeys.contains($0.key) }
}

func getNoneFilterConditionString(params: [String: Any]?, conditionsKeys: Set<String>) -> String {
    guard let params = params else {
        return ""
    }
    let querys = getNoneFilterCondition(params: params, conditionsKeys: conditionsKeys)
    let conditions = querys.reduce("", { (result, value) -> String in
            let condition = convertKeyValueToCondition(key: value.key,
                                                       value: value.value)
                .reduce("", { (result, value) -> String in
                    result + "&\(value)"
                })
            return result + "\(condition)"
        })
    return conditions
}


/// 根据key value 拼接url query parameter
///
/// - Parameters:
///   - key:
///   - value:
/// - Returns:
func convertKeyValueToCondition(key: String, value: Any) -> [String] {
    if let arrays = value as? Array<Any> {
        return arrays.map { e in
            if let value = "\(e)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return "\(key)=\(value)"
            } else {
                return "\(key)=\(e)"
            }
        }
    } else {
        if let valueStr = value as? String,
            let theValue = valueStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return ["\(key)=\(theValue)"]
        } else {
            return ["\(key)=\(value)"]
        }
    }
}

func getAllFilterKeysFromNodes(nodes: [Node]) -> Set<String> {
    return nodes.reduce([], { (result, node) -> Set<String> in
        var theResult = result
        if !node.children.isEmpty {
            let keys = getAllFilterKeysFromNodes(nodes: node.children)
            keys.forEach({ (key) in
                theResult.insert(key)
            })
        }
        if let key = node.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            theResult.insert(key)
        }
        return theResult
    })
}

