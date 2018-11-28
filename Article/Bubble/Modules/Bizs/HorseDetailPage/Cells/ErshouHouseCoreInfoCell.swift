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
        
        for v in contentView.subviews where v.tag == 101 {
            v.removeFromSuperview()
        }
        
        items.forEach { view in
            contentView.addSubview(view)
        }
        let space = (UIScreen.main.bounds.width - 40 - CGFloat(70 * items.count)) / 2 // 间隔
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: space, averageLayout: true, leadSpacing: 20, tailSpacing: 20)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
        // 添加中间分割线(小区信息)
        for i in 1 ..< items.count {
            let v = UIView()
            v.tag = 101
            v.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
            contentView.addSubview(v)
            let leftOffset = CGFloat(20 + CGFloat(i) * 70 + (CGFloat(i) - 1 + 0.5) * space)
            v.snp.makeConstraints { (maker) in
                maker.height.equalTo(27)
                maker.width.equalTo(0.5)
                maker.centerY.equalTo(contentView)
                maker.left.equalToSuperview().offset(leftOffset)
            }
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
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        return re
    }()
    
    lazy var rightArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "setting-arrow-4")
        return re
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.top.equalTo(self)
            maker.height.equalTo(17)
            maker.bottom.equalTo(self)
        }
        addSubview(rightArrowImageView)
        rightArrowImageView.snp.makeConstraints { maker in
            maker.left.equalTo(valueLabel.snp.right).offset(10)
            maker.width.height.equalTo(12)
            maker.centerY.equalTo(valueLabel)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            rightArrowImageView.isHidden = !isEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 小区头部成交房源套数
fileprivate class ItemValueView: UIControl {
    
    // 套数
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#517b9f")
        return re
    }()
    
    lazy var valueDataLabel: ItemButtonControl = {
        let re = ItemButtonControl()
        return re
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = hexStringToUIColor(hex: "#ffffff")
        
        addSubview(valueDataLabel)
        valueDataLabel.isUserInteractionEnabled = false
        valueDataLabel.snp.makeConstraints { maker in
            maker.left.equalTo(self)
            maker.top.equalTo(self).offset(14.5)
            maker.right.equalTo(self)
        }
        
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(valueDataLabel.snp.left)
            maker.top.equalTo(valueDataLabel.snp.bottom).offset(2)
            maker.height.equalTo(20)
            maker.bottom.equalToSuperview().offset(-14)
        }
        
        self.isDataEnabled = true
    }
    
    var isDataEnabled: Bool = true {
        didSet {
            if isDataEnabled {
                keyLabel.textColor = hexStringToUIColor(hex: "#517b9f")
            } else {
                keyLabel.textColor = hexStringToUIColor(hex: "#a1aab3")
            }
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
            re.keyLabel.text = info.value
            re.valueDataLabel.valueLabel.text = info.attr
            re.rx.controlEvent(UIControlEvents.touchUpInside).subscribe({ (event) in
                if !event.isCompleted {
                    callBack(info)
                }
            }).disposed(by: disposeBag)
            
            if info.value == "暂无" || info.value == "0套" {
                re.keyLabel.text = "暂无"
                re.valueDataLabel.isEnabled = false
                re.isDataEnabled = false
                re.isEnabled = false
            } else {
                re.valueDataLabel.isEnabled = true
                re.isDataEnabled = true
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
