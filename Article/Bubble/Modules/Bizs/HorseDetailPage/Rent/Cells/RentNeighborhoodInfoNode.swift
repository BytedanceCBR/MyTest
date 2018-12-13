//
//  RentNeighborhoodInfoNode.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation


func parseRentNeighborhoodInfoNode(model: FHRentDetailResponseModel?,
                                   tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let render = curry(fillRentNeighborhoodInfoCell)(model?.data?.neighborhoodInfo)(tracer)
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

func fillRentNeighborhoodInfoCell(neighborhoodInfo: FHRentDetailResponseDataNeighborhoodInfoModel?, tracer: HouseRentTracer, cell: BaseUITableViewCell) {
    if let theCell = cell as? NeighborhoodInfoCell {
        if let evaluationInfo = neighborhoodInfo?.evaluationInfo {
            theCell.starsContainer.isHidden = false
            theCell.starsContainer.updateStarsCount(scoreValue: evaluationInfo.totalScore)
            theCell.starsContainer.snp.updateConstraints { maker in
                maker.height.equalTo(50)
            }
            theCell.nameKey.snp.remakeConstraints { (maker) in
                maker.left.equalTo(theCell.leftMarge)
                maker.top.equalTo(theCell.starsContainer.snp.bottom)
                maker.height.equalTo(20)
            }
        } else {
            theCell.starsContainer.isHidden = true
            theCell.starsContainer.snp.updateConstraints { maker in
                maker.height.equalTo(0)
            }
            theCell.nameKey.snp.remakeConstraints { (maker) in
                maker.left.equalTo(theCell.leftMarge)
                maker.top.equalTo(10)
                maker.height.equalTo(20)
            }
        }
        theCell.nameValue.text = neighborhoodInfo?.areaName
        
        var imprId: String? = "be_null"
        var groupId: String? = "be_null"
        if let logpbV = tracer.logPb as? [String : Any]
        {
            imprId = logpbV["impr_id"] as? String
            groupId = logpbV["group_id"] as? String
        }
        
        
        theCell.tracerParams = TracerParams.momoid() <|>
            toTracerParams(tracer.groupId ?? "be_null", key: "group_id") <|>
            toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
            toTracerParams("rent_detail", key: "enter_from") <|>
            toTracerParams(imprId ?? "be_null", key: "impr_id") <|>
            toTracerParams(groupId ?? "be_null", key: "group_id") <|>
            toTracerParams(tracer.searchId ?? "be_null", key: "search_id")
        
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
            if theCell.lat == nil {
                theCell.setLocation(lat: lat, lng: lng)
                theCell.lat = lat
                theCell.lng = lng
            }
        }
        if let schoolName = neighborhoodInfo?.schoolInfo?.schoolName {
            theCell.schoolLabel.text = schoolName
            theCell.schoolLabelIsHidden(isHidden: false)
        } else {
            theCell.schoolLabelIsHidden(isHidden: true)
        }
    }
}
