//
//  LoadingIndicatorView.swift
//  Bubble
//
//  Created by linlin on 2018/7/8.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class LoadingIndicatorView: UIView {

    lazy var message: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.text = "正在努力加载"
        return re
    }()

    lazy var loadingIndicator: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "loading_icon")
        return re
    }()

    var isAnimating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(message)
        message.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(16)
            maker.bottom.equalTo(-16)
            maker.height.equalTo(12)
         }

        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { maker in
            maker.width.height.width.equalTo(12)
            maker.centerY.equalTo(message.snp.centerY)
            maker.left.equalTo(message.snp.right).offset(5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.

     required init?(coder aDecoder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
     }
     // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */



    public final func startAnimating() {
        isAnimating = true
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(Int.max)
        loadingIndicator.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    public final func stopAnimating() {
        isAnimating = false
        loadingIndicator.layer.removeAllAnimations()
    }


}


class CycleIndicatorView: UIView {

    lazy var loadingIndicator: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "loading_icon")
        return re
    }()

    var isAnimating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { maker in
            maker.width.height.width.equalTo(20)
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalTo(-4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.

     required init?(coder aDecoder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
     }
     // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */



    public final func startAnimating() {
        isAnimating = true
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(Int.max)
        loadingIndicator.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    public final func stopAnimating() {
        isAnimating = false
        loadingIndicator.layer.removeAllAnimations()
    }


}
