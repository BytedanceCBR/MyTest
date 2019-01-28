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
        result.textColor = hexStringToUIColor(hex: "#081f33")
        result.textAlignment = .left
        return result
    }()

    var userDesc: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#8a9299")
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
//            maker.bottom.equalTo(-19)
            maker.top.equalTo(63)
        }
        avatarView.layer.cornerRadius = 62 / 2
        contentView.addSubview(userName)
        userName.snp.makeConstraints { maker in
            maker.top.equalTo(64)
            maker.left.equalTo(20)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
        }

        contentView.addSubview(userDesc)
        userDesc.snp.makeConstraints { maker in
            maker.top.equalTo(userName.snp.bottom)
            maker.left.equalTo(20)
            maker.height.equalTo(34)
            maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
            maker.bottom.equalTo(-20)
        }

        contentView.addSubview(editBtn)
        editBtn.snp.makeConstraints { maker in
            maker.left.equalTo(userDesc.snp.right).offset(5)
            maker.centerY.equalTo(userDesc.snp.centerY)
            maker.width.height.equalTo(16)
        }
    }
    
    // state:0 展示username，居中，desc不显示，不可点击；（默认）
    // state:1 展示username，展示desc，点击toast提示；
    // state:2 展示username，展示desc，点击到编辑页面
    func setUserInfoState(state:Int) {
        var vState = state;
        if (vState > 2 || vState < 0) {
            vState = 0;
        }
        if (vState == 0) {
            userDesc.isHidden = true
            editBtn.isHidden = true
            userName.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(avatarView)
                maker.left.equalTo(20)
                maker.height.equalTo(34)
                maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
            }
        } else {
            userDesc.isHidden = false
            editBtn.isHidden = false
            userName.snp.makeConstraints { maker in
                maker.top.equalTo(64)
                maker.left.equalTo(20)
                maker.height.equalTo(34)
                maker.right.lessThanOrEqualTo(avatarView.snp.left).offset(-10)
            }
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
        _ info: TTAccountUserEntity?,
        openEditProfile: @escaping (UIViewController) -> Void,
        disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillUserInfoCell)(info)
        var selector: ((TracerParams) -> Void)? = nil
        if info != nil {
            selector = { (params) in
                // add by zyk状态获取
                let vState = 0
                // 0：不可编辑；1：Toast提示；2：可编辑个人权限
                if (vState == 1) {
                    // Toast 提示
                    EnvContext.shared.toast.showToast("修改功能升级中，敬请期待")
                } else if (vState == 2) {
                    // 跳转
                    let vc = TTEditUserProfileViewController()
                    openEditProfile(vc)
                }
                
                let map = ["event_type":"house_app2c", "click_type":"edit_info", "page_type":"minetab"]
                recordEvent(key: TraceEventName.click_minetab, params: map)
                
                recordEvent(key: TraceEventName.go_detail, params: ["page_type":"personal_info", "enter_from": "minetab"])

            }
        } else {
            selector = { (params) in
                
                var tracerParams = TracerParams.momoid()
                tracerParams = tracerParams <|>
                    toTracerParams("minetab", key: "enter_from") <|>
                    toTracerParams("login", key: "enter_type")

                let paramsMap = tracerParams.paramsGetter([:])
                let userInfo = TTRouteUserInfo(info: paramsMap)
                
                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: userInfo)
                
                let map = ["event_type":"house_app2c", "click_type":"login", "page_type":"minetab"]
                recordEvent(key: TraceEventName.click_minetab, params: map)
            }
        }
        return TableSectionNode(
                items: [cellRender],
                selectors: [selector!],
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: UserInfoCell.identifier))
    }
}

func fillUserInfoCell(_ info: TTAccountUserEntity?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? UserInfoCell {
        theCell.userName.text = info?.name ?? "登录"
        if info != nil {
            theCell.userDesc.text = "查看并编辑个人资料"
            theCell.editBtn.isHidden = false
        } else {
            theCell.userDesc.text = "登录后，关注房源永不丢失"
            theCell.editBtn.isHidden = true
        }
        // add by zyk状态获取
        let vState = 0
        theCell.setUserInfoState(state: vState)

        if let urlStr = info?.avatarURL {
            theCell.avatarView.contentMode = .scaleAspectFill
            theCell.avatarView.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default-avatar-icons"))
        } else {
            theCell.avatarView.image = #imageLiteral(resourceName: "default-avatar-icons")
        }
    }
}

