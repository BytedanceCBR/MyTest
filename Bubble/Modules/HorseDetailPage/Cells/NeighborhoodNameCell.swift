//
//  NeighborhoodNameCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/7.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class NeighborhoodNameCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "NeighborhoodNameCell"
    }

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(24)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var subNameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var locationIcon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "group")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addBottomLine()

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(15)
            maker.right.equalTo(-15)
            maker.height.equalTo(34)
        }

        contentView.addSubview(subNameLabel)
        subNameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.height.equalTo(17)
            maker.bottom.equalTo(-16)
        }

        contentView.addSubview(locationIcon)
        locationIcon.snp.makeConstraints { maker in
            maker.left.equalTo(subNameLabel.snp.right).offset(4)
            maker.height.width.equalTo(16)
            maker.top.equalTo(nameLabel.snp.bottom).offset(6.5)
         }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseNeighborhoodNameNode(_ data: NeighborhoodDetailData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillNeighborhoodNameCell)(data)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: NeighborhoodNameCell.identifier))
    }
}

func fillNeighborhoodNameCell(_ data: NeighborhoodDetailData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodNameCell {
        theCell.nameLabel.text = data.name
        theCell.subNameLabel.text = data.neighborhoodInfo?.locationFullName
    }
}
