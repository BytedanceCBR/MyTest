//
//  CommonUIStyle.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class CommonUIStyle {
    
    class Screen {
        static let widthScale: CGFloat = UIScreen.main.bounds.width / 375
        static let isIphoneX: Bool = ((UIScreen.main.bounds.width == 375 && UIScreen.main.bounds.height == 812) || (UIScreen.main.bounds.width == 414 && UIScreen.main.bounds.height == 896))

    }
    
    class Font {
        static let pingFangRegular: (CGFloat) -> UIFont = { (size) in
            UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }

        static let pingFangMedium: (CGFloat) -> UIFont = { (size) in
            UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }

        static let pingFangSemibold: (CGFloat) -> UIFont = { (size) in
            UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
         }
    }
    
    class DateTime {
        static let dateFormat: DateFormatter = {
            let re = DateFormatter()
            re.dateFormat = "yyyy年MM月dd日"
            return re
        }()

        static let simpleDataFormat: DateFormatter = {
            let re = DateFormatter()
            re.dateFormat = "MM-dd"
            return re
        }()
        static let monthDataFormat: DateFormatter = {
            let re = DateFormatter()
            re.dateFormat = "M月"
            return re
        }()
        
    }

    class TabBar {
        static let height: CGFloat = CommonUIStyle.Screen.isIphoneX ? 77 : 49
    }

    class NavBar {
        static let height: CGFloat = 64
    }

    class StatusBar {
        static let height: CGFloat = CommonUIStyle.Screen.isIphoneX ? 44 : 20
    }
}

func attributeText(_ text: String, color: UIColor, font: UIFont) -> NSAttributedString {
    let attrText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: color,
                                                                 NSAttributedStringKey.font: font])
    return attrText
}
