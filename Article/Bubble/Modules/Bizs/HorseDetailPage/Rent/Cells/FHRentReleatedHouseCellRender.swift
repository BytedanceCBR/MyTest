//
//  FHRentReleatedHouseCellRender.swift
//  Article
//
//  Created by leo on 2018/11/22.
//

import Foundation
import RxSwift
func parseRentReleatedHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        var traceParmas = tracerParams.paramsGetter([:])
        var elementFrom: String = "related"
        if let elementFromV = (traceParmas["element_from"] ?? elementFrom) as? String
        {
            elementFrom = elementFromV
        }

        let selectors = data?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                return openErshouHouseDetailPage(
                    houseId: Int64(item.id ?? "")!,
                    logPB: item.logPB,
                    disposeBag: disposeBag,
                    tracerParams: tracerParams <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                        //                    toTracerParams("maintab", key: "enter_from") <|>
                        toTracerParams(elementFrom, key: "element_from") <|>
                        toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                    navVC: navVC)
        }

        let paramsElement = TracerParams.momoid() <|>
            toTracerParams("related", key: "element_type") <|>
            toTracerParams("rent_detail", key: "page_type") <|>
        traceExtension

        var records = data?
            .filter {
                $0.id != nil
            }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from"))
        }
        records?.insert(elementShowOnceRecord(params:paramsElement), at: 0)

        let count = data?.count ?? 0
        if let renders = data?.enumerated().map({ (index, item) in
            data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
        }), let selectors = selectors ,count != 0 {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: nil,
                label: "",
                type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
        } else {
            return nil
        }
    }
}
