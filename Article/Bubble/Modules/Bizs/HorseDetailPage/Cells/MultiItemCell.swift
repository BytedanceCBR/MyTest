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
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: "#e8e8e8").cgColor
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
        re.textColor = hexStringToUIColor(hex: "#999999")
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
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.width.equalTo(156)
            maker.height.equalTo(116)
            maker.top.equalToSuperview()
        }

        addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.height.equalTo(22)
            maker.top.equalTo(icon.snp.bottom).offset(9)
        }

        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(4)
            maker.height.equalTo(22)
            maker.top.equalTo(descLabel.snp.bottom).offset(3)
        }

        addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(6)
            maker.right.equalToSuperview().offset(-4)
            maker.height.equalTo(22)
            maker.centerY.equalTo(priceLabel.snp.centerY)
            maker.bottom.equalToSuperview()
        }
        addGestureRecognizer(tapGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NeighborhoodItemView: UIView {
    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: "#e8e8e8").cgColor
        return re
    }()

    lazy var descLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: "#222222")
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
        re.textColor = hexStringToUIColor(hex: "#999999")
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
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.width.equalTo(156)
            maker.height.equalTo(116)
            maker.top.equalToSuperview()
        }

        addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.height.equalTo(22)
            maker.top.equalTo(icon.snp.bottom).offset(10)
        }

        addSubview(spaceLabel)
        spaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.height.equalTo(17)
            maker.top.equalTo(descLabel.snp.bottom).offset(4)
        }

        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(4)
            maker.right.equalToSuperview().offset(-4)
            maker.height.equalTo(22)
            maker.top.equalTo(spaceLabel.snp.bottom).offset(4)
            maker.bottom.equalToSuperview()

        }
        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

func parseRelateCourtNode(_ data: RelatedCourtResponse?, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.data?.items?.take(5), datas.count > 0 {
            let render = curry(fillSearchInNeighborhoodCell)(datas)(navVC)
            return TableSectionNode(items: [render], selectors: nil, label: "猜你喜欢", type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

func fillSearchInNeighborhoodCell(items: [CourtItemInnerEntity], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = items.map { item -> FloorPanItemView in
            let re = generateearchInNeighborhoodItemView(item)
            re.tapGesture.rx.event
                    .subscribe(onNext: { [unowned re] recognizer in
                        if let id = item.id, let houseId = Int64(id) {
                            openNewHouseDetailPage(houseId: houseId, disposeBag: re.disposeBag, navVC: navVC)()
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

func parseSearchInNeighborhoodNode(_ data: HouseItemEntity?, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.items?.take(5), datas.count > 0 {
            let render = curry(fillSearchInNeighborhoodCell)(datas)(navVC)
            return TableSectionNode(items: [render], selectors: nil, label: "小区房源", type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

func fillSearchInNeighborhoodCell(items: [HouseItemInnerEntity], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = items.map { item -> FloorPanItemView in
            let re = generateearchInNeighborhoodItemView(item)
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let houseId = Int64(id) {
                        openErshouHouseDetailPage(houseId: houseId, disposeBag: re.disposeBag, navVC: navVC)()
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
    if let urlStr = item.courtImage?.first?.url {
        re.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
    }
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: "#222222")
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
    if let urlStr = item.houseImage?.first?.url {
        re.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
    }
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: "#222222")
    text.append(attributeText)

    re.descLabel.attributedText = text
    re.priceLabel.text = item.displayPrice
    re.spaceLabel.text = item.displayPricePerSqm
    return re
}


func parseRelatedNeighborhoodNode(_ datas: [NeighborhoodInnerItemEntity]?, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = datas, datas.count > 0 {
            let render = curry(fillRelatedNeighborhoodCell)(datas)(navVC)
            return TableSectionNode(items: [render], selectors: nil, label: "周边小区", type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

func fillRelatedNeighborhoodCell(datas: [NeighborhoodInnerItemEntity], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = datas.take(5).map { item -> NeighborhoodItemView in
            let re = generateRelatedNeighborhoodView(item)
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let houseId = Int64(id) {
                        openNeighborhoodDetailPage(neighborhoodId: houseId, disposeBag: re.disposeBag, navVC: navVC)()
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
    if let urlStr = item.images?.first?.url {
        re.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
    }
    re.descLabel.text = item.displayTitle
    re.priceLabel.text = item.displayPricePerSqm
    re.spaceLabel.text = item.displayBuiltYear
    return re
}

func parseFloorPanNode(_ newHouseData: NewHouseData, navVC: UINavigationController?) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillFloorPanCell)(newHouseData.floorPan?.list ?? [])(navVC)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "楼盘户型", type: .node(identifier: MultiItemCell.identifier))
    }
}

func fillFloorPanCell(_ data: [FloorPan.Item], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = data.take(5).map { item -> FloorPanItemView in
            let re = generateFloorPanItemView(item)
            re.tapGesture.rx.event
                .subscribe(onNext: { [unowned re] recognizer in
                    if let id = item.id, let floorPanId = Int64(id) {
                        openFloorPanCategoryDetailPage(floorPanId: floorPanId, disposeBag: re.disposeBag, navVC: navVC)()
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

func generateFloorPanItemView(_ item: FloorPan.Item) -> FloorPanItemView {
    let re = FloorPanItemView()
    if let urlStr = item.images?.first?.url {
        re.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
    }
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.title ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: "#222222")
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
    re.spaceLabel.text = item.squaremeter
    return re
}

func parseFloorPanNode(_ items: [FloorPlanInfoData.Recommend]?, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let items = items {
            let cellRender = curry(fillFloorPanCell)(items)(navVC)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "楼盘户型", type: .node(identifier: MultiItemCell.identifier))
        } else {
            return nil
        }
    }
}

func fillFloorPanCell(_ data: [FloorPlanInfoData.Recommend], navVC: UINavigationController?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = data.take(5).map { item -> FloorPanItemView in
            let re = generateFloorPanItemView(item)
            re.tapGesture.rx.event
                    .subscribe(onNext: { [unowned re] recognizer in
                        if let id = item.id, let floorPanId = Int64(id) {
                            openFloorPanCategoryDetailPage(floorPanId: floorPanId, disposeBag: re.disposeBag, navVC: navVC)()
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

func generateFloorPanItemView(_ item: FloorPlanInfoData.Recommend) -> FloorPanItemView {
    let re = FloorPanItemView()
    if let urlStr = item.images?.first?.url {
        re.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
    }
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
