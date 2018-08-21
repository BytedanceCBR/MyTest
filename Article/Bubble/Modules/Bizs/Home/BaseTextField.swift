//
//  BaseTextField.swift
//  Lark
//
//  Created by 刘晚林 on 2017/1/8.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import UIKit

@IBDesignable
open class BaseTextField: UITextField {

    @IBInspectable open var insetX: CGFloat = 0
    @IBInspectable open var insetY: CGFloat = 0
    @IBInspectable open var maxLength: Int = Int.max
    @IBInspectable open var exitOnReturn: Bool = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open func commonInit() {
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
    }

    // placeholder position
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var insetX = self.insetX
        if let leftView = self.leftView {
            insetX += leftView.bounds.width
        }
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var insetX = self.insetX
        if let leftView = self.leftView {
            insetX += leftView.bounds.width
        }
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    open func cut(_ text: String) -> (Bool, String) {
        var chCount = 0
        var bytesCount = 0
        var lengthExceed = false
        for ch in text {
            let chBytes = "\(ch)".lengthOfBytes(using: String.Encoding.utf8) >= 3 ? 2 : 1
            if bytesCount + chBytes > self.maxLength {
                lengthExceed = true
                break
            }
            chCount += 1
            bytesCount += chBytes
        }
        return (lengthExceed, String(text[..<text.index(text.startIndex, offsetBy: chCount)]))
    }

    @objc
    fileprivate func editingChanged() {
        guard let text = self.text else {
            return
        }

        let (lengthExceed, result) = cut(text)
        if lengthExceed {
            self.text = result
        }
    }

    @objc
    fileprivate func editingDidEndOnExit() {
        if self.exitOnReturn {
            self.endEditing(true)
        }
    }

}
