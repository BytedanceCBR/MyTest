//
//  FloorPlanHouseTypeNameCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class FloorPlanHouseTypeNameCell : BaseUITableViewCell {

    open override class var identifier: String {
        return "FloorPlanHouseTypeNameCell"
    }

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.font = CommonUIStyle.Font.pingFangMedium(24)
        return re
    }()

    lazy var pricingLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var pricingPerSqm: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var statusBGView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 2
        return re
    }()

    lazy var statusLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(15)
            maker.height.equalTo(34)
        }

        contentView.addSubview(pricingLabel)
        pricingLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(nameLabel.snp.bottom)
            maker.bottom.equalTo(-15)
            maker.height.equalTo(22)
        }

        contentView.addSubview(pricingPerSqm)
        pricingPerSqm.snp.makeConstraints { maker in
            maker.left.equalTo(pricingLabel.snp.right).offset(10)
            maker.top.equalTo(nameLabel.snp.bottom).offset(2)
            maker.height.equalTo(20)
        }

        contentView.addSubview(statusBGView)
        statusBGView.snp.makeConstraints { maker in
            maker.left.equalTo(nameLabel.snp.right).offset(6)
            maker.centerY.equalTo(nameLabel.snp.centerY)
            maker.height.equalTo(15)
            maker.width.equalTo(26)
        }

        statusBGView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.height.equalTo(10)
            maker.width.equalTo(20)
        }

        self.addBottomLine()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseFloorPlanHouseTypeNameNode(_ data: FloorPlanInfoData) -> () -> TableSectionNode? {
    let render = curry(fillFloorPlanHouseTypeNameCell)(data)
    return {
        TableSectionNode(
                items: [render],
                selectors: nil,
                label: "",
                type: .node(identifier: FloorPlanHouseTypeNameCell.identifier))
    }
}

fileprivate func fillFloorPlanHouseTypeNameCell(data: FloorPlanInfoData, cell: BaseUITableViewCell) {
    if let theCell = cell as? FloorPlanHouseTypeNameCell {
        theCell.nameLabel.text = data.title
        theCell.pricingLabel.text = data.pricing
        theCell.pricingPerSqm.text = data.pricingPerSqm
    }
}
