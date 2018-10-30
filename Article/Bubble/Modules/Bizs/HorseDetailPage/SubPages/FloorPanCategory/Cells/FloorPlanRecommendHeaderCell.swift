//
//  FloorPlanHouseTypeDetailRecommendHeaderCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class FloorPlanRecommendHeaderCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "FloorPlanRecommendHeaderCell"
    }

    lazy var title: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#299cff")
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.top.equalTo(0)
            maker.left.right.bottom.equalToSuperview()
        }

        contentView.addSubview(title)
        title.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-15)
            maker.top.equalTo(22)
            maker.height.equalTo(22)
            maker.bottom.equalTo(-10)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseFloorPlanRecommendHeaderNode(isShow:Bool) -> () -> TableSectionNode? {

    let render = { cell in
        fillHeaderCell(cell: cell)
    }
    return {
        return TableSectionNode(
                items: (isShow) ? [render] : [],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FloorPlanRecommendHeaderCell.identifier))
    }
}

fileprivate func fillHeaderCell(cell: BaseUITableViewCell) {
    if let theCell = cell as? FloorPlanRecommendHeaderCell {
        theCell.title.text = "推荐居室户型"
    }
}
