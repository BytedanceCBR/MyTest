//
//  RentCycleImageCellRender.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation
import RxSwift
import RxCocoa
func parseRentHouseCycleImageNode(_ images: [FHRentDetailResponseDataHouseImageModel]?,
                                  tracer: HouseRentTracer,
                                  disposeBag: DisposeBag) -> () -> TableSectionNode? {
    var imprId: String? = "be_null"
    var groupId: String? = "be_null"
    
    if let logPB = tracer.logPb as? [String: Any]
    {
        imprId = logPB["impr_id"] as? String
        groupId = logPB["group_id"] as? String
    }
    
    let params = TracerParams.momoid() <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams(tracer.pageType, key: "page_type")  <|>
        toTracerParams(tracer.searchId ?? "be_null", key: "search_id")  <|>
        toTracerParams(groupId, key: "group_id") <|>
        toTracerParams(tracer.originFrom ?? "be_null", key: "origin_from") <|>
        toTracerParams(tracer.originSearchId ?? "be_null", key: "origin_search_id") <|>
        toTracerParams(imprId, key: "impr_id")
    
    let cellRender = curry(fillRentHouseCycleImageCell)(images ?? [])(disposeBag)(params.exclude("search_id"))
    return {
        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: CycleImageCell.identifier))
    }
}


func fillRentHouseCycleImageCell(_ images: [FHRentDetailResponseDataHouseImageModel],
                                 disposeBag: DisposeBag,
                                 traceParams: TracerParams,
                                 cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        theCell.traceParams = traceParams
        theCell.count = images.count
        theCell.smallTracer = theCell.rentSmallImageTracerGen(images: images, traceParams: traceParams)
        theCell.headerImages = images.map { item in
            let model = ImageModel(url: item.url ?? "", category: "")
            return model
        }
    }
}
