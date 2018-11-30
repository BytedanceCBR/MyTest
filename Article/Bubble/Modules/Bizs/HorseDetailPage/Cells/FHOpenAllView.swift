//
//  FHOpenAllView.swift
//  Article
//
//  Created by 张静 on 2018/11/30.
//

import UIKit

class FHOpenAllView: UIView {

    var topPadding: CGFloat = 20
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        self.addSubview(topLine)
        topLine.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(topPadding)
            maker.height.equalTo(0.5)
        }
        self.addSubview(openAllBtn)
        openAllBtn.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(topLine.snp.bottom)
            maker.bottom.equalToSuperview()
        }
        
        self.addSubview(title)
        title.snp.makeConstraints { maker in
            maker.centerX.equalTo(openAllBtn).offset(-9)
            maker.centerY.equalTo(openAllBtn)
            
        }
        self.addSubview(settingArrowImageView)
        settingArrowImageView.snp.makeConstraints { maker in
            maker.height.equalTo(14)
            maker.width.equalTo(14)
            maker.centerY.equalTo(openAllBtn.snp.centerY)
            maker.left.equalTo(title.snp.right).offset(4)
        }
        
    }
    
    lazy var topLine: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return result
    }()
    
    lazy var openAllBtn: UIButton = {
        let result = UIButton()
        return result
    }()
    
    lazy var title: UILabel = {
        let re = UILabel()
        let attriStr = NSMutableAttributedString(
            string: "查看更多",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHDarkIndigoColor)])
        
        re.backgroundColor = UIColor.white
        re.attributedText = attriStr
        return re
    }()
    
    lazy var settingArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "setting-arrow")
        return re
    }()
}
