//
//  GlobalPricingCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class GlobalPricingCell: BaseUITableViewCell {


    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangSemibold(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var fromLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textAlignment = .right
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    open override class var identifier: String {
        return "GlobalPricingCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalTo(15)
            maker.bottom.equalToSuperview().offset(-15)
            maker.height.equalTo(14)
            maker.width.greaterThanOrEqualTo(60)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(11)
            maker.bottom.equalToSuperview().offset(-11)
            maker.height.equalTo(22)
            maker.right.equalTo(fromLabel.snp.left).offset(-15)
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

}

func parseGlobalPricingNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        guard let list = newHouseData.globalPricing?.list else {
            return nil
        }
        if list.count == 0 {
            return nil
        }
        let cellRenders = list[..<(list.count > 3 ? 3 : list.count)].map { curry(fillGlobalPricingCell)($0) }
        return TableSectionNode(items: cellRenders, selectors: nil, label: "", type: .node(identifier: GlobalPricingCell.identifier))
    }
}

func fillGlobalPricingCell(_ data: GlobalPrice.Item, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? GlobalPricingCell {
        theCell.priceLabel.text = data.pricingPerSqm
        theCell.fromLabel.text = data.agencyName
    }
}
