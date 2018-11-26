//
//  FHRentDisclaimerCell.swift
//  Article
//
//  Created by leo on 2018/11/21.
//

import Foundation
import RxSwift
import SnapKit
class FHRentDisclaimerCell: BaseUITableViewCell {

    lazy var ownerLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "3d6e99")
        return re
    }()

    lazy var contactIcon: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "contact"), for: .normal)
        return re
    }()

    lazy var disclaimerContent: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "a2abb4")
        re.numberOfLines = 0
        return re
    }()

    open override class var identifier: String {
        return "rentDisclaimerCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.backgroundColor = hexStringToUIColor(hex: "f2f4f5")
        contentView.addSubview(ownerLabel)
        contentView.addSubview(contactIcon)
        ownerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(14)
            make.height.equalTo(20)
            make.right.equalTo(contactIcon.snp.left).offset(-10)
        }

        contactIcon.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualTo(-20)
            make.centerY.equalTo(ownerLabel)
            make.width.equalTo(20)
            make.height.equalTo(13)
        }

        contentView.addSubview(disclaimerContent)
        disclaimerContent.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(ownerLabel.snp.bottom).offset(3)
            make.bottom.equalTo(-14)
        }
    }

    func hiddenOwnerLabel() {
        ownerLabel.isHidden = true
        contactIcon.isHidden = true
        disclaimerContent.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(14)
            make.bottom.equalTo(-14)
        }
    }

    func displayOwnerLabel() {
        ownerLabel.isHidden = false
        contactIcon.isHidden = false
        disclaimerContent.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(ownerLabel.snp.bottom).offset(3)
            make.bottom.equalTo(-14)
        }
    }
}


func parseRentDisclaimerCellNode(model: FHRentDetailResponseDataModel?) -> () -> TableSectionNode? {
    let render = curry(fillRentDisclaimerCell)(model)
    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHRentDisclaimerCell.identifier))
    }
}

func fillRentDisclaimerCell(model: FHRentDetailResponseDataModel?, cell: BaseUITableViewCell) {
    if let theCell = cell as? FHRentDisclaimerCell {
        if let contact = model?.contact,
            let realtorName = contact.realtorName,
            !realtorName.isEmpty {
            theCell.displayOwnerLabel()
            theCell.ownerLabel.text = "房屋负责人：\(realtorName)"
        } else {
            theCell.hiddenOwnerLabel()
        }

        theCell.disclaimerContent.text = "免责声明：房源所示图片及其他信息仅供参考，租房时请以房本信息为准。"
    }
}
