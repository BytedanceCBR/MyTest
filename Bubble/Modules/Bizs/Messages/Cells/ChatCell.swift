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
        
        contentView.lu.addBottomBorder(color: hexStringToUIColor(hex: "#e8e8e8"), leading: 15, trailing: -15)
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(14)
            maker.top.equalTo(9)
            maker.bottom.equalToSuperview().offset(-9)
            maker.height.width.equalTo(52)
        }
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { maker in
            maker.top.equalTo(13)
            maker.right.equalToSuperview().offset(-13)
            maker.width.greaterThanOrEqualTo(28).priority(.high)
            maker.height.equalTo(17)
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(12.5)
            maker.left.equalTo(iconImageView.snp.right).offset(11)
            maker.right.equalTo(rightLabel.snp.left).offset(4)
            maker.height.equalTo(22)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(label.snp.bottom).offset(5)
            maker.left.equalTo(label.snp.left)
            maker.right.equalTo(label.snp.right)
            maker.height.equalTo(17)
        }
        

        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
