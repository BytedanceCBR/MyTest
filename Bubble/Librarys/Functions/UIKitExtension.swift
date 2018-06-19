//
// Created by linlin on 2018/6/19.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
class UIKitExtension<BaseType> {
    var base: BaseType
    init(_ base: BaseType) {
        self.base = base
    }
}

protocol UIKitExtensionCompatible {
    associatedtype UIKitCompatibleType
    var lu: UIKitCompatibleType { get }
    static var lu: UIKitCompatibleType.Type { get }
}

extension UIKitExtensionCompatible {
    public var lu: UIKitExtension<Self> {
        return UIKitExtension(self)
    }

    public static var lu: UIKitExtension<Self>.Type {
        return UIKitExtension.self
    }
}

extension UIView: UIKitExtensionCompatible {}


extension UIKitExtension where BaseType: UIView {
    func addTopBorder(
        color: UIColor = UIColor.lightGray,
        leading: ConstraintRelatableTarget = 0,
        trailing: ConstraintRelatableTarget = 0) {
        let borderView = UIView(frame: CGRect.zero)
        self.base.addSubview(borderView)
        borderView.backgroundColor = color
        borderView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(leading)
            make.right.equalTo(trailing)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }

    func addleftBorder(
        color: UIColor = UIColor.lightGray,
        top: ConstraintRelatableTarget = 0,
        bottom: ConstraintRelatableTarget = 0) {
        let borderView = UIView(frame: CGRect.zero)
        self.base.addSubview(borderView)
        borderView.backgroundColor = color
        borderView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(top)
            make.bottom.equalTo(bottom)
            make.width.equalTo(1 / UIScreen.main.scale)
        }
    }

    func addRightBorder(
        color: UIColor = UIColor.lightGray,
        top: ConstraintRelatableTarget = 0,
        bottom: ConstraintRelatableTarget = 0) {
        let borderView = UIView(frame: CGRect.zero)
        self.base.addSubview(borderView)
        borderView.backgroundColor = color
        borderView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(top)
            make.bottom.equalTo(bottom)
            make.width.equalTo(1 / UIScreen.main.scale)
        }
    }

    @discardableResult
    func addBottomBorder(
        color: UIColor = UIColor.lightGray,
        leading: ConstraintRelatableTarget = 0,
        trailing: ConstraintRelatableTarget = 0) -> UIView {
        let borderView = UIView(frame: CGRect.zero)
        self.base.addSubview(borderView)
        borderView.backgroundColor = color
        borderView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-0.5)
            make.left.equalTo(leading)
            make.right.equalTo(trailing)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        return borderView
    }
}
