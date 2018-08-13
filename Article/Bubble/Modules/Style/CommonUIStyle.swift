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
            re.dateFormat = "MM月"
            return re
        }()
        
    }

    class TabBar {
        static let height: CGFloat = 44
    }

    class NavBar {
        static let height: CGFloat = 64
    }

    class StatusBar {
        static let height: CGFloat = 20
    }
}
