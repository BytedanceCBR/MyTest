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

    override init() {
        super.init()
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(30)
            maker.top.equalToSuperview().offset(10)
        }
        imageView.image = #imageLiteral(resourceName: "temp")
        addSubview(label)
        label.snp.makeConstraints { [unowned imageView] maker in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(imageView.snp.bottom)
        }
        label.text = "home"
        label.font = UIFont.systemFont(ofSize: 12)
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
