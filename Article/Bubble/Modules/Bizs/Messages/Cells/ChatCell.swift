//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class ChatCell: BaseUITableViewCell {
    
    
    open override class var identifier: String {
        return "ChatCell"
    }
    
    var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(16)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        result.textAlignment = .left
        return result
    }()
    
    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#8a9299")
        result.textAlignment = .left
        return result
    }()

    var rightLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#a1aab3")
        result.textAlignment = .right
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let re = UIImageView()
        re.layer.shouldRasterize = true
        re.layer.allowsEdgeAntialiasing = true
        re.layer.allowsGroupOpacity = true
        return re
    }()

    lazy var unreadRedDotView: TTBadgeNumberView = {
        let re = TTBadgeNumberView()
        re.badgeViewStyle = UInt(TTBadgeNumberViewStyle.defaultWithBorder.rawValue)
        return re
    }()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.bottom.equalToSuperview()
            maker.height.width.equalTo(62)
        }
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { maker in
            maker.top.equalTo(28)
            maker.right.equalToSuperview().offset(-20)
            maker.width.greaterThanOrEqualTo(56)
            maker.height.equalTo(17)
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(28)
            maker.left.equalTo(iconImageView.snp.right).offset(11)
            maker.right.equalTo(rightLabel.snp.left).offset(4)
            maker.height.equalTo(22)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(label.snp.bottom).offset(5)
            maker.left.equalTo(label.snp.left)
            maker.right.equalToSuperview().offset(-73 * CommonUIStyle.Screen.widthScale)
            maker.height.equalTo(17)
        }
        
        contentView.addSubview(unreadRedDotView)
        unreadRedDotView.snp.makeConstraints { maker in
            maker.right.top.equalTo(iconImageView)
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        unreadRedDotView.badgeNumber = TTBadgeNumberHidden
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
