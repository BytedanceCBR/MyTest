//
//  WebImageItemView.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class WebImageItemView: MarqueeItemView {

    lazy var imageView: UIImageView = {
        UIImageView()
    }()

    override init() {
        super.init()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        imageView.image = #imageLiteral(resourceName: "house-1")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }

}
