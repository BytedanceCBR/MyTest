//
//  CommonUIStyle.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class CommonUIStyle {
    class Font {
        static let pingFangRegular: (CGFloat) -> UIFont? = { (size) in
            UIFont(name: "PingFangSC-Regular", size: size)
        }

        static let pingFangMedium: (CGFloat) -> UIFont? = { (size) in
            UIFont(name: "PingFangSC-Medium", size: size)
        }
    }
}
