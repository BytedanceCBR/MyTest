//
//  ConditionFilterViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation

class ConditionFilterViewModel {


    weak var conditionPanelView: UIView?

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM: SearchAndConditionFilterViewModel

    init(conditionPanelView: UIView,
         searchAndConditionFilterVM: SearchAndConditionFilterViewModel) {
        self.conditionPanelView = conditionPanelView
        self.searchAndConditionFilterVM = searchAndConditionFilterVM
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


    func openConditionPanel(state: ConditionPanelState, apply: @escaping ConditionFilterPanelGenerator) -> (Int) -> Void {
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
        }
    }

    func closeConditionPanel(_ apply: @escaping ConditionSelectAction) -> ConditionSelectAction {
        return { [weak self] (index, nodes) -> Void in
            self?.conditionPanelView?.subviews.forEach { view in
                view.removeFromSuperview()
            }
            self?.conditionPanelView?.isHidden = true
            apply(index, nodes)
            self?.reloadConditionPanel()
        }
    }

    func reloadConditionPanel() -> Void {
//        searchFilterPanel.setItems(items: filterConditions)
        self.conditionPanelState.isShowPanel = false
    }
}
