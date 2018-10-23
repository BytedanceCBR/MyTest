//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit

class PermitListCell: BaseUITableViewCell {

    var headerView: UIView = {
        let re = UIView()
        return re
    }()

    var listView: UIView = {
        let re = UIView()
        return re
    }()

    override open class var identifier: String {
        return "PermitListCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
        }

        let hLabels = ["预售许可证",
                       "发证信息",
                       "绑定信息"]
                .map { value -> UILabel in
            let re = UILabel()
            re.font = CommonUIStyle.Font.pingFangRegular(15)
            re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
            re.textAlignment = .left
            re.text = value
            return re
        }
        hLabels.forEach { label in
            headerView.addSubview(label)
        }
        hLabels.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 15, tailSpacing: 15)
        hLabels.snp.makeConstraints { maker in
            maker.top.equalTo(16)
            maker.bottom.equalTo(-10)
        }

        contentView.addSubview(listView)
        listView.snp.makeConstraints { maker in
            maker.top.equalTo(headerView.snp.bottom)
            maker.bottom.left.right.equalToSuperview()
        }
    }

    fileprivate func setItems(items: [ItemView]) {
        var prev: UIView?
        items.enumerated().forEach { e in
            let (offset, v) = e
            listView.addSubview(v)

            v.snp.makeConstraints({ [weak prev] (maker) in
                if offset == 0 {
                    maker.top.equalToSuperview()
                }
                
                if let thePrev = prev {
                    maker.top.equalTo(thePrev.snp.bottom)
                }
                
                if offset == (items.count - 1) {
                    maker.bottom.equalToSuperview()
                }
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                
            })
            
            prev = v
        }
        
        setNeedsLayout()
        layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class ItemView: UIView {

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setItemValues(values: [String]) {
        let views = values.map { s -> UILabel in
            let re = UILabel()
            re.font = CommonUIStyle.Font.pingFangRegular(15)
            re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
            re.textAlignment = .left
            re.numberOfLines = 0
            re.text = s
            return re
        }

        views.forEach { label in
            addSubview(label)
        }
        views.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 15, tailSpacing: 15)
        views.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.bottom.equalTo(-10)
        }
    }

}

fileprivate func fillPermitListCell(permit: [PermitList], cell: BaseUITableViewCell) {
    if let theCell = cell as? PermitListCell {
        let items = permit.map { permit -> ItemView in
            let re = ItemView()
            re.setItemValues(values: [
                permit.permit ?? "",
                permit.permitDate ?? "",
                permit.bindBuilding ?? ""])
            return re
        }
        theCell.setItems(items: items)
    }
}

func parsePermitListNode(_ detail: CourtMoreDetail) -> () -> TableSectionNode? {
    return {
        if let permitList = detail.permitList, permitList.count > 0 {
            let render = curry(fillPermitListCell)(permitList)
            return TableSectionNode(
                items: [oneTimeRender(render)],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: PermitListCell.identifier))
        } else {
            return nil
        }
    }
}
