//
// Created by linlin on 2018/6/28.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class PopupMenuView: UIControl {

    let disposeBag = DisposeBag()

    lazy var popMenuContainer: UIView = {
        let result = UIView()
        result.layer.shadowOffset = CGSize(width: 0, height: 2)
        result.layer.shadowRadius = 4
        result.layer.shadowColor = UIColor.black.cgColor
        result.layer.shadowOpacity = 0.1
        result.backgroundColor = UIColor.white
        return result
    }()

    weak var targetView: UIView?

    var menus: [PopupMenuItem]

    init(targetView: UIView, menus: [PopupMenuItem]) {
        self.menus = menus
        self.targetView = targetView
        super.init(frame: CGRect.zero)
        
        rx.controlEvent(.touchUpInside)
                .subscribe(onNext: { void in
                    self.removeFromSuperview()
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showOnTargetView() {
        guard let targetView = targetView, let superView = self.superview else {
            assertionFailure()
            return
        }
        addSubview(popMenuContainer)
        
        let frame = targetView.convert(targetView.frame, to: superView)
        popMenuContainer.snp.makeConstraints { maker in
            maker.top.equalTo(frame.maxY)
            maker.left.equalTo(frame.minX)
            maker.width.equalTo(80)
        }

        let itemViews = menus.map { item -> PopupMenuItemView in
            let btn = PopupMenuItemView()
            btn.rx.controlEvent(.touchUpInside)
                    .subscribe(onNext: { void in
                        item.onClick?()
                    })
                    .disposed(by: disposeBag)
            btn.label.text = item.label
            if item.isSelected {
                btn.label.textColor = hexStringToUIColor(hex: "#299cff")
            }
            return btn
        }

        itemViews.forEach { [unowned popMenuContainer] view in
            popMenuContainer.addSubview(view)
        }
        if itemViews.count == 1, let itemView = itemViews.first {
            itemView.snp.makeConstraints { (maker) in
                maker.top.bottom.equalToSuperview()
            }
        } else {
            itemViews.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0)
        }
        itemViews.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
        }
    }

}


class PopupMenuItem {

    var label: String

    var isSelected: Bool

    var onClick: (() -> Void)?

    init(label: String, isSelected: Bool) {
        self.label = label
        self.isSelected = isSelected
    }

}

class PopupMenuItemView: UIControl {

    lazy var label: UILabel = {
        let result = UILabel()
        result.highlightedTextColor = hexStringToUIColor(hex: "#f85959")
        result.textColor = hexStringToUIColor(hex: "#505050")
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textAlignment = .left
        return result
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.top.bottom.equalToSuperview()
            maker.height.equalTo(30)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
