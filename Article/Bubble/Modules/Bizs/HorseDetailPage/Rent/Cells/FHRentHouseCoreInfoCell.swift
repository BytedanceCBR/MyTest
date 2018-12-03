//
//  FHRentHouseCoreInfoCell.swift
//  NewsLite
//
//  Created by linlin on 2018/12/3.
//

import Foundation
import SnapKit
class FHRentHouseCoreInfoCell: BaseUITableViewCell {

    var pending: CGFloat = 13
    var cubePending: CGFloat = 4

    private var itemViews: [HorseCoreInfoItemView] = []

    open override class var identifier: String {
        return "rentHouseCoreInfoCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.snp.makeConstraints { (make) in
            make.height.equalTo(66)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldUseAverageLayout(firstLabel: itemViews.first?.valueLabel) {
            averageLayoutItems()
        } else {
            layoutItems()
        }
    }

    func setItem(items: [HorseCoreInfoItemView]) {
        itemViews.forEach { (view) in
            view.removeFromSuperview()
        }
        itemViews.removeAll()
        items.forEach { (view) in
            contentView.addSubview(view)
        }
        itemViews.append(contentsOf: items)
        if shouldUseAverageLayout(firstLabel: itemViews.first?.valueLabel) {
            averageLayoutItems()
        } else {
            layoutItems()
        }
    }

    func shouldUseAverageLayout(firstLabel: UILabel?) -> Bool {
        if let firstLabel = firstLabel {
            let width = firstLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: firstLabel.frame.height)).width
            return width <= ((self.frame.width - 4 * cubePending) / 3)
        } else {
            return true
        }
    }

    func layoutItems() {
        var offsetX: CGFloat = cubePending
        itemViews.enumerated().forEach { (e) in
            let (offset, view) = e
            if offset != itemViews.count - 1 {
                view.frame = CGRect(x: offsetX,
                                    y: 0,
                                    width: catulateLabelWidth(view.valueLabel) + 2 * pending,
                                    height: self.frame.height)
                offsetX = offsetX + cubePending + catulateLabelWidth(view.valueLabel) + 2 * pending
            } else {
                view.frame = CGRect(x: offsetX,
                                    y: 0,
                                    width: self.frame.width - offsetX - cubePending,
                                    height: self.frame.height)
            }
        }
    }

    func averageLayoutItems() {
        let width = (self.frame.width - 4 * cubePending) / 3
        var offsetX: CGFloat = cubePending
        itemViews.forEach { (view) in
            view.frame = CGRect(x: offsetX, y: 0, width: width, height: self.frame.height)
            offsetX = offsetX + cubePending + width
        }
    }

    func catulateLabelWidth(_ label: UILabel) -> CGFloat {
        label.sizeToFit()
        let width = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: label.frame.height)).width
        return width
    }
}



func parseRentCoreInfoCellNode1(model: FHRentDetailResponseDataModel?,
                               tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let cellRender = curry(fillRentCoreInfoCell1)(model)
    //    let params = EnvContext.shared.homePageParams <|>
    //        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
    //        toTracerParams("house_roommate", key: "element_type") <|>
    //        toTracerParams(tracer.pageType, key: "page_type")
    //    let tracerEvaluationRecord = elementShowOnceRecord(params: params)
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHRentHouseCoreInfoCell.identifier))
    }
}

func fillRentCoreInfoCell1(model: FHRentDetailResponseDataModel?, cell: BaseUITableViewCell) {
    if let theCell = cell as? FHRentHouseCoreInfoCell {
        //        let re = HorseCoreInfoItemView()
        //        re.keyLabel.text = "93457元/月"
        //        re.valueLabel.text = "押一付三"
        //        let re1 = HorseCoreInfoItemView()
        //        re1.keyLabel.text = "2室1厅"
        //        re1.valueLabel.text = "房型"
        //        let re2 = HorseCoreInfoItemView()
        //        re2.keyLabel.text = "20平"
        //        re2.valueLabel.text = "共90平"
        //        theCell.setItem(items: [re, re1, re2])
        let infos = model?.coreInfo?
            .map { $0 as? FHRentDetailResponseDataCoreInfoModel }
            .map { info -> HorseCoreInfoItemView in
                let re = HorseCoreInfoItemView()
                re.keyLabel.text = info?.attr
                re.valueLabel.text = info?.value
                return re
        }

        theCell.setItem(items: infos ?? [])
    }
}
