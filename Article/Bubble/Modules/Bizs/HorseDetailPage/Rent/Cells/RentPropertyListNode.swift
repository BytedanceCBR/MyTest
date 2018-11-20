//
//  RentPropertyListNode.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation

func parseRentPropertyListCellNode(_ infos: [ErshouHouseBaseInfo]?) -> () -> TableSectionNode? {
    let cellRender = curry(fillRentPropertyListCell)(infos)
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            label: "",
            type: .node(identifier: PropertyListCell.identifier))
    }
}

func fillRentPropertyListCell(_ infos: [ErshouHouseBaseInfo]?, cell: BaseUITableViewCell) {
    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
//        if hasOutLineInfo {
            theCell.removeListBottomView()
//        }
        let groups: [[ErshouHouseBaseInfo]]? = infos?.reduce([[], []]) { (result, info) -> [[ErshouHouseBaseInfo]] in
            if info.isSingle == false {
                return [result[0] + [info], result[1]]
            } else {
                return [result[0], result[1] + [info]]
            }
        }

        if let groups = groups {

            func setRowValue(_ info: ErshouHouseBaseInfo, _ rowView: PropertyListRowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }

            var twoValueView: [UIView] = []
            groups[0].enumerated().forEach { (e) in
                let (offset, info) = e
                if offset % 2 == 0 {
                    let twoRow = PropertyListTwoRowView()
                    let row = PropertyListRowView()
                    setRowValue(info, row)
                    twoRow.addSubview(row)
                    twoValueView.append(twoRow)
                } else {
                    let twoRow = twoValueView.last
                    let row = PropertyListRowView()
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
                let re = PropertyListRowView()
                setRowValue(info, re)
                return re
            }

            theCell.addRowView(rows: twoValueView + singleViews)
        }
    }
}
