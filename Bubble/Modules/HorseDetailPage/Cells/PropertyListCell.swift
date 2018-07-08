//
//  PropertyListCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class PropertyListCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "PropertyListCell"
    }

    lazy var wrapperView: UIView = {
        let re = UIView()
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addBottomLine()

        contentView.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(-16)
            maker.left.right.equalToSuperview()
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

    fileprivate func addRowView(rows: [UIView]) {
        for v in wrapperView.subviews {
            v.removeFromSuperview()
        }

        rows.forEach { view in
            wrapperView.addSubview(view)
        }
        rows.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0)
        rows.snp.makeConstraints { maker in
            maker.width.equalToSuperview()
            maker.left.right.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        for v in wrapperView.subviews {
            v.removeFromSuperview()
        }
    }

}

fileprivate class RowView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(14)
            maker.width.greaterThanOrEqualTo(30).priority(.medium)
            maker.height.equalTo(21)
            maker.bottom.equalToSuperview()
        }

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(keyLabel.snp.right).offset(10)
            maker.height.equalTo(21)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

fileprivate class TwoRowView: UIView {

}


func parsePropertyListNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillPropertyListCell)(ershouHouseData.baseInfo)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            label: "",
            type: .node(identifier: PropertyListCell.identifier))
    }
}

func parseNeighborhoodPropertyListNode(_ data: NeighborhoodDetailData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillNeighborhoodPropertyListCell)(data.baseInfo)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
    }
}

func fillNeighborhoodPropertyListCell(_ infos: [NeighborhoodItemAttribute]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        let groups: [[NeighborhoodItemAttribute]]? = infos?.reduce([[], []]) { (result, info) -> [[NeighborhoodItemAttribute]] in
            if info.isSingle == false {
                return [result[0] + [info], result[1]]
            } else {
                return [result[0], result[1] + [info]]
            }
        }

        if let groups = groups {

            func setRowValue(_ info: NeighborhoodItemAttribute, _ rowView: RowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }

            var twoValueView: [UIView] = []
            groups[0].enumerated().forEach { (e) in
                let (offset, info) = e
                if (offset + 1) % 2 == 0 {
                    let twoRow = TwoRowView()
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow.addSubview(row)
                    twoValueView.append(twoRow)
                } else {
                    let twoRow = twoValueView.last
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow?.addSubview(row)
                }
            }

            twoValueView.forEach { view in
                view.subviews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
            }

            twoValueView.forEach { view in
                view.subviews.snp.makeConstraints { maker in
                    maker.top.bottom.equalToSuperview()
                    maker.height.equalTo(35)
                }
            }

            let singleViews = groups[1].map { (info) -> UIView in
                let re = RowView()
                setRowValue(info, re)
                return re
            }

            theCell.addRowView(rows: twoValueView + singleViews)
        }
    }
}



func fillPropertyListCell(_ infos: [ErshouHouseBaseInfo]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        let groups: [[ErshouHouseBaseInfo]]? = infos?.reduce([[], []]) { (result, info) -> [[ErshouHouseBaseInfo]] in
            if info.isSingle == false {
                return [result[0] + [info], result[1]]
            } else {
                return [result[0], result[1] + [info]]
            }
        }

        if let groups = groups {

            func setRowValue(_ info: ErshouHouseBaseInfo, _ rowView: RowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }

            var twoValueView: [UIView] = []
            groups[0].enumerated().forEach { (e) in
                let (offset, info) = e
                if (offset + 1) % 2 == 0 {
                    let twoRow = TwoRowView()
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow.addSubview(row)
                    twoValueView.append(twoRow)
                } else {
                    let twoRow = twoValueView.last
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow?.addSubview(row)
                }
            }

            twoValueView.forEach { view in
                view.subviews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
            }

            twoValueView.forEach { view in
                view.subviews.snp.makeConstraints { maker in
                    maker.top.bottom.equalToSuperview()
                    maker.height.equalTo(35)
                }
            }

            let singleViews = groups[1].map { (info) -> UIView in
                let re = RowView()
                setRowValue(info, re)
                return re
            }

            theCell.addRowView(rows: twoValueView + singleViews)
        }
    }
}
