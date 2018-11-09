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

fileprivate class ItemButtonControl: UIControl {
    
    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#45494d")
        return re
    }()
    
    lazy var rightArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "setting-arrow-2")
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
            maker.width.height.equalTo(10)
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
fileprivate class ItemValueView: UIView {
    
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

fileprivate class ItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        return re
    }()

    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#ff5b4c")
        return re
    }()

    lazy var verticalLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(16)
            maker.height.equalTo(17)
            maker.right.equalToSuperview().offset(-20)
        }

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(keyLabel.snp.left)
            maker.top.equalTo(keyLabel.snp.bottom).offset(4)
            maker.height.equalTo(22)
            maker.right.equalTo(keyLabel.snp.right)
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

func parseNeighborhoodStatsInfo(_ data: NeighborhoodDetailData,traceExtension: TracerParams = TracerParams.momoid(),disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        
        let params = TracerParams.momoid() <|>
            toTracerParams("house_onsale", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
            traceExtension

        
        if let count = data.statsInfo?.count, count > 0 {
            let cellRender = curry(fillNeighborhoodStatsInfoCell)(data)(disposeBag)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
        }else {
            
            return nil
        }
    }
}

func fillNeighborhoodStatsInfoCell(data: NeighborhoodDetailData, disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ErshouHouseCoreInfoCell, let statsInfo = data.statsInfo {
        let infos = statsInfo.map { info -> ItemValueView in
            let re = ItemValueView()
            re.keyLabel.text = info.attr
            re.valueDataLabel.valueLabel.text = info.value
            re.valueDataLabel.rx.controlEvent(UIControlEvents.touchUpInside).subscribe({ (Void) in
                print("\(info.value)")
            }).disposed(by: disposeBag)
            
            if info.value == "暂无" {
                re.valueDataLabel.isEnabled = false
            } else {
                re.valueDataLabel.isEnabled = true
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
                label: "",
                type: .node(identifier: ErshouHouseCoreInfoCell.identifier))
        }else {
            
            return nil
        }
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
