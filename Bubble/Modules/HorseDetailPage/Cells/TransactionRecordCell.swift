//
//  TransactionRecordCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/8.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class TransactionRecordCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "TransactionRecordCell"
    }

    lazy var namelabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var descLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var totalPriceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangSemibold(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var pricePreSqmLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addBottomLine()

        contentView.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints { maker in
            maker.right.equalTo(15)
            maker.top.equalTo(15)
            maker.width.greaterThanOrEqualTo(45)
            maker.height.equalTo(22)
        }

        contentView.addSubview(namelabel)
        namelabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(14)
            maker.right.equalTo(totalPriceLabel.snp.left).offset(5)
            maker.height.equalTo(22)
         }

        contentView.addSubview(pricePreSqmLabel)
        pricePreSqmLabel.snp.makeConstraints { maker in
            maker.right.equalTo(15)
            maker.height.equalTo(15)
            maker.top.equalTo(totalPriceLabel.snp.bottom).offset(5)
        }

        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.top.equalTo(5)
            maker.left.equalTo(15)
            maker.bottom.equalToSuperview().offset(-13)
            maker.right.equalTo(pricePreSqmLabel.snp.left).offset(5)
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

func parseTransactionRecordNode(_ data: NeighborhoodTotalSalesResponse?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.data?.list {
            if datas.count != 0 {

                let renders = datas.map(curry(fillTransactionRecordCell))
                return TableSectionNode(
                    items: renders,
                    selectors: nil,
                    label: "",
                    type: .node(identifier: TransactionRecordCell.identifier))
            }
        }

        return nil
    }
}

func fillTransactionRecordCell(_ item: TotalSalesInnerItem, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? TransactionRecordCell {
        theCell.namelabel.text = item.floorplan
        theCell.descLabel.text = "\(item.dealDate ?? ""),\(item.dataSource ?? "")"
        theCell.totalPriceLabel.text = item.pricing
        theCell.pricePreSqmLabel.text = item.pricingPerSqm
    }
}
