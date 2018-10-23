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
    
    var offsetY: CGFloat = 0.0 {
        didSet {
            headLine.snp.updateConstraints { (maker) in
                maker.height.equalTo(offsetY)
            }
        }
    }

    lazy var timeLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(18)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        return result
    }()

    lazy var redDotView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#a1aab3")
        result.layer.cornerRadius = 4
        return result
    }()

    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangSemibold(16)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        return result
    }()

    lazy var contentLabel: UILabel = {
        let result = UILabel()
        result.numberOfLines = 2
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#8a9299")
        result.lineBreakMode = .byWordWrapping
        return result
    }()

    lazy var timeLineLeading: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        return re
    }()
    
    lazy var headLine: UIView = {
        let re = UIView()
        re.backgroundColor = .white
        return re
    }()

    lazy var timeLineTailing: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(headLine)
        headLine.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(0)
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { maker in
            maker.left.equalTo(48)
            maker.right.equalToSuperview().offset(-20)
            maker.top.equalTo(headLine.snp.bottom)
            maker.height.equalTo(25)
        }

        contentView.addSubview(redDotView)
        redDotView.snp.makeConstraints { maker in
            maker.height.width.equalTo(8)
            maker.centerY.equalTo(timeLabel.snp.centerY)
            maker.left.equalTo(20)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(timeLabel.snp.bottom).offset(16)
            maker.left.equalTo(timeLabel.snp.left)
            maker.height.equalTo(26)
            maker.right.equalToSuperview().offset(-20)
         }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(4)
            maker.left.equalTo(titleLabel.snp.left)
            maker.right.equalToSuperview().offset(-20)
            maker.bottom.equalToSuperview().offset(-26)
         }

        contentView.addSubview(timeLineLeading)
        timeLineLeading.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.width.equalTo(1)
            maker.top.equalToSuperview()
            maker.bottom.equalTo(redDotView.snp.top).offset(-4)
         }

        contentView.addSubview(timeLineTailing)
        timeLineTailing.snp.makeConstraints { maker in
            maker.left.equalTo(timeLineLeading.snp.left)
            maker.width.equalTo(0.5)
            maker.top.equalTo(redDotView.snp.bottom).offset(4)
            maker.bottom.equalTo(0)
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
//        style.lineSpacing = 4
        style.lineBreakMode = .byTruncatingTail
        let attrText = NSMutableAttributedString(
                string: content,
                attributes: [.font: CommonUIStyle.Font.pingFangRegular(16),
                             .foregroundColor: hexStringToUIColor(hex: kFHCoolGrey3Color),
                             .paragraphStyle: style])
        contentLabel.attributedText = attrText
        if isExpand {
            contentLabel.numberOfLines = 0
        }
        
        if self.isTail {
            timeLineTailing.snp.updateConstraints { (maker) in
                maker.bottom.equalTo(-30)
            }
        }else {
            timeLineTailing.snp.updateConstraints { (maker) in
                maker.bottom.equalTo(0)
            }
        }
    }

}

func parseTimelineNode(_ newHouseData: NewHouseData, traceExt: TracerParams = TracerParams.momoid(), processor: @escaping TableCellSelectedProcess) -> () -> TableSectionNode? {
    return {
        
        let count = newHouseData.timeLine?.list?.count ??  0
        if count > 0 {
            let renders = newHouseData.timeLine?.list?.enumerated().map { (e) -> TableCellRender in
                let (offset, item) = e
                return curry(fillTimelineCell)(item)(offset == 0)(offset == count - 1)(0)(false)
            }
            var selectors:[TableCellSelectedProcess]?
            if let list = newHouseData.timeLine?.list {
                
                selectors = list.map { _ in processor }
            }
            let params = TracerParams.momoid() <|>
                toTracerParams("house_history", key: "element_type") <|>
                traceExt
            return TableSectionNode(
                items: renders ?? [],
                selectors: selectors,
                tracer: [elementShowOnceRecord(params: params)],
                label: "楼盘动态",
                type: .node(identifier: TimelineCell.identifier))
            
        }else {
            
            return nil
        }
    }
}

func fillTimelineCell(
    _ data: TimeLine.Item,
    isFirstCell: Bool,
    isLastCell: Bool = false,
    offsetY: CGFloat = 0,
    isExpand: Bool = false,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? TimelineCell {
        theCell.isFirstCell = isFirstCell
        theCell.isTail = isLastCell
        theCell.timeLabel.text = CommonUIStyle.DateTime.simpleDataFormat.string(from: Date(timeIntervalSince1970: TimeInterval(data.createTime)))
        theCell.titleLabel.text = data.title
        theCell.offsetY = offsetY
        if let content = data.desc {              
            theCell.setContent(content, isExpand: isExpand)
        }
    }
}

func parseTimelineNode(_ items: [TimeLine.Item]) -> () -> [TableRowNode] {
    return {
        
        let count = items.count
        let renders = items.map(curry(fillTimelineCell)).enumerated().map({ (e) -> TableRowNode in
            let (offset, render) = e
            return TableRowNode(
                    itemRender: render(offset == 0)(offset == count - 1)(0)(true),
                    selector: nil,
                    tracer: nil,
                    type: .node(identifier: TimelineCell.identifier),
                    editor: nil)
        })
        return renders
    }
}

func parseFloorTimelineNode(_ items: [TimeLine.Item]) -> () -> [TableRowNode] {
    return {
        
        let count = items.count
        let renders = items.map(curry(fillTimelineCell)).enumerated().map({ (e) -> TableRowNode in
            let (offset, render) = e
            return TableRowNode(
                itemRender: render(offset == 0)(offset == count - 1)(offset == 0 ? 15 : 0)(true),
                selector: nil,
                tracer: nil,
                type: .node(identifier: TimelineCell.identifier),
                editor: nil)
        })
        return renders
    }
}

