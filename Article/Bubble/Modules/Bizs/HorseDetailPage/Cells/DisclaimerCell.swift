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
        re.font = CommonUIStyle.Font.pingFangRegular(13)
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
        let cellRender = curry(fillDisclaimerCell)(data.disclaimer)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: DisclaimerCell.identifier))
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
                    rangeOfArray(item.highlightRange),
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

func rangeOfArray(_ range: [Int]?) -> NSRange {
    if let range = range, range.count == 2 {
        return NSRange(location: range[0], length: range[1] - range[0])
    } else {
        return NSRange(location: 0, length: 0)
    }

}

func highLightTextStyle() -> [NSAttributedStringKey: Any] {
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#f85959"),
//            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.patternSolid,
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(13)]
}

fileprivate func commonTextStyle() -> [NSAttributedStringKey: Any] {
    return [NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHCoolGrey2Color),
            NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(13)]
}
