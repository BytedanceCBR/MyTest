//
// Created by linlin on 2018/6/14.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import CoreGraphics

class CornerView: UIView {

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: [UIRectCorner.topLeft,
                                UIRectCorner.bottomRight],
            cornerRadii: CGSize(width: 4, height: 4))
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = maskPath.cgPath
        self.layer.mask = layer
    }

}

@objc class SingleImageInfoCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "BaseUITableViewCell"
    }

    var isFirstCell: Bool {
        didSet {
            
            if headView.superview == nil {
                return
            }
            let height = isFirstCell ? 0 : 20
            headView.snp.updateConstraints { maker in
                maker.height.equalTo(height)
            }
        }
        
    }
    
    override var isTail: Bool {
        didSet {

            if bottomView.superview == nil {
                return
            }
            let height = isTail ? 20 : 0
            bottomView.snp.updateConstraints { maker in
                maker.height.equalTo(height)
            }
        }
    }

    lazy var majorImageView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        return re
    }()

    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return label
    }()

    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "737a80")
        return label
    }()

    lazy var areaLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: kFHCoralColor)
        return label
    }()
    
    lazy var originPriceLabel: StrickoutLabel = {
        let label = StrickoutLabel()
        if TTDeviceHelper.isScreenWidthLarge320() {
            label.font = CommonUIStyle.Font.pingFangRegular(12)
        } else {
            label.font = CommonUIStyle.Font.pingFangRegular(10)
        }
        
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        label.isHidden = true
        return label
    }()
    
    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        if TTDeviceHelper.isScreenWidthLarge320() {
            label.font = CommonUIStyle.Font.pingFangRegular(12)
        } else {
            label.font = CommonUIStyle.Font.pingFangRegular(10)
        }
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return label
    }()

    lazy var headView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var imageTopLeftLabel: UILabel = {
        let re = UILabel()
        re.text = "新上"
        re.textAlignment = .center
        re.textColor = UIColor.white
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        return re
    }()

    lazy var imageTopLeftLabelBgView: CornerView = {
        let re = CornerView()
        re.backgroundColor = hexStringToUIColor(hex: "#ff5b4c")
        re.isHidden = true
        return re
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        isFirstCell = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isTail = false
        self.contentView.addSubview(headView)
        headView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        self.contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
            maker.top.equalTo(105)
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(10)
        }
        
        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.top.equalTo(headView.snp.bottom)
