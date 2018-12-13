//
//  CategoryRentListViewModel.swift
//  Article
//
//  Created by 谷春晖 on 2018/11/26.
//

import UIKit
import RxSwift
import RxCocoa

//class CategoryRentListViewModel: NSObject {
//
//}

func parseRentHouseListRowItemNode(
    _ data: [RentInnerItemEntity]?,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>? = nil,
    houseSearchParams: TracerParams?,
    navVC: UINavigationController?) -> [TableRowNode] {
    // 租房列表
//    var traceDict = traceParams.paramsGetter([:])
//    print("trace dict is: \(traceDict)")
    
    
    let params = traceParams <|>
        toTracerParams("rent", key: "house_type") <|>
        toTracerParams("left_pic", key: "card_type")
    let selectors = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> (TracerParams) -> Void in
            let (_, item) = e
            return openRentHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                logPB: item.logPB,
                followStatus: sameNeighborhoodFollowUp,
                disposeBag: disposeBag,
                tracerParams: params <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    //修复租房周边房源element_from应该上报related
//                    toTracerParams("be_null", key: "element_from") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                houseSearchParams: houseSearchParams,
                navVC: navVC)
            // <|>
            //                    toTracerParams("related_list", key: "enter_from"),
    }
    
    let records = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (index, item) = e
            let theParams = params <|>
                toTracerParams(index, key: "rank") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                //                toTracerParams("be_null", key: "element_type") <|>
                toTracerParams("rent", key: "house_type")
            return onceRecord(key: TraceEventName.house_show, params: theParams
                .exclude("element_from")
                .exclude("enter_from")
                .exclude("enter_from"))
    }
    let count = data?.count ?? 0
    if let renders = data?.enumerated().map( { (index, item) in
        curry(fillRentHouseListitemCell)(item)(index == count - 1)
    }),
        let selectors = selectors,
        let records = records {
        let items = zip(selectors, records)
        
        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                tracer: item.1,
                type: .node(identifier: SingleImageInfoCell.identifier),
                editor: nil)
        }
    } else {
        return []
    }
}

func fillRentHouseListitemCell(_ data: RentInnerItemEntity,
                                 isLastCell: Bool = false,
                                 cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.title
        theCell.extendTitle.text = data.subtitle
        theCell.isTail = isLastCell
        
        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
            return createTagAttrString(
                item.content,
                isFirst: offset == 0,
                textColor: hexStringToUIColor(hex: item.textColor),
                backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
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
        theCell.roomSpaceLabel.text = nil  //data.displayPricePerSqm
        theCell.majorImageView.bd_setImage(with: URL(string: data.houseImage?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
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
        theCell.updateOriginPriceLabelConstraints(originPriceText: nil )
        theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
    }
}


func openRentHouseDetailPage(
    houseId: Int64,
    logPB: [String: Any]? = nil,
    followStatus: BehaviorRelay<Result<Bool>>? = nil,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    houseSearchParams: TracerParams? = nil,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    return { (params) in
        var tracer: [String: Any?] = tracerParams.paramsGetter([:])
//        var houseSearchDict : [String : Any]? = nil
        if let houseSearchParams = houseSearchParams?.paramsGetter([:]) {
//            houseSearchDict = houseSearchParams
            tracer.merge(houseSearchParams, uniquingKeysWith: { (left, right) -> Any? in
                right
            })
        }
        if let paramsDict: [String: Any?] = params.paramsGetter([:]) {
            tracer.merge(paramsDict, uniquingKeysWith: { (left, right) -> Any? in
                right
            })
        }
        //修复二手房相关房源go_detail买点不能报be_null
//        tracer["element_from"] = "be_null"
        tracer["card_type"] = "left_pic"
        tracer["log_pb"] = logPB

//        var info = ["tracer": tracer]
//        if let hsp = houseSearchDict  {
//            info["house_search_params"] = hsp
//        }
//

        let info = ["tracer": tracer, "is_from_search": true] as [String : Any]

        let userInfo = TTRouteUserInfo(info: info)
        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(houseId)"), userInfo: userInfo)
    }
}
