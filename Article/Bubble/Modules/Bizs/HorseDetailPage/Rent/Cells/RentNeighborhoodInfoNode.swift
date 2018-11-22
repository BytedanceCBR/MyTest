//
//  RentNeighborhoodInfoNode.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNeighborhoodInfoNode() -> () -> TableSectionNode? {
    let render = curry(fillRentNeighborhoodInfoCell)
    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillRentNeighborhoodInfoCell(cell: BaseUITableViewCell) {
    if let theCell = cell as? NeighborhoodInfoCell {
        theCell.starsContainer.isHidden = false
        theCell.starsContainer.updateStarsCount(scoreValue: 50)
        theCell.starsContainer.snp.updateConstraints { maker in
            maker.height.equalTo(50)
        }
    }
}
