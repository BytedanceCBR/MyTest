//
//  ContactCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class ContactCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ContactCell"
    }

    lazy var phoneNumberLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangSemibold(16)
        result.textColor = hexStringToUIColor(hex: "#f85959")
        return result
    }()

    lazy var descLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#707070")
        result.text = "最新开盘、户型及优惠信息，免费致电售楼处"
        return result
    }()

    lazy var phoneCallBtn: UIButton = {
        let result = UIButton()
        result.setImage(#imageLiteral(resourceName: "group-3"), for: .normal)
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        let maskView = UIView()
        maskView.backgroundColor = UIColor.white
        contentView.addSubview(maskView)
        maskView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(6)
            maker.bottom.equalToSuperview().offset(-6)
        }

        maskView.addSubview(phoneCallBtn)
        phoneCallBtn.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-12)
            maker.top.equalTo(17)
            maker.bottom.equalToSuperview().offset(-17)
            maker.height.width.equalTo(46)
         }

        maskView.addSubview(phoneNumberLabel)
        phoneNumberLabel.snp.makeConstraints { maker in
            maker.height.equalTo(22)
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.right.equalTo(phoneCallBtn.snp.left)
        }

        maskView.addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.height.equalTo(22)
            maker.left.equalTo(15)
            maker.top.equalTo(phoneNumberLabel.snp.bottom).offset(4)
            maker.right.equalTo(phoneCallBtn.snp.left)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

func parseNewHouseContactNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillNewHouseContactCell)(newHouseData)
        return TableSectionNode(items: [cellRender], label: "", type: .node(identifier: ContactCell.identifier))
    }
}

func fillNewHouseContactCell(_ data: NewHouseData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ContactCell {
        theCell.phoneNumberLabel.text = data.contact?["phone"]
        theCell.descLabel.text = data.contact?["notice_desc"]
    }
}
