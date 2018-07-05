//
// Created by linlin on 2018/6/14.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import BDWebImage
import YYText
import CoreGraphics
class SingleImageInfoCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "BaseUITableViewCell"
    }

    var imageRequest: BDWebImageRequest?

    lazy var majorImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: "#222222")
        return label
    }()

    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#505050")
        return label
    }()

    lazy var areaLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: "#f85959")
        return label
    }()

    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#999999")
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(majorImageView)

        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
        }

        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(16)
            maker.bottom.equalToSuperview().offset(-16)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        majorImageView.image = #imageLiteral(resourceName: "house-1")

        let infoPanel = UIView()
        self.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(5)
            maker.top.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }

        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(23)
            maker.top.equalToSuperview().offset(13)
        }

        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { [unowned majorTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }

        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { [unowned extendTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.width.greaterThanOrEqualTo(100)
            maker.height.equalTo(15)
        }
        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { [unowned areaLabel] maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }


        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { [unowned priceLabel] maker in
            maker.left.equalTo(priceLabel.snp.right).offset(5)
            maker.top.equalTo(priceLabel.snp.top)
            maker.height.equalTo(17)
        }
    }

    func setImageByUrl(_ url: String) {
        imageRequest = majorImageView.bd_setImage(with: URL(string: url))
    }

    override func prepareForReuse() {
        imageRequest?.cancel()
        imageRequest = nil
    }
}

func fillHouseItemToCell(_ cell: SingleImageInfoCell, item: HouseItemInnerEntity) {
    cell.majorTitle.text = item.displayTitle
    cell.extendTitle.text = item.displaySubtitle
    let text = NSMutableAttributedString()

    let attributeText = createTagAttrString("新房一天")
    text.append(attributeText)
    text.append(attributeText)
    text.append(attributeText)
    text.append(attributeText)
    cell.areaLabel.attributedText = text;
//    cell.areaLabel.sizeToFit()

    cell.priceLabel.text = item.baseInfoMap?.pricing
    cell.roomSpaceLabel.text = item.baseInfoMap?.pricingPerSqm
    if let img = item.houseImage?.first , let url = img.url {
        cell.setImageByUrl(url)
    }

}

func createTagAttrString(
    _ text: String,
    textColor: UIColor = hexStringToUIColor(hex: "#f85959"),
    backgroundColor: UIColor = color(248, 89, 89, 0.08)) -> NSMutableAttributedString {
    let attributeText = NSMutableAttributedString(string: text)
    attributeText.yy_insertString("  ", at: 0)
    attributeText.yy_appendString("  ")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(10)
    attributeText.yy_color = textColor
    let substringRange = attributeText.string.range(of: text)
    if let lowerBound = substringRange?.lowerBound,
        let upperBound = substringRange?.upperBound {
        let start = attributeText.string.distance(from: attributeText.string.startIndex, to: (lowerBound))
        let length = attributeText.string.distance(from: lowerBound, to: upperBound)
        let range = NSMakeRange(start, length)
        attributeText.yy_setTextBinding(YYTextBinding(deleteConfirm: false), range: range)

        let border = YYTextBorder()
        border.strokeWidth = 1.5
        border.fillColor = backgroundColor
        border.cornerRadius = 2
        border.lineJoin = CGLineJoin.bevel

        border.insets = UIEdgeInsets(top: -2, left: -5, bottom: -2, right: -5)
        attributeText.yy_setTextBackgroundBorder(border, range: range)
    }
    return attributeText
}


