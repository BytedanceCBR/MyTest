//
//  HeaderCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class HeaderCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "HeaderCell"
    }

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var loadMore: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        re.textAlignment = .right
        re.text = "查看更多"
        re.isHidden = true
        return re
    }()

    lazy var arrowsImg: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-feed")
        re.isHidden = true
        return re
    }()

    var adjustBottomSpace: CGFloat {
        didSet {
            if label.superview != nil {
                label.snp.updateConstraints { (maker) in
                    maker.bottom.equalToSuperview().offset(adjustBottomSpace)
                }
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.adjustBottomSpace = -16
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(arrowsImg)
        arrowsImg.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-20)
            maker.height.width.equalTo(18)
            maker.centerY.equalTo(label.snp.centerY)
         }

        contentView.addSubview(loadMore)
        loadMore.snp.makeConstraints { maker in
            maker.centerY.equalTo(label.snp.centerY)
            maker.height.equalTo(14)
            maker.width.equalTo(80)
            maker.right.equalTo(arrowsImg.snp.left)
         }
        
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(loadMore.snp.left).offset(-10)
            maker.top.equalTo(20)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview().offset(-20)
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

    override func prepareForReuse() {
        super.prepareForReuse()
        loadMore.isHidden = true
        arrowsImg.isHidden = true
    }
}

func parseTimeLineHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.timeLine?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("楼盘动态")("查看更多 >")(false)(-20)
            return TableSectionNode(
                    items: [cellRender],
                    selectors: nil,
                    tracer: nil,
                    sectionTracer: nil,
                    label: "",
                    type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseFloorPanHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.floorPan?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("楼盘户型")("查看更多 >")(false)(-20)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseCommentHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.comment?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("用户点评")("查看更多 >")(false)(-20)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil, sectionTracer: nil,
                label: "",
                type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseHeaderNode(
        _ title: String,
        subTitle: String = "查看更多",
        showLoadMore: Bool = false,
        adjustBottomSpace: CGFloat = -20,
        process: TableCellSelectedProcess? = nil,
        filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        if let filter = filter, filter() == false {
            return nil
        } else {
            let cellRender = curry(fillHeaderCell)(title)(subTitle)(showLoadMore)(adjustBottomSpace)
            var selectors: [TableCellSelectedProcess] = []
            if process != nil {
                selectors.append(process!)
            }
            return TableSectionNode(
                items: [cellRender],
                selectors: selectors,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: HeaderCell.identifier))
        }
    }
}

func fillHeaderCell(_ title: String, subTitle: String, showLoadMore: Bool, adjustBottomSpace: CGFloat, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? HeaderCell {
        theCell.label.text = title
        theCell.loadMore.text = subTitle
        theCell.arrowsImg.isHidden = !showLoadMore
        theCell.loadMore.isHidden = !showLoadMore
        theCell.adjustBottomSpace = adjustBottomSpace
    }
}
