//
//  MultiItemCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MultiItemCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "MultiItemCell"
    }

    lazy var groupView: UIScrollView = {
        let result = UIScrollView()
        result.contentInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        result.showsHorizontalScrollIndicator = false
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(groupView)
        groupView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        groupView.subviews.forEach { view in
            view.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

class FloorPanItemView: UIView {

    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        re.image = #imageLiteral(resourceName: "default_image")
        return re
    }()

    lazy var descLabel: YYLabel = {
        let re = YYLabel()
        return re
    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var spaceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(icon)
        icon.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.width.equalTo(156)
            maker.height.equalTo(116)
            maker.top.equalToSuperview()
        }

        addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(22)
            maker.top.equalTo(icon.snp.bottom).offset(9)
        }

        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.height.equalTo(22)
            maker.top.equalTo(descLabel.snp.bottom).offset(3)
        }

        addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(6)
            maker.right.equalToSuperview()
            maker.height.equalTo(22)
            maker.centerY.equalTo(priceLabel.snp.centerY)
            maker.bottom.equalToSuperview()
        }
//        addGestureRecognizer(tapGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NeighborhoodEvaluationItem: UIView
{
    lazy var backView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.backgroundColor = hexStringToUIColor(hex: kFHClearGreyColor)
        return re
    }() 
    
    lazy var descLabel: YYLabel = {
        let re = YYLabel() 
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHBattleShipGreyColor)
        return re
    }()
    
    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()
    
    lazy var scoreLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHBattleShipGreyColor)
        return re
    }()
    
    lazy var levelLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = UIColor.white
        re.textAlignment = .center
        re.backgroundColor = hexStringToUIColor(hex: kFHCoralColor)
        re.layer.masksToBounds = true
        re.layer.cornerRadius = 4.0
        return re
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()
    
    let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(backView)
        
        backView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.width.equalTo(140)
            maker.height.equalTo(122)
            maker.top.equalToSuperview()
        }
        
        backView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.top.equalToSuperview().offset(12)
            maker.height.equalTo(22)
            maker.width.equalTo(70)
        }
        
        backView.addSubview(levelLabel)
        levelLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.height.width.equalTo(22)
            maker.top.equalTo(nameLabel)
        }
        
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        backView.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { maker in
            maker.right.equalTo(levelLabel.snp.left).offset(-9)
            maker.height.equalTo(22)
            maker.top.equalTo(nameLabel)
        }
        
        backView.addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.top.equalTo(nameLabel.snp.bottom).offset(4)
            maker.left.equalTo(nameLabel)
            maker.right.bottom.equalToSuperview().offset(-10)
        }
        
        descLabel.backgroundColor = UIColor.clear
        descLabel.numberOfLines = 4
        descLabel.sizeToFit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class NeighborhoodItemView: UIView {
    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        return re
    }()

    lazy var descLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var spaceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#ffffff")
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(icon)
        icon.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.width.equalTo(156)
            maker.height.equalTo(116)
            maker.top.equalToSuperview()
        }

        addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(22)
            maker.top.equalTo(icon.snp.bottom).offset(10)
        }

        addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { maker in
            maker.height.equalTo(17)
            maker.right.equalToSuperview().offset(-6)
            maker.bottom.equalTo(icon.snp.bottom).offset(-6)
        }

        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(22)
            maker.top.equalTo(descLabel.snp.bottom)
            maker.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

func parseRelateCourtNode(
    _ data: RelatedCourtResponse?,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.data?.items?.take(5), datas.count > 0 {
            
            let theDatas = datas.map({ (item) -> CourtItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = data?.searchId
                return newItem
            })
            let params = TracerParams.momoid() <|>
                toTracerParams("related", key: "element_type")
            let render = curry(fillSearchInNeighborhoodCell)(theDatas)(params)(navVC)

            return TableSectionNode(
                    items: [render],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params:params)],
                    label: "猜你喜欢",
                    type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCell(
    items: [CourtItemInnerEntity],
    params: TracerParams,
    navVC: UINavigationController?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = items
            .enumerated()
            .map { (e) -> FloorPanItemView in
            let (offset, item) = e
            let re = generateearchInNeighborhoodItemView(item)
            let theParams = params <|>
                toTracerParams("related", key: "element_type") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id")
                
                re.tapGesture.rx.event
                    .subscribe(onNext: { [unowned re] recognizer in
                        if let id = item.id, let houseId = Int64(id) {
                            openNewHouseDetailPage(
                                houseId: houseId,
                                logPB: item.logPB as? [String: Any],
                                disposeBag: re.disposeBag,
                                tracerParams: theParams  <|>
                                    toTracerParams(offset, key: "rank"),
                                navVC: navVC)(TracerParams.momoid())
                        }
                    })
                    .disposed(by: re.disposeBag)
            return re
        }

        views.forEach { view in
            theCell.groupView.addSubview(view)
        }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        views.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
        if let view = views.last {
            theCell.groupView.snp.makeConstraints { [unowned view] maker in
                maker.height.equalTo(view.snp.height).offset(16)
            }
        }
    }
}

