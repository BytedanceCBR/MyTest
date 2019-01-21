//
//  FHRentSearchInNeighborhoodNode.swift
//  NewsLite
//
//  Created by leo on 2018/11/22.
//

import Foundation
import RxSwift


func parseRentSearchInNeighborhoodNode(
    _ data: FHRentSameNeighborhoodResponseDataModel?,
    tracer: HouseRentTracer,
    traceExtension: TracerParams = TracerParams.momoid(),
    navVC: UINavigationController?,
    tracerParams: TracerParams) -> () -> TableSectionNode? {
    return {
        if let datas = data?.items?.take(5), datas.count > 0 {

            let theDatas = datas as? [FHRentSameNeighborhoodResponseDataItemsModel]

            let params = TracerParams.momoid() <|>
                toTracerParams("same_neighborhood", key: "element_type") <|>
            traceExtension

            let openParams = params <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("rent_detail", key: "enter_from") <|>
                toTracerParams("same_neighborhood", key: "element_from")

            let sectionParms = params <|>
                toTracerParams(tracer.rank, key: "rank") <|>
                toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
                toTracerParams("same_neighborhood", key: "element_type") <|>
                toTracerParams(tracer.originFrom ?? "be_null", key: "origin_from") <|>
                toTracerParams(tracer.originSearchId ?? "be_null", key: "origin_search_id") <|>
                toTracerParams(tracer.pageType, key: "page_type")


            let render = curry(fillSearchInNeighborhoodCollectionCell)(theDatas)(openParams)(navVC)(openParams)
            let sectionRecord = elementShowOnceRecord(params: sectionParms)
            return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer: nil,
                sectionTracer: sectionRecord,
                label: "小区房源",
                type: .node(identifier: MultitemCollectionCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCollectionCell(
    items: [FHRentSameNeighborhoodResponseDataItemsModel]?,
    params: TracerParams,
    navVC: UINavigationController?,
    itemTracerParams: TracerParams,
    cell: BaseUITableViewCell) {
    if let theCell = cell as? MultitemCollectionCell {
        theCell.itemReuseIdentifier = "floorPan"
        theCell.collectionViewCellRenders = items?.take(5).map({ (entity) -> CollectionViewCellRender in
            curry(fillSearchInNeighborhoodItemCell)(entity)(itemTracerParams)
        }) ?? []
        theCell.itemSelectors = items?.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(searchInNeighborhoodItemCellSelector)(offset)(item)(itemTracerParams)(navVC)
            } ?? []

        theCell.itemRecorders = items?.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("rent", key: "house_type") <|>
                toTracerParams("rent_detail", key: "page_type") <|>
                toTracerParams(item.searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.imprId ?? "be_null", key: "impr_id") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams("same_neighborhood", key: "element_type")
            return onceRecord(key: "house_show", params: params.exclude("enter_from").exclude("element_from"))
            } ?? []
    }
}

fileprivate func fillSearchInNeighborhoodItemCell(
    item: FHRentSameNeighborhoodResponseDataItemsModel,
    itemTracerParams: TracerParams,
    cell: UICollectionViewCell) {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let url = (item.houseImage?.first as? FHRentSameNeighborhoodResponseDataItemsHouseImageModel)?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            theCell.floorPanItemView.icon.image = #imageLiteral(resourceName: "default_image")
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: item.title ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = item.pricing
//        theCell.floorPanItemView.spaceLabel.text = item.
    }
}

fileprivate func searchInNeighborhoodItemCellSelector(
    offset: Int,
    item: FHRentSameNeighborhoodResponseDataItemsModel,
    itemTracerParams: TracerParams,
    navVC: UINavigationController?,
    disposeBag: DisposeBag) {
    if let id = item.id, let houseId = Int64(id) {
        var tracer = itemTracerParams.paramsGetter([:])
        tracer["card_type"] = "left_pic"
        tracer["enter_from"] = "rent_detail"
        tracer["element_from"] = "same_neighborhood"
        tracer["element_type"] = "be_null"
        tracer["rank"] = offset
        tracer["log_pb"] = item.logPb
        let info = ["tracer": tracer]
        let userInfo = TTRouteUserInfo(info: info)
        let url = URL(string: "fschema://rent_detail?house_id=\(houseId)")
        TTRoute.shared()?.openURL(byPushViewController: url, userInfo: userInfo)
    }
}

