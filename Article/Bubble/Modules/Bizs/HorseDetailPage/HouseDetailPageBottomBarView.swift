//
// Created by linlin on 2018/7/9.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class HouseDetailPageBottomBarView: UIView {

    lazy var leftView: UIView = {
        let re = UIView()
        return re
    }()
    
    lazy var avatarView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.layer.cornerRadius = 21
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return label
    }()
    
    lazy var agencyLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return label
    }()
    
    lazy var contactBtn: FHLoadingButton = {
        let re = FHLoadingButton()

        re.setTitleColor(.white, for: .normal)
        re.setTitleColor(.white, for: .highlighted)
        re.titleLabel?.font = CommonUIStyle.Font.pingFangRegular(16)
        re.setTitle("电话咨询", for: .normal)
        re.setTitle("电话咨询", for: .highlighted)
        
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.lu.addTopBorder()
        
        addSubview(leftView)
        leftView.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(0)
        }
        
        leftView.addSubview(avatarView)
        leftView.addSubview(nameLabel)
        leftView.addSubview(agencyLabel)
        
        avatarView.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(42)
        }
        nameLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(avatarView.snp.right).offset(10)
            maker.top.equalTo(avatarView).offset(2)
            maker.right.equalToSuperview()
        }
        agencyLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(nameLabel)
            maker.top.equalTo(nameLabel.snp.bottom)
            maker.right.equalToSuperview()
        }

        addSubview(contactBtn)
        contactBtn.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.bottom.equalTo(-10)
            maker.left.equalTo(leftView.snp.right).offset(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(44)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class FHLoadingButton: UIButton {
    
    var isLoading: Bool = false
    
    func startLoading() {
        
        self.isLoading = true
        self.isEnabled = false
        loadingAnimateView.isHidden = false
        let duration: CFTimeInterval = 0.4
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        loadingAnimateView.layer.add(rotationAnimation, forKey: "rotationAnimation")

    }
    
    func stopLoading() {

        self.isLoading = false
        self.isEnabled = true
        loadingAnimateView.isHidden = true
        loadingAnimateView.layer.removeAllAnimations()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isLoading {
            
            titleLabel?.sizeToFit()
            loadingAnimateView.centerY = self.height / 2
            loadingAnimateView.left = (self.width - loadingAnimateView.width - (titleLabel?.width ?? 0) - 4) / 2
            
            titleLabel?.left = loadingAnimateView.right + 4
        }else {
            
            titleLabel?.centerY = self.height / 2
            titleLabel?.centerX = self.width / 2

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupUI() {
        
        addSubview(loadingAnimateView)
        loadingAnimateView.size = CGSize(width: 16, height: 16)
        loadingAnimateView.isHidden = true
    }
    
    
    lazy var loadingAnimateView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: "house_loading"))
        return imageView
    }()
}

