//
//  RentNameCellRender.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNameCellNode() -> () -> TableSectionNode? {
    let cellRender = oneTimeRender(curry(fillRentNameCell))
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            label: "",
            type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillRentNameCell(cell: BaseUITableViewCell) -> Void {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }
    theCell.bottomLine.isHidden = true
    theCell.nameLabel.text = "合租 | 西三旗 富力桃园 2室1厅"
    let tags:[NSAttributedString] = ["新上", "立刻入住"].map({ (item) -> NSAttributedString in
        createTagAttributeTextNormal(content: item)
    })
    theCell.setAlias(alias: nil)
    theCell.setTags(tags: tags)
}
