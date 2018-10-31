//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class EmptyMaskView: UIView {

    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "group-9")
        return re
    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.text = "网络异常"
        return re
    }()
    
    lazy var retryBtn: UIButton = {
        let re = UIButton()
        re.setTitleColor(hexStringToUIColor(hex: "#299cff"), for: .normal)
        re.layer.masksToBounds = true
        re.layer.borderWidth = 1
        re.setTitle("重新加载", for: .normal)
        re.layer.cornerRadius = 15
        re.titleLabel?.font = CommonUIStyle.Font.pingFangRegular(14)
        re.layer.borderColor = hexStringToUIColor(hex: "#299cff").cgColor
        re.isHidden = true
        return re
    }()

    lazy var contentView: UIView = {
        let re = UIView()
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.equalToSuperview()
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.height.equalTo(20)
            maker.centerY.equalToSuperview().offset(20)
        }
        
        
        contentView.addSubview(icon)
        icon.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(126)
            maker.bottom.equalTo(label.snp.top).offset(-20)
        }


//        label.ttf_hitTestEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        
        contentView.addSubview(retryBtn)
        retryBtn.snp.makeConstraints { maker in
            maker.top.equalTo(label.snp.bottom).offset(18)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
            maker.width.equalTo(84)
        }
        retryBtn.ttf_hitTestEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