func parseSearchInNeighborhoodNode(
    _ data: SameNeighborhoodHouseResponse.Data?,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.items.take(5), datas.count > 0 {
            let theDatas = datas.map({ (item) -> HouseItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = data?.searchId
                return newItem
            })
            let params = TracerParams.momoid() <|>
                toTracerParams("same_neighborhood", key: "element_type")

            let openParams = params <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("old_detail", key: "enter_from") <|>
                toTracerParams("old_detail", key: "element_from")

            let render = curry(fillSearchInNeighborhoodCell)(theDatas)(openParams)(navVC)
            return TableSectionNode(
                    items: [render],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    label: "小区房源",
                    type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCell(
    items: [HouseItemInnerEntity],
    params: TracerParams,
    navVC: UINavigationController?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = items
            .enumerated()
            .map { (e) -> FloorPanItemView in
            let (offset, item) = e
            let re = generateearchInNeighborhoodItemView(item)
            let theParams = params <|>
                toTracerParams("slide", key: "card_type") <|>
                params
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let houseId = Int64(id) {
                        openErshouHouseDetailPage(
                            houseId: houseId,
                            disposeBag: re.disposeBag,
                            tracerParams: theParams <|>
                                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                                toTracerParams(offset, key: "rank"),
                            navVC: navVC)(TracerParams.momoid())
                    }
                })
                .disposed(by: re.disposeBag)
            return re
        }

        views.forEach { view in
            theCell.groupView.addSubview(view)
        }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        views.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
        if let view = views.last {
            theCell.groupView.snp.makeConstraints { [unowned view] maker in
                maker.height.equalTo(view.snp.height).offset(16)
            }
        }
    }
}

