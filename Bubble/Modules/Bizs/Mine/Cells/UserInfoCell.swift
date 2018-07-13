//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class UserInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "UserInfoCell"
    }

    var userName: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(24)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.textAlignment = .left
        return result
    }()

    var userDesc: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(14)
        result.textColor = hexStringToUIColor(hex: "#999999")
        result.textAlignment = .left
        return result
    }()

    lazy var avatarView: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "icon-zufang")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (maker) in
            maker.right.equalTo(-15)
            maker.width.height.equalTo(60)
            maker.bottom.equalTo(-20)
            maker.top.equalToSuperview()
        }

        contentView.addSubview(userName)
        userName.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalTo(15)
            maker.right.lessThanOrEqualTo(avatarView)
        }

        contentView.addSubview(userDesc)
        userDesc.snp.makeConstraints { maker in
            maker.top.equalTo(userName.snp.bottom)
            maker.left.equalTo(15)
            maker.right.lessThanOrEqualTo(avatarView)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseUserInfoNode(_ info: UserInfo?) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillUserInfoCell)(info)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: UserInfoCell.identifier))
    }
}

func fillUserInfoCell(_ info: UserInfo?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? UserInfoCell {
        theCell.userName.text = info?.screen_name ?? "139****7029"
        theCell.userDesc.text = info?.description ?? "填写你的说明"
    }
}
