//
// Created by linlin on 2018/7/16.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class MineOptionCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "MineOptionCell"
    }

//    lazy var iconView: UIImageView = {
//        let re = UIImageView()
//        return re
//    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        re.textAlignment = .left
        return re
    }()

    lazy var arrowsIcon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "setting-arrow")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(20)
            maker.right.equalTo(50)
            maker.height.equalTo(22)
        }

        contentView.addSubview(arrowsIcon)
        arrowsIcon.snp.makeConstraints { maker in
            maker.left.equalTo(label.snp.right).offset(10)
            maker.right.equalTo(-20)
            maker.centerY.equalTo(label.snp.centerY)
            maker.height.width.equalTo(12)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        arrowsIcon.isHidden = false
    }
}

func parseOptionNode(
        icon: UIImage,
        label: String,
        isShowBottomLine: Bool,
        callback: ((TracerParams) -> Void)?) -> () -> TableSectionNode? {
    return {
        let render = curry(fillOptionCell)(icon)(label)(isShowBottomLine)
        return TableSectionNode(
            items: [render],
            selectors: callback != nil ? [callback!] : nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: MineOptionCell.identifier))
    }
}

fileprivate func fillOptionCell(icon: UIImage,
                                label: String,
                                isShowBottomLine: Bool,
                                cell: BaseUITableViewCell) {
    if let theCell = cell as? MineOptionCell {
        theCell.label.text = label

    }
}

func parseContactUsNode(phoneNumber: String, callback: ((TracerParams) -> Void)?) -> () -> TableSectionNode? {
    let render = curry(fillContactUsCell)(phoneNumber)
    let traceParams = TracerParams.momoid() <|>
            toTracerParams("call_page", key: "element_type")
    return {
        return TableSectionNode(
                items: [render],
                selectors: callback != nil ? [callback!] : nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: MineOptionCell.identifier))
    }
}

func fillContactUsCell(phoneNumber: String, cell: BaseUITableViewCell) {
    if let theCell = cell as? MineOptionCell {
        theCell.label.text = "客服电话"
        theCell.arrowsIcon.isHidden = true
    }
}

