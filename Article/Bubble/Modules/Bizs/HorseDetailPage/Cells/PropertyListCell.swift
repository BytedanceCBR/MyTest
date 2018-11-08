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

        // addBottomLine()

        contentView.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(-35)
            maker.left.right.equalToSuperview()
        }
        
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(6)
        }
    }
    
    lazy var bottomMaskView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

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
        resetListBottomView()
    }
    
    func removeListBottomView(heightOffset:CGFloat = -10) {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(heightOffset)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = true
        
    }
    
    func resetListBottomView()
    {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(-35)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = false
    }
}

fileprivate class RowView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        return re
    }()

    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        re.textAlignment = .left
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        
        keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(keyLabel)
        addSubview(valueLabel)

        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(keyLabel.snp.right).offset(10)
            maker.right.equalTo(-25)
            maker.top.equalTo(14)
            maker.bottom.equalTo(keyLabel)
        }
    }
    // 小区详情页布局
    func remakeValueLabelConstraints() {
        valueLabel.snp.remakeConstraints { maker in
            maker.left.equalTo(self).offset(96)
            maker.right.equalTo(-25)
            maker.top.equalTo(14)
            maker.bottom.equalTo(keyLabel)
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
        
        if let count = ershouHouseData.baseInfo?.count, count > 0 {
            
            let cellRender = curry(fillPropertyListCell)(ershouHouseData.baseInfo)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            
            return nil
        }
    }
}

func parseFloorPlanPropertyListNode(_ data: FloorPlanInfoData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillPropertyListCell)(data.baseInfo)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
                tracer: nil,
            label: "",
            type: .node(identifier: PropertyListCell.identifier))
    }
}

func parseNeighborhoodPropertyListNode(_ data: NeighborhoodDetailData, traceExtension: TracerParams = TracerParams.momoid()) -> () -> TableSectionNode? {
    return {
        
        let params = TracerParams.momoid() <|>
            toTracerParams("neighborhood_info", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
            traceExtension
        
        if let count = data.baseInfo?.count, count > 0 {
            let cellRender = curry(fillNeighborhoodPropertyListCell)(data.baseInfo)(data.neighborhoodBaseInfoFold)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            return nil
        }
    }
}

func fillNeighborhoodPropertyListCell(_ infos: [NeighborhoodItemAttribute]?, infoFold:Bool, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        cell.prepareForReuse()
        if let groups = infos {
            func setRowValue(_ info: NeighborhoodItemAttribute, _ rowView: RowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }

            let singleViews = groups.map { (info) -> UIView in
                let re = RowView()
                setRowValue(info, re)
                re.remakeValueLabelConstraints()
                return re
            }
            
            if infoFold {
                let rowVeiws = singleViews.take(4)
                theCell.addRowView(rows: rowVeiws)
            } else {
                theCell.addRowView(rows: singleViews)
            }
        }
    }
}



func fillPropertyListCell(_ infos: [ErshouHouseBaseInfo]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
        theCell.removeListBottomView()
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
                if offset % 2 == 0 {
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

// 房源概况-info
fileprivate class HouseOutlineInfoView:UIView {
    
    lazy var iconImg: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "rectangle-11")
        return re
    }()
    
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()
    
    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.numberOfLines = 0
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#737a80")
        re.textAlignment = .left
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(iconImg)
        addSubview(keyLabel)
        addSubview(valueLabel)
        
        iconImg.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.width.equalTo(10)
            maker.height.equalTo(8)
            maker.centerY.equalTo(keyLabel)
        }
        
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconImg.snp.right).offset(4)
            maker.top.equalTo(10)
            maker.height.equalTo(26)
            maker.right.equalTo(self).offset(-20)
        }
        
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconImg)
            maker.right.equalTo(-20)
            maker.top.equalTo(keyLabel.snp.bottom).offset(2)
            maker.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


func parseHouseOutlineListNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        
        if let count = ershouHouseData.baseInfo?.count, count > 0 {
            
            let cellRender = curry(fillHouseOutlineListCell)(ershouHouseData.baseInfo)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            
            return nil
        }
    }
}


func fillHouseOutlineListCell(_ infos: [ErshouHouseBaseInfo]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
        func setInfoValue(_ keyText: String, _ valueText: String, _ infoView: HouseOutlineInfoView) {
            infoView.keyLabel.text = keyText
            infoView.valueLabel.text = valueText
        }
        
        let re1 = HouseOutlineInfoView()
        setInfoValue("核心卖点", "本放弃我瓦灰而韩国九二五我华为覅无恶哈哈我维护费IE文化馆一我了hi维护过来玩哈格uwihgeuihweiuhfkheiughewiu外观和UIhi额外一万飞胡歌一无花果我活过来了喝挂了韩国", re1)
        
        var listView:[HouseOutlineInfoView] = []
        listView.append(re1)
        
        let re2 = HouseOutlineInfoView()
        setInfoValue("小区配套", "本放弃我瓦灰而韩国九二五我华为覅无恶哈哈我维护费IE文化馆一我了hi维护过来玩哈格uwihgeuihweiuhfkheiughewiu外观和UIhi额外一万飞胡歌一无花果我活过来了喝挂了韩国", re2)
         listView.append(re2)
         theCell.addRowView(rows: listView)
    }
}
