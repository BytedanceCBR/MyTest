//
//  DisclaimerCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class DisclaimerCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "DisclaimerCell"
    }

    lazy var contentLabel: YYLabel = {
        let re = YYLabel()
        re.numberOfLines = 0
        re.lineBreakMode = NSLineBreakMode.byWordWrapping
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview().offset(-14)
            maker.right.equalTo(-15)
            maker.height.equalTo(0)
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
    
    func remakeConstraints() {
        let size = contentLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 30, height: 1000))
        contentLabel.snp.updateConstraints { maker in
            maker.height.equalTo(size.height)
        }
    }
}

func parseErshouHouseDisclaimerNode(_ data: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        if data.disclaimer == nil && data.contact == nil {
            return nil
        }
        var contact: FHHouseDetailContact? = nil
        // 当且仅当没有合作经纪人时，才在disclaimer中显示爬取经纪人
        if data.highlightedRealtor == nil {
            contact = data.contact
        }
        let cellRender = curry(fillErshouHouseDisclaimerCell)(data.disclaimer)(contact)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHRentDisclaimerCell.identifier))
    }
}

func fillErshouHouseDisclaimerCell(model: Disclaimer?, contact: FHHouseDetailContact?, cell: BaseUITableViewCell)  {
    if let theCell = cell as? FHRentDisclaimerCell {

        if let disclaimer = model, let text = disclaimer.text {
            let attrText = NSMutableAttributedString(string: text)
            attrText.addAttributes(commonTextStyle(), range: NSRange(location: 0, length: attrText.length))
            disclaimer.richText.forEach { item in
                attrText.yy_setTextHighlight(
                    rangeOfArray(item.highlightRange, originalLength: text.count),
                    color: hexStringToUIColor(hex: "#299cff"),
                    backgroundColor: nil,
                    userInfo: nil,
                    tapAction: { (_, text, range, _) in
                        if let url = item.linkUrl,
                            let theUrl = URL(string: url) {
                            TTRoute.shared().openURL(byPushViewController: theUrl)
                        } else {
                            assertionFailure()
                        }
                },
                    longPressAction: nil)
            }
            theCell.disclaimerContent.attributedText = attrText
            theCell.remakeConstraints()
        }

        if let contact = contact,
            let realtorName = contact.realtorName,
            let agencyName = contact.agencyName {
            if !realtorName.isEmpty || !agencyName.isEmpty {
                theCell.displayOwnerLabel()
                var tempName = ""
                if !realtorName.isEmpty {
                    tempName = realtorName
                    if !agencyName.isEmpty {
                        tempName += " | \(agencyName)"
                    }
                } else if !agencyName.isEmpty {
                    tempName = agencyName
                }
                theCell.ownerLabel.text = "房源维护方：\(tempName)"
                var headerImages = [FHRentDetailResponseDataHouseImageModel]()
                if let businessLicense = contact.businessLicense,
                    !businessLicense.isEmpty {
                    let imageModel = FHRentDetailResponseDataHouseImageModel()
                    imageModel.url = businessLicense
                    imageModel.name = "营业执照"
                    headerImages.append(imageModel)
                }
                if let certificate = contact.certificate,
                    !certificate.isEmpty {
                    let imageModel = FHRentDetailResponseDataHouseImageModel()
                    imageModel.url = certificate
                    imageModel.name = "从业人员信息卡"
                    headerImages.append(imageModel)
                }
                if headerImages.count > 0 {
                    theCell.headerImages = headerImages
                    theCell.contactIcon.isHidden = false
                    theCell.contactIcon.snp.updateConstraints { (maker) in
                        maker.right.lessThanOrEqualTo(-20)
                    }
                } else {
                    theCell.contactIcon.isHidden = true
                    theCell.contactIcon.snp.updateConstraints { (maker) in
                        maker.right.lessThanOrEqualTo(10)
                    }
                }
            } else {
                theCell.hiddenOwnerLabel()
            }
        } else {
            theCell.hiddenOwnerLabel()
        }
    }
}

func parseDisclaimerNode() -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillDisclaimerCell)(nil)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: DisclaimerCell.identifier))
    }
}


func parseDisclaimerNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillDisclaimerCell)(newHouseData.disclaimer)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: DisclaimerCell.identifier))
    }
}

func fillDisclaimerCell(disclaimer: Disclaimer?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? DisclaimerCell {
        theCell.contentLabel.text = disclaimer?.text
        if let disclaimer = disclaimer, let text = disclaimer.text {
            let attrText = NSMutableAttributedString(string: text)
            attrText.addAttributes(commonTextStyle(), range: NSRange(location: 0, length: attrText.length))
            disclaimer.richText.forEach { item in
                attrText.yy_setTextHighlight(
                    rangeOfArray(item.highlightRange, originalLength: text.count),
                    color: hexStringToUIColor(hex: "#299cff"),
                    backgroundColor: nil,
                    userInfo: nil,
                    tapAction: { (_, text, range, _) in
                        if let url = item.linkUrl,
                            let theUrl = URL(string: url) {
                            TTRoute.shared().openURL(byPushViewController: theUrl)
                        } else {
                            assertionFailure()
                        }
                    },
                    longPressAction: nil)

            }
            
            theCell.contentLabel.attributedText = attrText
            theCell.remakeConstraints()
        }
    }
}

fileprivate func rangeOfArray(_ range: [Int]?, originalLength: Int) -> NSRange {
    if let range = range, range.count == 2 {
        if originalLength > range[0] && originalLength > range[1] && range[1] > range[0] {
            return NSRange(location: range[0], length: range[1] - range[0])
        } else {
            return NSRange(location: 0, length: 0)
        }
    } else {
        return NSRange(location: 0, length: 0)
    }

}

fileprivate func highLightTextStyle() -> [NSAttributedStringKey: Any] {
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#f85959"),
//            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.patternSolid,
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(12)]
}

fileprivate func commonTextStyle() -> [NSAttributedStringKey: Any] {
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHCoolGrey2Color),
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(12)]
}
