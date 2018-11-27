//
//  RentNameCellRender.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNameCellNode(model: FHRentDetailResponseDataModel?) -> () -> TableSectionNode? {
    let cellRender = oneTimeRender(curry(fillRentNameCell)(model))
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillRentNameCell(model: FHRentDetailResponseDataModel?, cell: BaseUITableViewCell) -> Void {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }
    theCell.bottomLine.isHidden = true
    theCell.nameLabel.text = model?.title
    let tags:[NSAttributedString] = ["新上", "立刻入住"].map({ (item) -> NSAttributedString in
        createTagAttributeTextNormal(content: item)
    })
    theCell.setAlias(alias: nil)
    theCell.setTags(tags: tags)
}
