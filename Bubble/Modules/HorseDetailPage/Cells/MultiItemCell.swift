//
//  MultiItemCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import BDWebImage
import YYText

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
            maker.bottom.equalToSuperview().offset(-16)
            maker.height.equalTo(172)
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
        UIImageView()
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseFloorPanNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillFloorPanCell)(newHouseData.floorPan?.list ?? [])
        return TableSectionNode(items: [cellRender], label: "楼盘户型", type: .node(identifier: MultiItemCell.identifier))
    }
}

func fillFloorPanCell(_ data: [FloorPan.Item], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultiItemCell {
        let views = data.map { item in
            generateFloorPanItemView(item)
        }
        views.forEach { view in
            theCell.groupView.addSubview(view)
         }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
    }
}

func generateFloorPanItemView(_ item: FloorPan.Item) -> FloorPanItemView {
    let re = FloorPanItemView()
    if let urlStr = item.images?.first?.url {
        re.icon.bd_setImage(with:  URL(string: urlStr))
    }
    let text = NSMutableAttributedString()
    let attributeText = NSMutableAttributedString(string: item.title ?? "")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
    attributeText.yy_color = hexStringToUIColor(hex: "#222222")
    text.append(attributeText)

    if let status = item.saleStatus, let content = status.content {
        let tag = createTagAttributeText(
            content: content,
            textColor: hexStringToUIColor(hex: "#33bf85"),
            backgroundColor: hexStringToUIColor(hex: "#33bf85", alpha: 0.08),
            insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
        tag.yy_baselineOffset = 2
        text.append(tag)
    }

    re.descLabel.attributedText = text
    re.priceLabel.text = item.pricingPerSqm
    re.spaceLabel.text = item.squaremeter
    return re
}
