//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class FloorPanInfoPropertyCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "FloorPanInfoPropertyCell"
    }

    lazy var containerView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.bottom.equalTo(-6)
        }

    }

    fileprivate func addPropertyItemView(items: [PropertyItemView]) {
        items.forEach { view in
            containerView.addSubview(view)
        }

        items.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0, averageLayout: false, leadSpacing: 9, tailSpacing: 9)
        items.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.subviews.forEach { view in
            view.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class PropertyItemView: UIView {

    var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .left
        return re
    }()

    var value: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.textAlignment = .left
        re.numberOfLines = 0
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.width.equalTo(60)
            maker.top.equalTo(7)
            maker.height.equalTo(21)
        }

        addSubview(value)
        value.snp.makeConstraints { maker in
            maker.left.equalTo(label.snp.right).offset(30)
            maker.top.equalTo(label.snp.top)
            maker.right.equalTo(-15)
            maker.bottom.equalTo(-7)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate func fillPropertiesCell(properties: [(String, String)], cell: BaseUITableViewCell) {
    if let theCell = cell as? FloorPanInfoPropertyCell {
        let views = properties.map { e -> PropertyItemView in
            let (key, value) = e
            let re = PropertyItemView()
            re.label.text = key
            re.value.text = value
            return re
        }
        theCell.addPropertyItemView(items: views)
        theCell.setNeedsLayout()
        theCell.layoutIfNeeded()

    }
}


func parsePropertiesNode(properties: [(String, String)]) -> () -> TableSectionNode? {
    return {
        let render = curry(fillPropertiesCell)(properties)
        let params = TracerParams.momoid() <|>
                toTracerParams("house_info", key: "element_type")
        return TableSectionNode(
                items: [render],
                selectors: [],
                tracer: [elementShowOnceRecord(params: params)],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: FloorPanInfoPropertyCell.identifier))
    }
}
