//
//  RentCoreInfoCellRender.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation

func parseRentCoreInfoCellNode() -> () -> TableSectionNode? {
    let cellRender = curry(fillRentCoreInfoCell)
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            label: "",
            type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
    }
}

func fillRentCoreInfoCell(cell: BaseUITableViewCell) {
    if let theCell = cell as? ErshouHouseCoreInfoCell {
        let re = HorseCoreInfoItemView()
        re.keyLabel.text = "93457元/月"
        re.valueLabel.text = "押一付三"
        let re1 = HorseCoreInfoItemView()
        re1.keyLabel.text = "2室1厅"
        re1.valueLabel.text = "房型"
        let re2 = HorseCoreInfoItemView()
        re2.keyLabel.text = "20平"
        re2.valueLabel.text = "共90平"
        theCell.setItem(items: [re, re1, re2])
    }
}
