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

    lazy var iconView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.textAlignment = .left
        return re
    }()

    lazy var arrowsIcon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "setting-arrow")
        return re
    }()

    lazy var subTitle: UILabel = {
        let re = UILabel()
        re.textAlignment = .right
        re.textColor = hexStringToUIColor(hex: "#cacaca")
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.isHidden = true
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addBottomLine()
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(13)
            maker.width.height.equalTo(24)
            maker.bottom.equalTo(-13)
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalTo(iconView.snp.centerY)
            maker.left.equalTo(iconView.snp.right).offset(12)
            maker.height.equalTo(22)
        }

        contentView.addSubview(arrowsIcon)
        arrowsIcon.snp.makeConstraints { maker in
            maker.left.equalTo(label.snp.right).offset(10)
            maker.right.equalTo(-16)
            maker.centerY.equalTo(iconView.snp.centerY)
            maker.height.width.equalTo(12)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

func parseOptionNode(
        icon: UIImage,
        label: String,
        isShowBottomLine: Bool,
        callback: (() -> Void)?) -> () -> TableSectionNode? {
    return {
        let render = curry(fillOptionCell)(icon)(label)(isShowBottomLine)
        return TableSectionNode(
            items: [render],
            selectors: callback != nil ? [callback!] : nil,
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
        if isShowBottomLine {
            theCell.contentView.lu.addBottomBorder(
                    color: hexStringToUIColor(hex: "#e8e8e8"),
                    leading: 15,
                    trailing: -15)
        }
        theCell.iconView.image = icon
    }
}

