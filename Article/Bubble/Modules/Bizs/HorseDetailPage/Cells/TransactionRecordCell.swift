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
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var descLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return re
    }()

    lazy var totalPriceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangSemibold(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        re.textAlignment = .right
        return re
    }()

    lazy var pricePreSqmLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .right
        return re
    }()

    lazy var bottomLine: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return result
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints { maker in
            maker.right.equalTo(-20)
            maker.top.equalTo(10)
            maker.width.greaterThanOrEqualTo(45)
            maker.height.equalTo(22)
        }

        contentView.addSubview(namelabel)
        namelabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(10)
            maker.right.equalTo(totalPriceLabel.snp.left).offset(-5)
            maker.height.equalTo(22)
         }

        contentView.addSubview(pricePreSqmLabel)
        pricePreSqmLabel.snp.makeConstraints { maker in
            maker.right.equalTo(-20)
            maker.height.equalTo(17)
            maker.top.equalTo(totalPriceLabel.snp.bottom).offset(5)
        }

        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.top.equalTo(namelabel.snp.bottom).offset(5)
            maker.left.equalTo(20)
            maker.bottom.equalToSuperview().offset(-11)
            maker.right.equalTo(pricePreSqmLabel.snp.left).offset(-5)
        }
    }
    
    override var isTail: Bool {
        didSet {
            bottomLine.isHidden = isTail
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

func parseTransactionRecordNode(_ datas: [TotalSalesInnerItem]?, traceExtension: TracerParams = TracerParams.momoid()) -> () -> TableSectionNode? {
    return {
        if let datas = datas {
            if datas.count != 0 {
                let params = TracerParams.momoid() <|>
                        toTracerParams("neighborhood_trade", key: "element_type") <|>
                        traceExtension
                let count = datas.count
                let renders = datas.take(3).enumerated().map( { (index, item) in
                    
                    curry(fillTransactionRecordCell)(item)((index == count - 1))
                })
                return TableSectionNode(
                    items: renders,
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    sectionTracer: nil,
                    label: "",
                    type: .node(identifier: TransactionRecordCell.identifier))
            }
        }

        return nil
    }
}
func parseTransactionRecordNode(_ data: NeighborhoodTotalSalesResponse?) -> () -> [TableRowNode] {
    return {
        if let datas = data?.data?.list {
            if datas.count != 0 {

                let count = datas.count
                let renders = datas.enumerated().map( { (index, item) in
                    
                    curry(fillTransactionRecordCell)(item)(index == count - 1)
                })

                return renders.map { TableRowNode(
                        itemRender: $0,
                        selector: nil,
                        tracer: nil,
                        type: .node(identifier: TransactionRecordCell.identifier), editor: nil) }
            }
        }
        return []
    }
}

func fillTransactionRecordCell(_ item: TotalSalesInnerItem,
                               isLastCell: Bool = false,
                               cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? TransactionRecordCell {
        theCell.namelabel.text = "\(item.floorplan ?? "")/\(item.squaremeter ?? "")"
        theCell.descLabel.text = "\(item.dealDate ?? ""),\(item.dataSource ?? "")"
        theCell.totalPriceLabel.text = item.pricing
        theCell.pricePreSqmLabel.text = item.pricingPerSqm
        theCell.isTail = isLastCell
        if isLastCell
        {
            theCell.descLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(theCell.namelabel.snp.bottom).offset(5)
                maker.left.equalTo(20)
                maker.bottom.equalToSuperview().offset(-21)
                maker.right.equalTo(theCell.pricePreSqmLabel.snp.left).offset(-5)
            }
        } else {
            theCell.descLabel.snp.remakeConstraints { maker in
                maker.top.equalTo(theCell.namelabel.snp.bottom).offset(5)
                maker.left.equalTo(20)
                maker.bottom.equalToSuperview().offset(-11)
                maker.right.equalTo(theCell.pricePreSqmLabel.snp.left).offset(-5)
            }
        }
    }
}
