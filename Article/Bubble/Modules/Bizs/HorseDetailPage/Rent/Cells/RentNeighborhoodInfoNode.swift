//
//  RentNeighborhoodInfoNode.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNeighborhoodInfoNode(tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let render = curry(fillRentNeighborhoodInfoCell)
    let params = EnvContext.shared.homePageParams <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("neighborhood_detail", key: "element_type") <|>
        toTracerParams(tracer.pageType, key: "page_type")
    let tracerEvaluationRecord = elementShowOnceRecord(params: params)
    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:[tracerEvaluationRecord],
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
