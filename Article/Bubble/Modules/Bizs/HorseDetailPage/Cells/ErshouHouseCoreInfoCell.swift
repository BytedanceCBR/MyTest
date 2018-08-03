//
//  ErshouHouseCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class ErshouHouseCoreInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ErshouHouseCoreInfoCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addBottomLine()
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

    fileprivate func setItem(items: [ItemView]) {
        for v in contentView.subviews where v is ItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            contentView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
         }
    }

}

fileprivate class ItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var verticalLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.height.equalTo(17)
            maker.right.equalToSuperview().offset(-15)
        }

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(keyLabel.snp.bottom).offset(4)
            maker.height.equalTo(22)
            maker.right.equalToSuperview().offset(-15)
            maker.bottom.equalToSuperview().offset(-16)
        }

        addSubview(verticalLine)
        verticalLine.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.width.equalTo(0.5)
            maker.top.equalTo(23)
            maker.bottom.equalToSuperview().offset(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseNeighborhoodStatsInfo(_ data: NeighborhoodDetailData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillNeighborhoodStatsInfoCell)(data)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
    }
}

func fillNeighborhoodStatsInfoCell(data: NeighborhoodDetailData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHouseCoreInfoCell, let statsInfo = data.statsInfo {
        let infos = statsInfo.map { info -> ItemView in
            let re = ItemView()
            re.keyLabel.text = info.attr
            re.valueLabel.text = info.value
            return re
        }
        infos.first?.verticalLine.isHidden = true

        theCell.setItem(items: infos)
    }
}

func parseErshouHouseCoreInfoNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillErshouHouseCoreInfoCell)(ershouHouseData)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            label: "",
            type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
    }
}

func fillErshouHouseCoreInfoCell(_ ershouHouseData: ErshouHouseData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHouseCoreInfoCell, let coreInfos = ershouHouseData.coreInfo {
        let infos = coreInfos.map { info -> ItemView in
            let re = ItemView()
            re.keyLabel.text = info.attr
            re.valueLabel.text = info.value
            return re
        }
        infos.first?.verticalLine.isHidden = true

        theCell.setItem(items: infos)
    }
}
