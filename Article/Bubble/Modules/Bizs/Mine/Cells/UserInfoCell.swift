//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
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
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#999999")
        result.textAlignment = .left
        return result
    }()

    lazy var avatarView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFit
        re.clipsToBounds = true
        re.image = #imageLiteral(resourceName: "default-avatar-icons")
        return re
    }()

    lazy var editBtn: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "pencil-simple-line-icons"), for: .normal)
        re.isHidden = true
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
        avatarView.layer.cornerRadius = 62 / 2
        contentView.addSubview(userName)
        userName.snp.makeConstraints { maker in
            maker.top.equalTo(64)
            maker.left.equalTo(15)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
        }

        contentView.addSubview(userDesc)
        userDesc.snp.makeConstraints { maker in
            maker.top.equalTo(userName.snp.bottom)
            maker.left.equalTo(15)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
            maker.bottom.equalTo(-13)
        }

        contentView.addSubview(editBtn)
        editBtn.snp.makeConstraints { maker in
            maker.left.equalTo(userDesc.snp.right).offset(5)
            maker.centerY.equalTo(userDesc.snp.centerY)
            maker.width.height.equalTo(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseUserInfoNode(
        _ info: BDAccountUser?,
        openEditProfile: @escaping (UIViewController) -> Void,
        disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillUserInfoCell)(info)
        var selector: (() -> Void)? = nil
        if info != nil {
            selector = {
                let vc = TTEditUserProfileViewController()
                openEditProfile(vc)
            }
        } else {
            selector = {
//                TTAccountManager.presentQuickLogin(fromVC: EnvContext.shared.rootNavController, type: TTAccountLoginDialogTitleType.default, source: "", completion: { (state) in
//
//                })
                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"))
            }
        }
        return TableSectionNode(
                items: [cellRender],
                selectors: [selector!],
                label: "",
                type: .node(identifier: UserInfoCell.identifier))
    }
}

func fillUserInfoCell(_ info: BDAccountUser?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? UserInfoCell {
        theCell.userName.text = info?.name ?? "登陆/注册"
        if info != nil {
            theCell.userDesc.text = "查看并编辑个人资料"
            theCell.editBtn.isHidden = false
        } else {
            theCell.userDesc.text = "我们一起开启美好的找房之旅～"
            theCell.editBtn.isHidden = true
        }

        if let urlStr = info?.avatarURL {
            theCell.avatarView.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default-avatar-icons"))
        } else {
            theCell.avatarView.bd_setImage(with: #imageLiteral(resourceName: "default-avatar-icons"))
        }
    }
}

