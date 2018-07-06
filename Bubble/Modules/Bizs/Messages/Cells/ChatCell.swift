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
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.textAlignment = .left
        return result
    }()
    
    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(13)
        result.textColor = hexStringToUIColor(hex: "#999999")
        result.textAlignment = .right
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let re = UIImageView()
        return re
    }()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(11)
            maker.bottom.equalToSuperview().offset(-11)
            maker.width.greaterThanOrEqualTo(250)
        }
        
        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.right.equalToSuperview().offset(-15)
            maker.left.equalTo(label.snp.right).offset(5).priority(.high)
            maker.width.greaterThanOrEqualTo(63).priority(.high)
        }
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.height.width.equalTo(40)
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
