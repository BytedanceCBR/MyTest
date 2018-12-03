//
//  RentNeighborhoodInfoNode.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNeighborhoodInfoNode(model: FHRentDetailResponseModel?,
                                   tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let render = curry(fillRentNeighborhoodInfoCell)(model?.data?.neighborhoodInfo)
    let params = EnvContext.shared.homePageParams <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("neighborhood_detail", key: "element_type") <|>
        toTracerParams(tracer.pageType, key: "page_type") <|>
        toTracerParams("rent_detail", key: "enter_from")
    
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

func fillRentNeighborhoodInfoCell(neighborhoodInfo: FHRentDetailResponseDataNeighborhoodInfoModel?, cell: BaseUITableViewCell) {
    if let theCell = cell as? NeighborhoodInfoCell {
        if let evaluationInfo = neighborhoodInfo?.evaluationInfo {
            theCell.starsContainer.isHidden = false
            theCell.starsContainer.updateStarsCount(scoreValue: evaluationInfo.totalScore)
        } else {
            theCell.starsContainer.isHidden = true
        }
        theCell.nameValue.text = neighborhoodInfo?.areaName
        theCell.starsContainer.snp.updateConstraints { maker in
            maker.height.equalTo(50)
        }
        theCell.neighborhoodId = neighborhoodInfo?.id
        theCell.name = neighborhoodInfo?.name
        if let detailUrl = neighborhoodInfo?.evaluationInfo?.detailUrl,
            !detailUrl.isEmpty {
            theCell.detailUrl = detailUrl
            theCell.bgView.isHidden = false
        } else {
            theCell.bgView.isHidden = true
        }
        if let lat = neighborhoodInfo?.gaodeLat,
            let lng = neighborhoodInfo?.gaodeLng {
            theCell.setLocation(lat: lat, lng: lng)
            theCell.lat = lat
            theCell.lng = lng
        }
        if let schoolName = neighborhoodInfo?.schoolInfo?.schoolName {
            theCell.schoolLabel.text = schoolName
            theCell.schoolLabelIsHidden(isHidden: false)
        } else {
            theCell.schoolLabelIsHidden(isHidden: true)
        }
    }
}
