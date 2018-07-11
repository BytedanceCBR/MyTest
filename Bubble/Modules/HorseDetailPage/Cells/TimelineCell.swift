//
//  TimelineCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class TimelineCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "TimelineCell"
    }

    var isFirstCell = false {
        didSet {
            timeLineLeading.isHidden = isFirstCell
        }
    }

    lazy var timeLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(18)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var redDotView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#f85959")
        result.layer.cornerRadius = 4
        return result
    }()

    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangSemibold(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var contentLabel: UILabel = {
        let result = UILabel()
        result.numberOfLines = 2
        return result
    }()

    lazy var timeLineLeading: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    lazy var timeLineTailing: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { maker in
            maker.left.equalTo(38)
            maker.top.right.equalToSuperview()
            maker.height.equalTo(25)
        }

        contentView.addSubview(redDotView)
        redDotView.snp.makeConstraints { maker in
            maker.height.width.equalTo(8)
            maker.centerY.equalTo(timeLabel.snp.centerY)
            maker.left.equalTo(15)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(timeLabel.snp.bottom).offset(16)
            maker.left.equalTo(timeLabel.snp.left)
            maker.height.equalTo(26)
            maker.right.equalToSuperview().offset(-15)
         }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(4)
            maker.left.equalTo(titleLabel.snp.left)
            maker.right.equalToSuperview().offset(-15)
            maker.bottom.equalToSuperview().offset(-26)
         }

        contentView.addSubview(timeLineLeading)
        timeLineLeading.snp.makeConstraints { maker in
            maker.left.equalTo(19)
            maker.width.equalTo(1)
            maker.top.equalToSuperview()
            maker.bottom.equalTo(redDotView.snp.top).offset(-4)
         }

        contentView.addSubview(timeLineTailing)
        timeLineTailing.snp.makeConstraints { maker in
            maker.left.equalTo(timeLineLeading.snp.left)
            maker.width.equalTo(1)
            maker.top.equalTo(redDotView.snp.bottom).offset(4)
            maker.bottom.equalToSuperview()
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContent(_ content: String, isExpand: Bool = false) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let attrText = NSMutableAttributedString(
                string: content,
                attributes: [.font: CommonUIStyle.Font.pingFangMedium(16),
                             .foregroundColor: hexStringToUIColor(hex: "#707070"),
                             .paragraphStyle: style])
        contentLabel.attributedText = attrText
        if isExpand {
            contentLabel.numberOfLines = 0
        }
    }

}

func parseTimelineNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let renders = newHouseData.timeLine?.list?.enumerated().map { (e) -> TableCellRender in
            let (offset, item) = e
            return curry(fillTimelineCell)(item)(offset == 0)(false)
        }
        return TableSectionNode(items: renders ?? [], selectors: nil, label: "楼盘动态", type: .node(identifier: TimelineCell.identifier))
    }
}

func fillTimelineCell(
    _ data: TimeLine.Item,
    isFirstCell: Bool,
    isExpand: Bool = false,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? TimelineCell {
        theCell.isFirstCell = isFirstCell
        theCell.timeLabel.text = "03-20"
        theCell.titleLabel.text = data.title
        if let content = data.desc {              
            theCell.setContent(content, isExpand: isExpand)
        }
    }
}

func parseTimelineNode(_ items: [TimeLine.Item]) -> () -> [TableRowNode] {
    return {
        let renders = items.map(curry(fillTimelineCell)).enumerated().map({ (e) -> TableRowNode in
            let (offset, render) = e
            return TableRowNode(
                    itemRender: render(offset == 0)(true),
                    selector: nil,
                    type: .node(identifier: TimelineCell.identifier))
        })
        return renders
    }
}
