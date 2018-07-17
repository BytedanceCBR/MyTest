//
//  NeighborhoodPriceCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/7.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class NeighborhoodPriceCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "NeighborhoodPriceCell"
    }

    lazy var priceKeyLabel: UILabel = {
        let re = UILabel()
        re.text = "均价"
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var monthUpKey: UILabel = {
        let re = UILabel()
        re.text = "环比"
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var monthUpLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var monthUpTrend: UIImageView = {
        let re = UIImageView()
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addBottomLine()
        contentView.addSubview(priceKeyLabel)
        priceKeyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(19)
            maker.height.equalTo(17)
            maker.bottom.equalTo(-19)
            maker.width.equalTo(24)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceKeyLabel.snp.right).offset(10)
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.height.equalTo(22)
            maker.right.equalTo(contentView.snp.centerX).offset(5)
        }

        contentView.addSubview(monthUpKey)
        monthUpKey.snp.makeConstraints { maker in
            maker.left.equalTo(contentView.snp.centerX).offset(15)
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.height.equalTo(17)
            maker.width.equalTo(24)
        }

        contentView.addSubview(monthUpLabel)
        monthUpLabel.snp.makeConstraints { maker in
            maker.left.equalTo(monthUpKey.snp.right).offset(10)
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.height.equalTo(22)
         }

        contentView.addSubview(monthUpTrend)

        monthUpTrend.snp.makeConstraints { maker in
            maker.left.equalTo(monthUpLabel.snp.right).offset(4)
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.width.height.equalTo(12)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseNeighborhoodPriceNode(_ data: NeighborhoodDetailData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillNeighborhoodPriceCell)(data.neighborhoodInfo)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: NeighborhoodPriceCell.identifier))
    }
}

func fillNeighborhoodPriceCell(_ data: NeighborhoodDetailInfo?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodPriceCell {
        theCell.priceLabel.text = data?.pricingPerSqm
        if let monthUp = data?.monthUp {
            let absValue = abs(monthUp) * 100
            if absValue < 1 {
                theCell.monthUpLabel.text = "持平"
                theCell.monthUpTrend.isHidden = true
            } else {
                theCell.monthUpLabel.text = String(format: "%.2f%%", arguments: [absValue])
                theCell.monthUpTrend.isHidden = false
                if monthUp >= 0 {
                    theCell.monthUpLabel.textColor = hexStringToUIColor(hex: "#f85959")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_up")
                } else {
                    theCell.monthUpLabel.textColor = hexStringToUIColor(hex: "#79d35f")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_down")
                }
            }

        }
    }
}
