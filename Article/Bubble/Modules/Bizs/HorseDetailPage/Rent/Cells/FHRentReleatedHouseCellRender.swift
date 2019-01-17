//
//  FHRentReleatedHouseCellRender.swift
//  Article
//
//  Created by leo on 2018/11/22.
//

import Foundation
import RxSwift
func parseRentReleatedHouseListItemNode(
    _ data: [FHHouseRentRelatedResponseDataItemsModel]?,
    tracer: HouseRentTracer,
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
                return { (params) in
                    if let houseId = item.id {
                        var tracerRoute = tracerParams.paramsGetter([:])
                        tracerRoute["card_type"] = "left_pic"
                        tracerRoute["enter_from"] = "rent_detail"
                        tracerRoute["element_from"] = "related"
                        tracerRoute["origin_from"] = tracer.originFrom ?? "be_null"
                        tracerRoute["origin_search_id"] = tracer.originSearchId ?? "be_null"
                        tracerRoute["rank"] = offset
                        tracerRoute["log_pb"] = item.logPb
                        let info = ["tracer": tracerRoute]
                        let userInfo = TTRouteUserInfo(info: info)
                        let url = URL(string: "fschema://rent_detail?house_id=\(houseId)")
                        TTRoute.shared()?.openURL(byPushViewController: url, userInfo: userInfo)
                    }
               }
        }

        let paramsElement = TracerParams.momoid() <|>
            toTracerParams("related", key: "element_type") <|>
            toTracerParams(tracer.rank, key: "rank") <|>
            toTracerParams(tracer.originFrom ?? "be_null", key: "origin_from") <|>
            toTracerParams(tracer.originSearchId ?? "be_null", key: "origin_search_id") <|>
            toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
            toTracerParams("rent_detail", key: "page_type") <|>
            traceExtension

        let records = data?
            .filter {
                $0.id != nil
            }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams("rent", key: "house_type") <|>
                    toTracerParams("left_pic", key: "card_type") <|>
                    toTracerParams("rent_detail", key: "page_type") <|>
                    toTracerParams("related", key: "element_type") <|>
                    toTracerParams(tracer.originFrom ?? "be_null", key: "origin_from") <|>
                    toTracerParams(tracer.originSearchId ?? "be_null", key: "origin_search_id") <|>
                    searchIdTraceParam(item.logPb) <|>
                    imprIdTraceParam(item.logPb) <|>
                    groupIdTraceParam(item.logPb) <|>
                    toTracerParams(item.logPb as? [String : Any] ?? "be_null", key: "log_pb")
                return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from"))
        }
        let sectionRecord = elementShowOnceRecord(params:paramsElement)

        let count = data?.count ?? 0
        if let renders = data?.enumerated().map({ (arg) -> (BaseUITableViewCell) -> Void in

            let (index, item) = arg
            return curry(fillRentHouseListitemCell)(item)(index == count - 1)
        }), let selectors = selectors ,count != 0 {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: sectionRecord,
                label: "",
                type: .node(identifier:SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillRentHouseListitemCell(_ data: FHHouseRentRelatedResponseDataItemsModel,
                                 isLastCell: Bool = false,
                                 cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.title;
        theCell.extendTitle.text = data.subtitle;
        theCell.isTail = isLastCell

        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.enumerated().map({ (arg) -> NSAttributedString in
            let (offset, item) = arg
            let theItem = item as? FHHouseRentRelatedResponseDataItemsTagsModel
            return createTagAttrString(
                theItem?.content ?? "",
                isFirst: offset == 0,
                textColor: hexStringToUIColor(hex: theItem?.textColor ?? ""),
                backgroundColor: hexStringToUIColor(hex: theItem?.backgroundColor ?? ""))
        })

        var height: CGFloat = 0
        attrTexts?.enumerated().forEach({ (e) in
            let (offset, tag) = e

            text.append(tag)

            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 170, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        })

        theCell.areaLabel.attributedText = text
        theCell.areaLabel.snp.updateConstraints { (maker) in

            maker.left.equalToSuperview().offset(-3)
        }

        theCell.priceLabel.text = data.pricing
        if let imageItem = data.houseImage?.first as? FHHouseRentRelatedResponseDataItemsHouseImageModel {
            theCell.majorImageView.bd_setImage(with: URL(string: imageItem.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        }
        if let houseImageTag = data.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            theCell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            theCell.imageTopLeftLabel.text = houseImageTag.text
            theCell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            theCell.imageTopLeftLabelBgView.isHidden = false
        } else {
            theCell.imageTopLeftLabelBgView.isHidden = true
        }
        theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
    }
}
