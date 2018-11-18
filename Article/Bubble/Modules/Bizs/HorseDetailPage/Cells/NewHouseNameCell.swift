//
//  NewHouseNameCell.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class NewHouseNameCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NewHouseNameCell"
    }

    lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(24)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        result.numberOfLines = 2
        return result
    }()

    lazy var aliasLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#a1aab3")
        result.text = "别名"
        result.textAlignment = .left
        return result
    }()

    lazy var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        return result
    }()

    lazy var tagsView: YYLabel = {
        let result = YYLabel()
        result.numberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return result
    }()
    
    lazy var bottomLine: UIView = {
        let re = UIView(frame: CGRect.zero)
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()

    let leftMerge: CGFloat = 20
    let rightMerge: CGFloat = -20

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(leftMerge)
            maker.right.equalToSuperview().offset(rightMerge)
            maker.top.equalToSuperview().offset(25)
        }

        contentView.addSubview(aliasLabel)
        aliasLabel.snp.makeConstraints { maker in
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.left.equalTo(nameLabel.snp.left)
            maker.height.equalTo(0)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(aliasLabel)
            maker.left.equalTo(aliasLabel.snp.right).offset(4)
            maker.height.equalTo(0)
        }

        contentView.addSubview(tagsView)
        tagsView.snp.makeConstraints { maker in
            maker.top.equalTo(aliasLabel.snp.bottom).offset(4)
            maker.left.equalTo(nameLabel.snp.left)
            maker.bottom.equalToSuperview().offset(-16)
            maker.width.equalToSuperview().offset(-30)
        }
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(UIScreen.main.scale == 3 ? 0.34 : 0.5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTags(tags: [NSAttributedString]) {
        let text = NSMutableAttributedString()
        var height: CGFloat = 0
        let dotAttributedString = createTagAttributeTextNormal(content: " · ")
        tags.enumerated().forEach { (e) in
            let (offset, tag) = e
            if offset > 0 {
                text.append(dotAttributedString)
            }
            text.append(tag)
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            // 只显示一行
            if lineHeight > height {
                if offset == 0 {
                    height = lineHeight
                } else {
                    // 删除： · tag
                    if text.length - (tag.length + 3) >= 0 {
                       text.deleteCharacters(in: NSRange(location: text.length - (tag.length + 3), length: tag.length + 3))
                    }
                }
            }
        }

        tagsView.attributedText = text
    }

    func setAlias(alias: String? = nil) {
        if let alias = alias, !alias.isEmpty {
            secondaryLabel.text = alias

            aliasLabel.snp.updateConstraints { maker in
                maker.height.equalTo(17)
            }
            secondaryLabel.snp.updateConstraints { maker in
                maker.height.equalTo(17)
            }
            tagsView.snp.updateConstraints { maker in
                maker.top.equalTo(aliasLabel.snp.bottom).offset(10)
            }
            aliasLabel.isHidden = false
            secondaryLabel.isHidden = false

        } else {
            aliasLabel.snp.updateConstraints { maker in
                maker.height.equalTo(0)
            }
            secondaryLabel.snp.updateConstraints { maker in
                maker.height.equalTo(0)
            }
            tagsView.snp.updateConstraints { maker in
                maker.top.equalTo(aliasLabel.snp.bottom).offset(-2)
            }
            aliasLabel.isHidden = true
            secondaryLabel.isHidden = true

        }
    }

}

func parseNewHouseNameNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillNewHouseNameCell)(newHouseData)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillNewHouseNameCell(_ newHouseData: NewHouseData, cell: BaseUITableViewCell) {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }

    theCell.bottomLine.isHidden = false
    theCell.nameLabel.text = newHouseData.coreInfo?.name
    theCell.setAlias(alias: newHouseData.coreInfo?.aliasName)
    var tags: [NSAttributedString] = []

    if let tgs = newHouseData.tags {
        tgs.map { (item) in
            createTagAttributeTextNormal(content: item.content)
        }.forEach { item in
            tags.append(item)
        }
    }
    theCell.setTags(tags: tags)
    theCell.layoutIfNeeded()

}

func parseErshouHouseNameNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillErshouHouseNameCell)(ershouHouseData)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillErshouHouseNameCell(_ ershouHouseData: ErshouHouseData, cell: BaseUITableViewCell) {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }
    theCell.bottomLine.isHidden = true
    theCell.nameLabel.text = ershouHouseData.title
    let tags = ershouHouseData.tags.map({ (item) -> NSAttributedString in
        createTagAttributeTextNormal(content: item.content)
    })
    theCell.setAlias(alias: nil)
    theCell.setTags(tags: tags)
    theCell.layoutIfNeeded()

}

func createTagAttributeTextNormal(content:String, fontSize:CGFloat = 12.0) -> NSMutableAttributedString {
    let attributeText = NSMutableAttributedString(string: content)
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(fontSize)
    attributeText.yy_color = hexStringToUIColor(hex: kFHCoolGrey2Color)
    attributeText.yy_lineSpacing = 2
    attributeText.yy_lineHeightMultiple = 0
    attributeText.yy_maximumLineHeight = 0
    attributeText.yy_minimumLineHeight = 20
    return attributeText
}

func createTagAttributeText(
        content: String,
        textColor: UIColor,
        backgroundColor: UIColor,
        insets: UIEdgeInsets = UIEdgeInsets(top: -2, left: -6, bottom: -2, right: -6)) -> NSMutableAttributedString {
    let attributeText = NSMutableAttributedString(string: content)
    attributeText.yy_insertString("  ", at: 0)
    attributeText.yy_appendString("    ")
    attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(10)
    attributeText.yy_color = textColor
    attributeText.yy_lineSpacing = 2
    attributeText.yy_lineHeightMultiple = 0
    attributeText.yy_maximumLineHeight = 0
    attributeText.yy_minimumLineHeight = 20
    let substringRange = attributeText.string.range(of: content)
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

        border.insets = insets
        attributeText.yy_setTextBackgroundBorder(border, range: range)
    }
    return attributeText
}