func generateearchInNeighborhoodItemView(_ item: CourtItemInnerEntity) -> FloorPanItemView {
    let re = FloorPanItemView()
    re.icon.bd_setImage(with: URL(string: item.courtImage?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
    text.append(attributeText)

    if let status = item.tags?.first {
        let tag = createTagAttributeText(
                content: status.content,
                textColor: hexStringToUIColor(hex: status.textColor),
                backgroundColor: hexStringToUIColor(hex: status.backgroundColor),
                insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
        tag.yy_baselineOffset = 2
        text.append(tag)
    }

    re.descLabel.attributedText = text
    re.priceLabel.text = item.displayPricePerSqm
    return re
}


func generateearchInNeighborhoodItemView(_ item: HouseItemInnerEntity) -> FloorPanItemView {
    let re = FloorPanItemView()
    re.icon.bd_setImage(with: URL(string: item.houseImage?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
    text.append(attributeText)
    re.descLabel.attributedText = text
    re.priceLabel.text = item.displayPrice
    re.spaceLabel.text = item.displayPricePerSqm

    return re
}

//func parseRelatedNeighborhoodNode(_ datas: [NeighborhoodInnerItemEntity]?, navVC: UINavigationController?) -> () -> TableSectionNode? {
//    return {
//        if let datas = datas, datas.count > 0 {
//
//            let render = curry(fillRelatedNeighborhoodCell)(datas)(navVC)
//            let params = TracerParams.momoid() <|>
//                    toTracerParams("slide", key: "card_type") <|>
//                    toTracerParams("neighborhood_nearby", key: "element_type")
//            return TableSectionNode(
//                    items: [render],
//                    selectors: nil,
//                    tracer: [elementShowOnceRecord(params: params)],
//                    label: "周边小区",
//                    type: .node(identifier: MultiItemCell.identifier))
//        } else {
//            return nil
//        }
//    }
//}

fileprivate func fillRelatedNeighborhoodCell(datas: [NeighborhoodInnerItemEntity], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = datas.take(5)
            .enumerated()
            .map { (e) -> NeighborhoodItemView in
            let (offset, item) = e
            let re = generateRelatedNeighborhoodView(item)
            let params = TracerParams.momoid() <|>
                toTracerParams("neighborhood_nearby", key: "element_type") <|>
                toTracerParams("neighborhood_nearby", key: "element_from") <|>
                toTracerParams("left_pic", key: "card_type")
                
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let houseId = Int64(id) {
                        openNeighborhoodDetailPage(
                            neighborhoodId: houseId,
                            logPB: item.logPB,
                            disposeBag: re.disposeBag,
                            tracerParams: params <|>
                                toTracerParams(item.logPB ?? [:], key: "log_pb") <|>
                                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                                toTracerParams(offset, key: "rank"),
                            navVC: navVC)(TracerParams.momoid())
                    }
                })
                .disposed(by: re.disposeBag)
            return re
        }
        views.forEach { view in
            theCell.groupView.addSubview(view)
        }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        views.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
        if let view = views.last {
            theCell.groupView.snp.makeConstraints { [unowned view] maker in
                maker.height.equalTo(view.snp.height).offset(16)
            }
        }
    }
}


func generateRelatedNeighborhoodView(_ item: NeighborhoodInnerItemEntity) -> NeighborhoodItemView {
    let re = NeighborhoodItemView()
    re.icon.bd_setImage(with: URL(string: item.images?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
    re.descLabel.text = item.displayTitle
    re.priceLabel.text = item.displayPricePerSqm
    re.spaceLabel.text = item.displayBuiltYear
    return re
}


fileprivate func fillFloorPanCell(
        _ data: [FloorPan.Item],
        logPBVC: Any?,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = data.take(5)
            .map { item -> FloorPanItemView in
            let re = generateFloorPanItemView(item)
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let floorPanId = Int64(id) {
                        
                        followPage.accept("house_model_detail")

                        openFloorPanCategoryDetailPage(
                                floorPanId: floorPanId,
                                logPbVC: logPBVC,
                                disposeBag: re.disposeBag,
                                navVC: navVC,
                                followPage: followPage,
                                bottomBarBinder: bottomBarBinder)()
                    }
                })
                .disposed(by: re.disposeBag)
            return re
        }
        views.forEach { view in
            theCell.groupView.addSubview(view)
        }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        views.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
        if let view = views.last {
            theCell.groupView.snp.makeConstraints { [unowned view] maker in
                maker.height.equalTo(view.snp.height).offset(16)
            }
        }
    }
}

fileprivate func generateFloorPanItemView(_ item: FloorPan.Item) -> FloorPanItemView {
    let re = FloorPanItemView()
    re.icon.bd_setImage(with: URL(string: item.images?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.title ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
    text.append(attributeText)

    if let status = item.saleStatus {
        let tag = createTagAttributeText(
                content: status.content,
                textColor: hexStringToUIColor(hex: status.textColor),
                backgroundColor: hexStringToUIColor(hex: status.backgroundColor),
                insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
        tag.yy_baselineOffset = 2
        text.append(tag)
    }

    re.descLabel.attributedText = text
    re.priceLabel.text = item.pricingPerSqm
    if let squaremeter = item.squaremeter {
        
        re.spaceLabel.text = "建面 \(squaremeter)"
    }
    return re
}


fileprivate func generateFloorPanItemView(_ item: FloorPlanInfoData.Recommend) -> FloorPanItemView {
    let re = FloorPanItemView()
    re.icon.bd_setImage(with: URL(string: item.images?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.title ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: "#222222")
    text.append(attributeText)

//    if let status = item.saleStatus, let content = status.content {
//        let tag = createTagAttributeText(
//                content: content,
//                textColor: hexStringToUIColor(hex: "#33bf85"),
//                backgroundColor: hexStringToUIColor(hex: "#33bf85", alpha: 0.08),
//                insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
//        tag.yy_baselineOffset = 2
//        text.append(tag)
//    }

    re.descLabel.attributedText = text
    re.priceLabel.text = item.pricingPerSqm
    re.spaceLabel.text = item.squaremeter
    return re
}
