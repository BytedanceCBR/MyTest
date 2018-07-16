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
        print(BDAccount.shared())
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "default-avatar-icons")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (maker) in
            maker.right.equalTo(-14)
            maker.width.height.equalTo(62)
            maker.bottom.equalTo(-19)
            maker.top.equalTo(63)
        }

        contentView.addSubview(userName)
        userName.snp.makeConstraints { maker in
            maker.top.equalTo(64)
            maker.left.equalTo(15)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView)
        }

        contentView.addSubview(userDesc)
        userDesc.snp.makeConstraints { maker in
            maker.top.equalTo(userName.snp.bottom)
            maker.left.equalTo(15)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView)
            maker.bottom.equalTo(-13)
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
        theCell.userName.text = info?.screen_name ?? "登陆/注册"
        theCell.userDesc.text = info?.description ?? "我们一起开启美好的找房之旅～"
    }
}
