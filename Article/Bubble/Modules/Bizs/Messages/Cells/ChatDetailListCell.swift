//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//



import UIKit
import SnapKit
import CoreGraphics
import RxCocoa
import RxSwift

class ChatDetailListCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "ChatDetailListCell"
    }
    override var isTail: Bool {
        didSet {

            if bottomView.superview == nil {
                return
            }
            let height = isTail ? 20 : 0
            bottomView.snp.updateConstraints { maker in
                maker.height.equalTo(height)
            }
        }
    }
    
    lazy var majorImageView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        return re
    }()
    
    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return label
    }()
    
    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "737a80")
        return label
    }()
    
    lazy var areaLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: kFHCoralColor)
        return label
    }()
    
    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return label
    }()
    
    lazy var headView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isTail = false
        
        self.contentView.addSubview(headView)
        headView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        self.contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(0)
            maker.top.equalTo(105)

        }
        
        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.top.equalTo(headView.snp.bottom)
//            maker.bottom.equalTo(bottomView.snp.top)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        
        let infoPanel = UIView()
        contentView.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(15)
            maker.top.equalTo(majorImageView)
            maker.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }
        
        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(16)
            
        }
        
        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(8)
            maker.height.equalTo(17)
            
        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.height.equalTo(15)
            
        }
        
        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(24)
            maker.width.lessThanOrEqualTo(130)

        }
        
        roomSpaceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        roomSpaceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(7)
            maker.bottom.equalTo(priceLabel.snp.bottom).offset(-2)
            maker.height.equalTo(19)
            
        }
    }
    
    func updateLayoutCompoents(isShowTags: Bool)
    {
        if isShowTags {
            self.majorTitle.numberOfLines = 1
            
            majorTitle.snp.updateConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(20)
            }
            
            extendTitle.snp.updateConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(majorTitle.snp.bottom).offset(4)
                maker.height.equalTo(17)
            }
            
        } else {
            self.majorTitle.numberOfLines = 2
            
            let fitSize = self.majorTitle.sizeThatFits(CGSize(width: UIScreen.main.bounds.width * (UIScreen.main.bounds.size.width > 376 ? 0.6 : (UIScreen.main.bounds.size.width > 321 ? 0.56 : 0.48)), height: 0))
            
            majorTitle.snp.updateConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.top.equalToSuperview().offset(fitSize.height < 30 ? 0 : -5)
                maker.height.equalTo(fitSize.height < 30 ? 20 : 50)
            }
            
            extendTitle.snp.updateConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(majorTitle.snp.bottom).offset(fitSize.height < 30 ? 4 : 1)
                maker.height.equalTo(17)
            }
            
            areaLabel.snp.updateConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(extendTitle.snp.bottom).offset(0)
                maker.height.equalTo(0)
            }
            
            priceLabel.snp.updateConstraints { maker in
                maker.left.equalToSuperview()
                maker.top.equalTo(areaLabel.snp.bottom).offset(0)
                maker.height.equalTo(24)
                maker.width.lessThanOrEqualTo(130)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        majorTitle.snp.updateConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        extendTitle.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(4)
            maker.height.equalTo(17)
        }
        
        areaLabel.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.height.equalTo(15)
        }
        
        priceLabel.snp.updateConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(24)
            maker.width.lessThanOrEqualTo(130)
        }
    }

}



class UserMsgSectionView: UIView {
    
    lazy var timeAreaBgView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.backgroundColor = color(0, 0, 0, 0.1)
        return re
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: "#081f33")
        label.text = ""
        return label
    }()
    
    lazy var tipsBgView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#ffffff")
        label.text = ""
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)

        self.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        addSubview(timeAreaBgView)
        timeAreaBgView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(20)
            maker.height.equalTo(20)
        }
        
        timeAreaBgView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(20)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
        }

        addSubview(tipsBgView)
        tipsBgView.snp.makeConstraints { (maker) in
            maker.top.equalTo(timeAreaBgView.snp.bottom).offset(10)
            maker.bottom.left.right.equalToSuperview()
        }

        tipsBgView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.centerY.equalToSuperview()
        }
        self.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
            maker.left.right.equalToSuperview()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class UserMsgFooterOpenAllView: UIView {
    
    lazy var openAllBtn: UIButton = {
        let result = UIButton()
        return result
    }()
    
    lazy var title: UILabel = {
        let re = UILabel()
        re.backgroundColor = UIColor.clear
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var bottomMaskView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        return re
    }()
    
    lazy var settingArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "arrowicon-msseage")
        return re
    }()
        
    let disposeBag = DisposeBag()
    
    
    init(callBack:(() -> Void)? = nil) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.white
        
        addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(0)
        }
        
        addSubview(openAllBtn)
        openAllBtn.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(0)
            maker.bottom.equalTo(bottomMaskView.snp.top) // .offset(-6)
        }
        
        addSubview(title)
        title.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.centerY.equalTo(openAllBtn)
            
        }
        
        addSubview(settingArrowImageView)
        settingArrowImageView.snp.makeConstraints { maker in
            maker.height.equalTo(18)
            maker.width.equalTo(18)
            maker.centerY.equalTo(openAllBtn.snp.centerY)
            maker.right.equalToSuperview().offset(-14)
        }
        
        self.lu.addTopBorder()
        
        openAllBtn.rx.tap.subscribe(onNext: callBack ?? {})
            .disposed(by: disposeBag)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

