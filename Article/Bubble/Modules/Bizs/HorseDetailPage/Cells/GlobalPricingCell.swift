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
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
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
            maker.width.equalTo(56).priority(.high)
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

class GlobalPricingListCell: BaseUITableViewCell {


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
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return re
    }()

    open override class var identifier: String {
        return "GlobalPricingListCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addBottomLine()

        contentView.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalTo(21)
            maker.bottom.equalToSuperview().offset(-21)
            maker.height.equalTo(14)
            maker.width.greaterThanOrEqualTo(60)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(17)
            maker.bottom.equalToSuperview().offset(-17)
            maker.height.equalTo(22)
            maker.width.equalTo(56).priority(.high)
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

func parseGlobalPricingNode(_ newHouseData: NewHouseData, traceExt: TracerParams = TracerParams.momoid(),
 processor: @escaping TableCellSelectedProcess) -> () -> TableSectionNode? {
    return {
        guard let list = newHouseData.globalPricing?.list else {
            return nil
        }
        if list.count == 0 {
            return nil
        }
        let cellRenders = list[..<(list.count > 3 ? 3 : list.count)].map { curry(fillGlobalPricingCell)($0) }
        let selectors = list[..<(list.count > 3 ? 3 : list.count)].map { _ in processor }
        let params = TracerParams.momoid() <|>
                toTracerParams("price_trend", key: "element_type") <|>
                traceExt
        return TableSectionNode(
                items: cellRenders,
                selectors: selectors,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: GlobalPricingCell.identifier))
    }
}

func parseGlobalPricingNode(_ items: [GlobalPrice.Item]) -> () -> [TableRowNode] {
    return {
        let renders = items.map(curry(fillGlobalPricingListCell)).map({ (render) -> TableRowNode in
            return TableRowNode(
                itemRender: render,
                selector: nil,
                tracer: nil,
                type: .node(identifier: GlobalPricingListCell.identifier), editor: nil)
        })
        return renders
    }
}

func fillGlobalPricingListCell(_ data: GlobalPrice.Item, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? GlobalPricingListCell {
        theCell.priceLabel.text = data.pricingPerSqm
        theCell.fromLabel.text = "来自\(data.agencyName ?? "")"
    }
}


func fillGlobalPricingCell(_ data: GlobalPrice.Item, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? GlobalPricingCell {
        theCell.priceLabel.text = data.pricingPerSqm
        theCell.fromLabel.text = "来自\(data.agencyName ?? "")"
    }
}
