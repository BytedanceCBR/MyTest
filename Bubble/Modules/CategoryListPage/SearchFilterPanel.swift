//
//  SearchFilterPanel.swift
//  Bubble
//
//  Created by linlin on 2018/6/19.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import RxCocoa
import RxSwift

enum ConditionItemType {
    case noCondition(String)
    case condition(String)
}

class SearchFilterPanel: UIView {

    var itemViews: [SearchConditionItemView] = []

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)
        let color = hexStringToUIColor(hex: "#e8e8e8")
        self.lu.addTopBorder(color: color)
        self.lu.addBottomBorder(color: color)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reLayoutAllItems()
    }

    func reLayoutAllItems() {

        let itemWidth = self.bounds.width / CGFloat(itemViews.count)
        itemViews.enumerated().forEach { (e) in
            let (offset, view) = e
            view.frame = CGRect(
                    x: itemWidth * CGFloat(offset),
                    y: 0,
                    width: itemWidth,
                    height: self.bounds.height)
        }
    }

    func setItems(items: [SearchConditionItem]) {
        itemViews.forEach {
            $0.removeFromSuperview()
        }
        itemViews = items.map { item -> SearchConditionItemView in
            let result = SearchConditionItemView()
            if item.isHighlighted {
                result.setConditionLabelText(label: item.label, color: hexStringToUIColor(hex: "#f85959"), icon: #imageLiteral(resourceName: "icon-triangle-retract"))
            } else {
                result.setConditionLabelText(label: item.label, color: hexStringToUIColor(hex: "#222222"), icon: #imageLiteral(resourceName: "icon-triangle-open"))
            }
            return result
        }

        zip(itemViews, items)
                .enumerated()
                .forEach { (e) in
                    let (offset, (view, item)) = e
                    view.clickBtn.rx.tap
                            .subscribe(onNext: { void in
                                item.onClick?(offset)
                            })
                            .disposed(by: disposeBag)
                }

        itemViews.forEach { view in
            addSubview(view)
        }
        reLayoutAllItems()
    }

}

class SearchConditionItemView: UIView {

    lazy var conditionLabel: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textAlignment = .center
        return result
    }()

    lazy var triangle: UIImageView = {
        let result = UIImageView()
        result.image = #imageLiteral(resourceName: "icon-triangle-open")
        return result
    }()

    lazy var clickBtn: UIButton = {
        UIButton()
    }()

    var isHighlighted = false

    init() {
        super.init(frame: CGRect.zero)
        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints { maker in
            maker.left.right.centerY.equalToSuperview()
            maker.height.equalTo(15)
        }

        addSubview(clickBtn)
        clickBtn.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setConditionLabelText(label: String, color: UIColor, icon: UIImage) {
        conditionLabel.textColor = color
        let attributeText = NSMutableAttributedString(string: label)
        let attributes: [NSAttributedStringKey: Any] = [.font: CommonUIStyle.Font.pingFangRegular(15)!]
        attributeText.setAttributes(attributes, range: NSRange(location: 0, length: label.count))
        let attachment = NSTextAttachment()
        attachment.image = icon
        let attachmentText = NSAttributedString(attachment: attachment)
        attributeText.append(attachmentText)
        conditionLabel.attributedText = attributeText
    }

}

class SearchConditionItem {
    var label: String = ""
    var onClick: ((Int) -> Void)? = nil
    var isHighlighted: Bool

    init(label: String, onClick: ((Int) -> Void)? = nil) {
        self.isHighlighted = false
        self.label = label
        self.onClick = onClick
    }
}
