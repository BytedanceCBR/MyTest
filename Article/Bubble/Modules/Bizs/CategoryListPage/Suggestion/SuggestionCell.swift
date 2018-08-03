//
//  SuggestionCell.swift
//  News
//
//  Created by leo on 2018/8/2.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
class SuggestionItemCell: UITableViewCell {
    
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
        contentView.lu.addBottomBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SuggestionNewHouseItemCell: UITableViewCell {

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

    var subLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.textAlignment = .left
        return re
    }()

    var secondarySubLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.textAlignment = .right
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(11)
            maker.width.greaterThanOrEqualTo(250)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.right.equalToSuperview().offset(-15)
            maker.left.equalTo(label.snp.right).offset(5).priority(.high)
            maker.width.greaterThanOrEqualTo(63).priority(.high)
        }

        contentView.addSubview(subLabel)
        subLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(label.snp.bottom).offset(6)
            maker.left.equalTo(15)
            maker.width.greaterThanOrEqualTo(250)
            maker.bottom.equalTo(-13)
            maker.height.equalTo(17)
        }
        
        contentView.addSubview(secondarySubLabel)
        secondarySubLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(subLabel.snp.centerY)
            maker.right.equalTo(-15)
            maker.left.equalTo(subLabel.snp.right).offset(5).priority(.high)
            maker.width.greaterThanOrEqualTo(63).priority(.high)
        }

        contentView.lu.addBottomBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SuggestionHeaderView: UIView {

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var deleteBtn: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(10)
            maker.bottom.equalTo(-10)
        }

        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(label.snp.centerY)
            maker.right.equalTo(-15)
            maker.height.width.equalTo(16)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