//            maker.bottom.equalTo(bottomView.snp.top)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }

        let infoPanel = UIView()
        contentView.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(15)
            maker.top.equalTo(majorImageView)
            maker.bottom.equalTo(bottomView.snp.top)
            maker.right.equalToSuperview().offset(-15)
        }

        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(16)
        }

        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(8)
            maker.height.equalTo(17)

        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.height.equalTo(15)
            
        }

        infoPanel.addSubview(priceLabel)
        infoPanel.addSubview(roomSpaceLabel)
        infoPanel.addSubview(originPriceLabel)

        priceLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(24)
            maker.width.lessThanOrEqualTo(130)
        }
        
        originPriceLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(priceLabel.snp.right).offset(6)
            maker.height.equalTo(17)
            maker.centerY.equalTo(priceLabel)
        }
        
        roomSpaceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        roomSpaceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(7)
            maker.centerY.equalTo(priceLabel)
            maker.height.equalTo(17)
        }

        contentView.addSubview(imageTopLeftLabelBgView)
        imageTopLeftLabelBgView.snp.makeConstraints { (maker) in
            maker.left.equalTo(majorImageView.snp.left).offset(0)
            maker.top.equalTo(majorImageView.snp.top)
            maker.height.equalTo(17)
            maker.width.equalTo(48)
        }

        imageTopLeftLabelBgView.addSubview(imageTopLeftLabel)
        imageTopLeftLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(1)
            maker.right.equalTo(-1)
            maker.center.equalToSuperview()
        }
    }
    
    func updateOriginPriceLabelConstraints(originPriceText:String?)
    {
        if let text = originPriceText, text.count > 0 {
            let offset:CGFloat = TTDeviceHelper.isScreenWidthLarge320() ? 20 : 15
            originPriceLabel.isHidden = false
            originPriceLabel.text = text
            originPriceLabel.snp.remakeConstraints { (maker) in
                maker.left.equalTo(priceLabel.snp.right).offset(6)
                maker.height.equalTo(17)
                maker.centerY.equalTo(priceLabel)
            }
            roomSpaceLabel.snp.remakeConstraints { maker in
                maker.left.equalTo(originPriceLabel.snp.right).offset(offset)
                maker.centerY.equalTo(priceLabel)
                maker.height.equalTo(17)
            }
        } else {
            originPriceLabel.isHidden = true
            roomSpaceLabel.snp.remakeConstraints { maker in
                maker.left.equalTo(priceLabel.snp.right).offset(7)
                maker.centerY.equalTo(priceLabel)
                maker.height.equalTo(17)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTopLeftLabelBgView.isHidden = true
    }
    
    override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

func fillHouseItemToCell(_ cell: SingleImageInfoCell,
                         isLastCell: Bool = false,
                         item: HouseItemInnerEntity) {
    cell.majorTitle.text = item.displayTitle
    cell.extendTitle.text = item.displaySubtitle
    cell.isTail = isLastCell

    let text = NSMutableAttributedString()
    let attrTexts = item.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
        createTagAttrString(
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
    
    cell.areaLabel.attributedText = text
    cell.areaLabel.snp.updateConstraints { (maker) in
        
        maker.left.equalToSuperview().offset(-3)
    }
    cell.priceLabel.text = item.baseInfoMap?.pricing

    cell.roomSpaceLabel.text = item.baseInfoMap?.pricingPerSqm
    cell.majorImageView.bd_setImage(with: URL(string: item.houseImage?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))

    cell.updateOriginPriceLabelConstraints(originPriceText: item.originPrice)
    //新上/降价

}

func createTagAttrString(
    _ text: String,
    isFirst: Bool = false,
    textColor: UIColor = hexStringToUIColor(hex: "#f85959"),
    backgroundColor: UIColor = color(248, 89, 89, 0.08)) -> NSMutableAttributedString {
    let attributeText = NSMutableAttributedString(string: "  \(text)  ")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(10)
    attributeText.yy_color = textColor
    let substringRange = attributeText.string.range(of: text)
    if let lowerBound = substringRange?.lowerBound,
        let upperBound = substringRange?.upperBound {
        let start = attributeText.string.distance(from: attributeText.string.startIndex, to: (lowerBound))
        let length = attributeText.string.distance(from: lowerBound, to: upperBound)
        let range = NSMakeRange(start, length)
        attributeText.yy_setTextBinding(YYTextBinding(deleteConfirm: false), range: range)

        let border = YYTextBorder.init(fill: backgroundColor, cornerRadius: 2)
        border.insets = UIEdgeInsets(top: 0, left: -3, bottom:  0, right: -3)

        attributeText.yy_setTextBackgroundBorder(border, range: range)
    }
    return attributeText
}


extension SingleImageInfoCell : FHHouseSingleImageInfoCellBridgeDelegate{    
    @objc func update(with model: FHSearchHouseDataItemsModel , isLastCell: Bool) {
        
        let cell = self
        let item = model
        cell.majorTitle.text = model.displayTitle
        cell.extendTitle.text = model.displaySubtitle
        cell.isTail = isLastCell
        
        let text = NSMutableAttributedString()
        if let tags = item.tags as? [FHSearchHouseDataItemsTagsModel] {
           let  attrTexts = tags.enumerated().map ({ (arg) -> NSAttributedString  in
                let (offset, element) = arg
                return createTagAttrString(
                    element.content ?? "",
                    isFirst: offset == 0,
                    textColor: hexStringToUIColor(hex: element.textColor),
                    backgroundColor: hexStringToUIColor(hex: element.backgroundColor))
            })
            
            var height: CGFloat = 0
            attrTexts.enumerated().forEach({ (e) in
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
        }
        
        cell.areaLabel.attributedText = text
        cell.areaLabel.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(-3)
        }
        cell.priceLabel.text = item.displayPrice
        
        cell.roomSpaceLabel.text = item.displayPricePerSqm
        let houseImags  = item.houseImage as? [FHSearchHouseDataItemsHouseImageModel]
        cell.majorImageView.bd_setImage(with: URL(string: houseImags?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        if let houseImageTag = item.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            cell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            cell.imageTopLeftLabel.text = houseImageTag.text
            cell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            cell.imageTopLeftLabelBgView.isHidden = false
        } else {
            cell.imageTopLeftLabelBgView.isHidden = true
        }
        cell.updateOriginPriceLabelConstraints(originPriceText: item.originPrice)
    }
    
    @objc func update(withSecondHouseModel model: FHSearchHouseDataItemsModel, isFirstCell: Bool, isLastCell: Bool) {
        
        let cell = self
        let item = model
        cell.majorTitle.text = model.displayTitle
        cell.extendTitle.text = model.displaySubtitle
        cell.isTail = isLastCell
        cell.isFirstCell = isFirstCell

        let text = NSMutableAttributedString()
        if let tags = item.tags as? [FHSearchHouseDataItemsTagsModel] {
            let  attrTexts = tags.enumerated().map ({ (arg) -> NSAttributedString  in
                let (offset, element) = arg
                return createTagAttrString(
                    element.content ?? "",
                    isFirst: offset == 0,
                    textColor: hexStringToUIColor(hex: element.textColor),
                    backgroundColor: hexStringToUIColor(hex: element.backgroundColor))
            })
            
            var height: CGFloat = 0
            attrTexts.enumerated().forEach({ (e) in
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
        }
        
        cell.areaLabel.attributedText = text
        cell.areaLabel.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(-3)
        }
        cell.priceLabel.text = item.displayPrice
        
        cell.roomSpaceLabel.text = item.displayPricePerSqm
        let houseImags  = item.houseImage as? [FHSearchHouseDataItemsHouseImageModel]
        cell.majorImageView.bd_setImage(with: URL(string: houseImags?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        if let houseImageTag = item.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            cell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            cell.imageTopLeftLabel.text = houseImageTag.text
            cell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            cell.imageTopLeftLabelBgView.isHidden = false
        } else {
            cell.imageTopLeftLabelBgView.isHidden = true
        }
        cell.updateOriginPriceLabelConstraints(originPriceText: item.originPrice)
    }
    
    @objc func update(withNewHouseModel model: FHNewHouseItemModel, isFirstCell: Bool,  isLastCell: Bool) {
 
        let cell = self
        let item = model
        cell.majorTitle.text = model.displayTitle
        cell.extendTitle.text = model.displayDescription
        cell.isTail = isLastCell
        cell.isFirstCell = isFirstCell

        let text = NSMutableAttributedString()
        if let tags = item.tags as? [FHNewHouseItemTagsModel] {
            let  attrTexts = tags.enumerated().map ({ (arg) -> NSAttributedString  in
                let (offset, element) = arg
                return createTagAttrString(
                    element.content ?? "",
                    isFirst: offset == 0,
                    textColor: hexStringToUIColor(hex: element.textColor),
                    backgroundColor: hexStringToUIColor(hex: element.backgroundColor))
            })
            
            var height: CGFloat = 0
            attrTexts.enumerated().forEach({ (e) in
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
        }
        
        cell.areaLabel.attributedText = text
        cell.areaLabel.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(-3)
        }
        cell.priceLabel.text = item.displayPricePerSqm
        cell.roomSpaceLabel.text = ""
        let houseImags  = model.images as? [FHNewHouseItemImagesModel]
        cell.majorImageView.bd_setImage(with: URL(string: houseImags?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        cell.updateOriginPriceLabelConstraints(originPriceText: nil)
    }
    
    @objc
    func update(withRentHouseModel model: FHHouseRentDataItemsModel, isFirstCell : Bool ,isLastCell: Bool) {
        
        let cell = self
//        let item = model
        cell.majorTitle.text = model.title
        cell.extendTitle.text = model.subtitle
        cell.isTail = isLastCell
        cell.isFirstCell = isFirstCell
        
        let text = NSMutableAttributedString()
        if let tags = model.tags as? [FHHouseRentDataItemsTagsModel] {
            let  attrTexts = tags.enumerated().map ({ (arg) -> NSAttributedString  in
                let (offset, element) = arg
                return createTagAttrString(
                    element.content ?? "",
                    isFirst: offset == 0,
                    textColor: hexStringToUIColor(hex: element.textColor),
                    backgroundColor: hexStringToUIColor(hex: element.backgroundColor))
            })
            
            var height: CGFloat = 0
            attrTexts.enumerated().forEach({ (e) in
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
        }
        
        cell.areaLabel.attributedText = text
        cell.areaLabel.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(-3)
        }
        cell.priceLabel.text = model.pricing
        
        cell.roomSpaceLabel.text = nil
        let houseImags  = model.houseImage as? [FHSearchHouseDataItemsHouseImageModel]
        cell.majorImageView.bd_setImage(with: URL(string: houseImags?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        if let houseImageTag = model.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            cell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            cell.imageTopLeftLabel.text = houseImageTag.text
            cell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            cell.imageTopLeftLabelBgView.isHidden = false
        } else {
            cell.imageTopLeftLabelBgView.isHidden = true
        }
        cell.updateOriginPriceLabelConstraints(originPriceText: nil)        
    }
    
    
}

@objc
class StrickoutLabel: UILabel {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        self.textColor.setStroke()

        context?.setLineWidth(1)
        let y = self.frame.height / 2
        context?.move(to: CGPoint(x:0,y:y))
        
        let size = self.sizeThatFits(CGSize(width:100,height:17))
        
        context?.addLine(to: CGPoint(x:size.width,y:y))
        context?.strokePath()
    }
}
