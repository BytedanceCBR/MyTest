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

            let render = curry(fillSearchInNeighborhoodCollectionCell)(theDatas)(openParams)(navVC)(openParams)
            return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params <|>
                    toTracerParams("rent_detail", key: "page_type") <|>
                    toTracerParams("old", key: "house_type"))],
                sectionTracer: nil,
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
//                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("rent", key: "house_type") <|>
                toTracerParams("rent_detail", key: "page_type") <|>
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
        let url = URL(string: "fschema://rent_detail?house_id=\(houseId)")
        TTRoute.shared()?.openURL(byPushViewController: url)
    }
}

