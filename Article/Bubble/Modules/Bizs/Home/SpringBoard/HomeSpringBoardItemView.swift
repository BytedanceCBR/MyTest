//
//  HomeSpringBoardItemView.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class HomeSpringBoardItemView: MarqueeItemView {

    lazy var imageView: UIImageView = {
        UIImageView()
    }()

    lazy var label: UILabel = {
        UILabel()
    }()

    lazy var clickGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        return gesture
    }()

    override init() {
        super.init()
        addGestureRecognizer(clickGesture)
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(66)
            maker.top.equalToSuperview().offset(16)
        }
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview().offset(76)
            maker.bottom.equalToSuperview().offset(-20)
            maker.height.equalTo(20)
        }
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        label.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func qubeSize(groupView: MarqueeGroupView) -> CGSize {
        return CGSize(
                width: groupView.bounds.width / CGFloat(groupView.count()),
                height: groupView.bounds.height)
    }

}
