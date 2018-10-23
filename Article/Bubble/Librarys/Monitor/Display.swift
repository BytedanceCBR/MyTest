//
//  Display.swift
//  LarkUIKit
//
//  Created by liuwanlin on 2017/12/14.
//  Copyright © 2017年 liuwanlin. All rights reserved.
//

import Foundation
import UIKit

public enum DisplayType {
    case unknown
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6plus
    static let iPhone7 = iPhone6
    static let iPhone7plus = iPhone6plus
    case iPhoneX
}

public final class Display {
    public class var width: CGFloat { return UIScreen.main.bounds.size.width }
    public class var height: CGFloat { return UIScreen.main.bounds.size.height }
    public class var maxLength: CGFloat { return max(width, height) }
    public class var minLength: CGFloat { return min(width, height) }
    public class var zoomed: Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    public class var retina: Bool { return UIScreen.main.scale >= 2.0 }
    public class var phone: Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    public class var pad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
//    public class var carplay: Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
//    public class var tv: Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    public class var typeIsLike: DisplayType {
        if phone && maxLength < 568 {
            return .iPhone4
        } else if phone && maxLength == 568 {
            return .iPhone5
        } else if phone && maxLength == 667 {
            return .iPhone6
        } else if phone && maxLength == 736 {
            return .iPhone6plus
        } else if phone && maxLength == 812 {
            return .iPhoneX
        }
        return .unknown
    }
}
