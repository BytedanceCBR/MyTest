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
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.textAlignment = .left
        return result
    }()
    
    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#999999")
        result.textAlignment = .left
        return result
    }()

    var rightLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#cacaca")
        result.textAlignment = .right
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let re = UIImageView()
        return re
    }()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(14)
            maker.top.equalTo(9)
            maker.bottom.equalToSuperview().offset(-9)
            maker.height.width.equalTo(52)
        }
        
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(12.5)
            maker.left.equalTo(77)
//            maker.left.equalTo(iconImageView.snp.right).offset(11)
            maker.bottom.equalToSuperview().offset(-13.5)
            maker.width.greaterThanOrEqualTo(283)
        }
        
        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(39.5)
            maker.left.equalTo(77)
            maker.bottom.equalToSuperview().offset(-13.5)
            maker.width.greaterThanOrEqualTo(283)
        }
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { maker in

            maker.top.equalTo(15)
            maker.right.equalToSuperview().offset(-10)
            maker.left.equalTo(label.snp.right).offset(5).priority(.high)
            maker.width.greaterThanOrEqualTo(28).priority(.high)
        }
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
