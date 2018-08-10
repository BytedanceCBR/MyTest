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
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.numberOfLines = 2
        return result
    }()

    lazy var aliasLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#999999")
        result.text = "别名"
        return result
    }()

    lazy var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        return result
    }()

    lazy var tagsView: YYLabel = {
        let result = YYLabel()
        result.numberOfLines = 0
        result.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalToSuperview().offset(15)
        }

        contentView.addSubview(aliasLabel)
        aliasLabel.snp.makeConstraints { maker in
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.left.equalTo(nameLabel.snp.left)
            maker.height.equalTo(0).priority(.high)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.left.equalTo(aliasLabel.snp.right).offset(4)
            maker.right.equalTo(nameLabel.snp.right)
            maker.height.equalTo(0).priority(.high)
        }

        contentView.addSubview(tagsView)
        tagsView.snp.makeConstraints { maker in
            maker.top.equalTo(secondaryLabel.snp.bottom).offset(-3)
            maker.left.equalTo(nameLabel.snp.left).offset(-2)
            maker.bottom.equalToSuperview().offset(-16)
            maker.width.equalToSuperview().offset(-30)
        }
        contentView.lu
                .addBottomBorder(
                color: hexStringToUIColor(hex: "#e8e8e8"),
                leading: 15,
                trailing: -15)
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

        tags.enumerated().forEach { (e) in
            let (offset, tag) = e
            text.append(tag)
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
//            if lineHeight > height {
//                if offset != 0 {
//                    text.yy_insertString("\n", at: UInt(text.length - tag.length))
//                }
//                height = lineHeight
//            }
            //只显示一行
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        }

        tagsView.attributedText = text
    }

    func setAlias(alias: String? = nil) {
        if let alias = alias, !alias.isEmpty {
            secondaryLabel.text = alias

            aliasLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(nameLabel.snp.bottom).offset(6)
                maker.left.equalTo(nameLabel.snp.left)
                maker.height.equalTo(17).priority(.high)
            }
            secondaryLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(nameLabel.snp.bottom).offset(6)
                maker.left.equalTo(nameLabel.snp.left)
                maker.right.equalTo(nameLabel.snp.right)
                maker.height.equalTo(17).priority(.high)
            }
        } else {
            aliasLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(nameLabel.snp.bottom).offset(6)
                maker.left.equalTo(nameLabel.snp.left)
                maker.height.equalTo(0).priority(.high)
            }
            secondaryLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(nameLabel.snp.bottom).offset(6)
                maker.left.equalTo(aliasLabel.snp.left)
                maker.right.equalTo(nameLabel.snp.right)
                maker.height.equalTo(0).priority(.high)
            }
        }
    }

}

func parseNewHouseNameNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillNewHouseNameCell)(newHouseData)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillNewHouseNameCell(_ newHouseData: NewHouseData, cell: BaseUITableViewCell) {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }

    theCell.nameLabel.text = newHouseData.coreInfo?.name
    theCell.setAlias(alias: newHouseData.coreInfo?.aliasName)
    var tags: [NSAttributedString] = []

    if let tgs = newHouseData.tags {
        tgs.map { (item) in
            createTagAttributeText(
                    content: item.content,
                    textColor: hexStringToUIColor(hex: item.textColor),
                    backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
        }.forEach { item in
            tags.append(item)
        }
    }
    theCell.setTags(tags: tags)
}

func parseErshouHouseNameNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillErshouHouseNameCell)(ershouHouseData)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: NewHouseNameCell.identifier))
    }
}

func fillErshouHouseNameCell(_ ershouHouseData: ErshouHouseData, cell: BaseUITableViewCell) {
    guard let theCell = cell as? NewHouseNameCell else {
        return
    }
    theCell.nameLabel.text = ershouHouseData.title
    let tags = ershouHouseData.tags.map({ (item) -> NSAttributedString in
        createTagAttributeText(
            content: item.content,
            textColor: hexStringToUIColor(hex: item.textColor),
            backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
    })
    theCell.setAlias(alias: nil)

    theCell.setTags(tags: tags)
}

func createTagAttributeText(
        content: String,
        textColor: UIColor,
        backgroundColor: UIColor,
        insets: UIEdgeInsets = UIEdgeInsets(top: -2, left: -3, bottom: -2, right: -3)) -> NSMutableAttributedString {
    let attributeText = NSMutableAttributedString(string: content)
    attributeText.yy_insertString("  ", at: 0)
    attributeText.yy_appendString("  ")
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
