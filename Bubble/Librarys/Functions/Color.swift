//
//  Color.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

typealias Filter = (UIImage) -> UIImage

func fillColorOnShap(color: UIColor) -> Filter {
    return { (image) in
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        if let context = UIGraphicsGetCurrentContext(),
            let cgImage = image.cgImage {
            context.translateBy(x: 0, y: image.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            context.clip(to: rect, mask: cgImage)
            color.setFill()
            context.fill(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage ?? image
        }
        return image
    }
}

func argb(argb: Int64) -> UIColor {
    return color(
        CGFloat((argb & 0x00FF0000) >> 16),
        CGFloat((argb & 0x0000FF00) >> 8),
        CGFloat((argb & 0x000000FF)),
        CGFloat((argb & 0xFF000000) >> 24) / 255.0
    )
}

func rgb(rgb: Int64, alpha: CGFloat) -> UIColor {
    return color(
        CGFloat((rgb & 0x00FF0000) >> 16),
        CGFloat((rgb & 0x0000FF00) >> 8),
        CGFloat((rgb & 0x000000FF)),
        alpha
    )
}

func UIColorRGB(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat) -> UIColor {
    return UIColorRGBA(red, green, blue, 1.0)
}

func color(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat,
    _ alpha: CGFloat = 1) -> UIColor {
    return UIColorRGBA(red, green, blue, alpha)
}

func UIColorRGBA(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat,
    _ alpha: CGFloat = 1) -> UIColor {
    return UIColor(
        red: red / 255.0,
        green: green / 255.0,
        blue: blue / 255.0,
        alpha: alpha)
}

func colorToRGB(color: UIColor) -> Int32 {
    typealias RGBComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var c: RGBComponents = (0, 0, 0, 0)

    if color.getRed(&c.red, green: &c.green, blue: &c.blue, alpha: &c.alpha) {
        let a = Int32(c.alpha * 255.0) << 24
        let r = Int32(c.red * 255.0) << 16
        let g = Int32(c.green * 255.0) << 8
        let b = Int32(c.blue * 255.0)
        return Int32(a | r | g | b)
    } else {
        return -1
    }
}

func UIColorRGBAToRGB(rgbBackground: UIColor, rgbaColor: UIColor) -> UIColor {
    typealias RGBComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBComponents = (0, 0, 0, 0)
    var rgb: RGBComponents = (0, 0, 0, 0)

    if !rgbaColor.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha) {
        return UIColor.white
    }
    if !rgbBackground.getRed(&rgb.red, green: &rgb.green, blue: &rgb.blue, alpha: &rgb.alpha) {
        return UIColor.white
    }
    let alpha = rgba.alpha
    return UIColor(
        red: (1 - alpha) * rgb.red + alpha * rgba.red,
        green: (1 - alpha) * rgb.green + alpha * rgba.green,
        blue: (1 - alpha) * rgb.blue + alpha * rgba.blue,
        alpha: 1)
}

func hexStringToUIColor (hex: String?, alpha: CGFloat = 1.0) -> UIColor {
    guard let hex = hex else {
        return UIColor.black
    }

    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
        cString.remove(at: cString.startIndex)
    }

    if cString.count != 6 {
        return UIColor.gray
    }

    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: alpha
    )
}

func intToUIColor(color: Int64, defaultColor: Int64) -> UIColor {
    if color != -1 {
        return argb(argb: color)
    } else {
        return argb(argb: defaultColor)
    }
}
