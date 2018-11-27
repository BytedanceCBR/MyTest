//
//  ErshouHouseCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ErshouHouseCoreInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ErshouHouseCoreInfoCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        addBottomLine()
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

    fileprivate func setNeighborhoodItem(items: [ItemValueView]) {
        for v in contentView.subviews where v is ItemValueView {
            v.removeFromSuperview()
        }
        
        items.forEach { view in
            contentView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 4, averageLayout: true, leadSpacing: 20, tailSpacing: 20)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
    }

    func setItem(items: [HorseCoreInfoItemView]) {
        for v in contentView.subviews where v is HorseCoreInfoItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            contentView.addSubview(view)
        }
//        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 4, averageLayout: true, leadSpacing: 20, tailSpacing: 20)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
         }
    }

}

fileprivate class ItemButtonControl: UIControl {
    
    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#45494d")
        return re
    }()
    
    lazy var rightArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "setting-arrow-3")
        return re
    }()
    
    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.top.equalTo(self)
            maker.height.equalTo(22)
            maker.bottom.equalTo(self).offset(-0.5)
        }
        addSubview(rightArrowImageView)
        rightArrowImageView.snp.makeConstraints { maker in
            maker.left.equalTo(valueLabel.snp.right).offset(7)
            maker.right.equalTo(self)
            maker.width.equalTo(10)
            maker.height.equalTo(10)
            maker.centerY.equalTo(valueLabel)
        }
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { maker in
            maker.left.right.equalTo(valueLabel)
            maker.top.equalTo(valueLabel.snp.bottom)
            maker.height.equalTo(0.5)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            bottomLine.isHidden = !isEnabled
            rightArrowImageView.isHidden = !isEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 小区头部成交房源套数
fileprivate class ItemValueView: UIControl {
    
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        return re
    }()
    
    lazy var valueDataLabel: ItemButtonControl = {
        let re = ItemButtonControl()
        return re
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        backgroundColor = hexStringToUIColor(hex: "#f7f8f9")
        layer.cornerRadius = 4.0
        addSubview(valueDataLabel)
        valueDataLabel.isUserInteractionEnabled = false
        valueDataLabel.snp.makeConstraints { maker in
            maker.left.equalTo(self).offset(16)
            maker.top.equalTo(self).offset(11)
        }
        
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(valueDataLabel.snp.left)
            maker.top.equalTo(valueDataLabel.snp.bottom).offset(4.5)
            maker.height.equalTo(17)
            maker.right.equalToSuperview().offset(-20)
            maker.bottom.equalToSuperview().offset(-11)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HorseCoreInfoItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        return re
    }()

    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: "#ff5b4c")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = hexStringToUIColor(hex: "#f7f8f9")
        layer.cornerRadius = 4.0
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(16)
            maker.top.equalTo(12)
            maker.height.equalTo(25)
            maker.right.equalToSuperview().offset(-10)
        }
        
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(16)
            maker.top.equalTo(valueLabel.snp.bottom)
            maker.height.equalTo(17)
            maker.right.equalToSuperview().offset(-10)
            maker.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseNeighborhoodStatsInfo(_ data: NeighborhoodDetailData,traceExtension: TracerParams = TracerParams.momoid(),disposeBag: DisposeBag, callBack: @escaping (_ info:NeighborhoodItemAttribute) -> Void) -> () -> TableSectionNode? {
    return {
        
        let params = TracerParams.momoid() <|>
            toTracerParams("house_onsale", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
            traceExtension

        
        if let count = data.statsInfo?.count, count > 0 {
            let cellRender = curry(fillNeighborhoodStatsInfoCell)(data)(disposeBag)(callBack)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
        }else {
            
            return nil
        }
    }
}

func fillNeighborhoodStatsInfoCell(data: NeighborhoodDetailData, disposeBag: DisposeBag, callBack: @escaping (_ info:NeighborhoodItemAttribute) -> Void ,cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHouseCoreInfoCell, let statsInfo = data.statsInfo {
        let infos = statsInfo.map { info -> ItemValueView in
            let re = ItemValueView()
            re.keyLabel.text = info.attr
            re.valueDataLabel.valueLabel.text = info.value
            re.rx.controlEvent(UIControlEvents.touchUpInside).subscribe({ (event) in
                if !event.isCompleted {
                    callBack(info)
                }
            }).disposed(by: disposeBag)
            
            if info.value == "暂无" || info.value == "0套" {
                re.valueDataLabel.valueLabel.text = "暂无"
                re.valueDataLabel.isEnabled = false
                re.isEnabled = false
            } else {
                re.valueDataLabel.isEnabled = true
                re.isEnabled = true
            }
            return re
        }

        theCell.setNeighborhoodItem(items: infos)
    }
}

func parseErshouHouseCoreInfoNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {

        if let count = ershouHouseData.coreInfo?.count, count > 0 {
            
            let cellRender = curry(fillErshouHouseCoreInfoCell)(ershouHouseData)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
        }else {
            
            return nil
        }
    }
}

func fillErshouHouseCoreInfoCell(_ ershouHouseData: ErshouHouseData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHouseCoreInfoCell, let coreInfos = ershouHouseData.coreInfo {
        let infos = coreInfos.map { info -> HorseCoreInfoItemView in
            let re = HorseCoreInfoItemView()
            re.keyLabel.text = info.attr
            re.valueLabel.text = info.value
            return re
        }

        theCell.setItem(items: infos)
    }
}
