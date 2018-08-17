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
class ConditionFilterViewModel {


    weak var conditionPanelView: UIView?

    weak var searchFilterPanel: SearchFilterPanel?

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM: SearchAndConditionFilterViewModel

    lazy var filterConditions: [SearchConditionItem] = {
        []
    }()

    let disposeBag = DisposeBag()

    init(conditionPanelView: UIControl,
         searchFilterPanel: SearchFilterPanel,
         searchAndConditionFilterVM: SearchAndConditionFilterViewModel) {
        self.conditionPanelView = conditionPanelView
        self.searchAndConditionFilterVM = searchAndConditionFilterVM
        self.searchFilterPanel = searchFilterPanel
        conditionPanelView.rx.controlEvent(.touchUpInside)
                .bind { [unowned self] recognizer in
                    self.dissmissConditionPanel()
                }
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
        let categoryName = item.label
        switch item.itemId {
        case 1:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructAreaConditionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                    var conditions = self.searchAndConditionFilterVM.conditionTracer.value
                    conditions[index] = nodes
                    self.searchAndConditionFilterVM.conditionTracer.accept(conditions)

                    self.searchAndConditionFilterVM.addCondition(index: index, condition: parseAreaSearchCondition(nodePath: nodes))
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: curry(parseAreaConditionItemLabel)(categoryName))(nodes)
                }))
        case 2:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructPriceListConditionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                    var conditions = self.searchAndConditionFilterVM.conditionTracer.value
                    conditions[index] = nodes
                    self.searchAndConditionFilterVM.conditionTracer.accept(conditions)

                    self.searchAndConditionFilterVM.addCondition(index: index, condition: parseAreaSearchCondition(nodePath: nodes))
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: curry(parsePriceConditionItemLabel)(categoryName))(nodes)
                }))
        case 3:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructBubbleSelectCollectionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                    var conditions = self.searchAndConditionFilterVM.conditionTracer.value
                    conditions[index] = nodes
                    self.searchAndConditionFilterVM.conditionTracer.accept(conditions)

                    self.searchAndConditionFilterVM.addCondition(index: index, condition: parseHorseTypeSearchCondition(nodePath: nodes))
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: curry(parseHorseTypeConditionItemLabel)(categoryName))(nodes)
                }))
        default:
            return openConditionPanel(
                state: self.conditionPanelState,
                apply: constructMoreSelectCollectionPanel(nodes: configs, self.closeConditionPanel { (index, nodes) in
                    var conditions = self.searchAndConditionFilterVM.conditionTracer.value
                    conditions[index] = nodes
                    self.searchAndConditionFilterVM.conditionTracer.accept(conditions)

                    self.searchAndConditionFilterVM.addCondition(index: index, condition: parseHorseTypeSearchCondition(nodePath: nodes))
                    setConditionItemTypeByParser(
                        item: item,
                        reload: reload,
                        parser: curry(parseMoreConditionItemLabel)(categoryName))(nodes)
                }))
        }
    }


    func openConditionPanel(
            state: ConditionPanelState,
            apply: @escaping ConditionFilterPanelGenerator) -> (Int) -> Void {
        return { [weak self] (index) in
            if state.isShowPanel, state.currentIndex == index {
                self?.conditionPanelView?.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                self?.conditionPanelView?.isHidden = true
                state.isShowPanel = false
            } else if state.isShowPanel, state.currentIndex != index {
                self?.conditionPanelView?.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                apply(index, self?.conditionPanelView)
                state.isShowPanel = true
            } else if state.isShowPanel != true {
                apply(index, self?.conditionPanelView)
                self?.conditionPanelView?.isHidden = false
                state.isShowPanel = true
            }
            state.currentIndex = index
            self?.searchFilterPanel?.items.forEach({ (item) in
                item.isExpand = false
                item.isHighlighted = item.isSeted
            })

            if let items = self?.searchFilterPanel?.items, items.count > index {
                items[index].isHighlighted = state.isShowPanel || items[index].isSeted
                items[index].isExpand = state.isShowPanel
            }
            self?.searchFilterPanel?.refresh()
        }
    }

    private func closeConditionPanel(_ apply: @escaping ConditionSelectAction) -> ConditionSelectAction {
        return { [weak self] (index, nodes) -> Void in
            apply(index, nodes)
            self?.closeConditionPanel()
        }
    }

    private func closeConditionPanel() {
        self.conditionPanelView?.subviews.forEach { view in
            view.removeFromSuperview()
        }
        self.conditionPanelView?.isHidden = true
        self.reloadConditionPanel()
    }

    func dissmissConditionPanel() {
        if let item = searchFilterPanel?.selectedItem() {
            item.isExpand = false
            if !item.isSeted {
                item.isHighlighted = false
            }
        }

        self.closeConditionPanel()
    }

    func reloadConditionPanel() -> Void {
        searchFilterPanel?.setItems(items: filterConditions)
        self.conditionPanelState.isShowPanel = false
    }
}
