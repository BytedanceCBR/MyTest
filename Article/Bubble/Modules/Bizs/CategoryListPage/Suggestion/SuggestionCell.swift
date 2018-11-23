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
        result.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        result.textAlignment = .left
        return result
    }()
    
    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(13)
        result.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        result.textAlignment = .right
        return result
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(11)
            maker.bottom.equalToSuperview().offset(-11)
        }
        
        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.right.equalToSuperview().offset(-20)
            maker.left.equalTo(label.snp.right).offset(-20)
            maker.width.greaterThanOrEqualTo(63)
        }

        secondaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        secondaryLabel.setContentHuggingPriority(.required, for: .horizontal)

//        contentView.lu.addBottomBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SuggestionNewHouseItemCell: UITableViewCell {

    var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        result.textAlignment = .left
        return result
    }()

    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(13)
        result.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        result.textAlignment = .right
        return result
    }()

    var subLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .left
        return re
    }()

    var secondarySubLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .right
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(11)
            maker.width.greaterThanOrEqualTo(250)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.right.equalToSuperview().offset(-20)
            maker.left.equalTo(label.snp.right).offset(5).priority(.high)
            maker.width.greaterThanOrEqualTo(63).priority(.high)
        }

        contentView.addSubview(subLabel)
        contentView.addSubview(secondarySubLabel)

        
        subLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(label.snp.bottom).offset(6)
            maker.left.equalTo(20)
            maker.bottom.equalTo(-13)
            maker.height.equalTo(17)
        }
        
        secondarySubLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        secondarySubLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        subLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        secondarySubLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(subLabel.snp.centerY)
            maker.right.equalTo(-20)
            maker.left.equalTo(subLabel.snp.right).offset(5)

        }

        contentView.lu.addBottomBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SuggestionHeaderView: UIView {

    lazy var guessView:GuessYouWantView = GuessYouWantView()
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var deleteBtn: UIButton = {
        let re = ExtendHotAreaButton()
        re.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        addSubview(guessView)
        guessView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(138)
        }
        
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.height.equalTo(20)
            maker.bottom.equalTo(-10)
        }

        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(label.snp.centerY)
            maker.right.equalTo(-20)
            maker.height.width.equalTo(20)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
