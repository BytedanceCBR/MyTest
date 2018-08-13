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
    case expand(String)
}

class SearchFilterPanel: UIView {

    var itemViews: [SearchConditionItemView] = []

    let disposeBag = DisposeBag()

    var items: [SearchConditionItem] = []

    init() {
        super.init(frame: CGRect.zero)
        let color = hexStringToUIColor(hex: "#e8e8e8")
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
        self.items = items

        refresh()
    }
    
    func refresh() {
        itemViews.forEach {
            $0.removeFromSuperview()
        }
        itemViews = items.map { item -> SearchConditionItemView in
            let result = SearchConditionItemView()
            if item.isHighlighted {
                if item.isExpand {
                    result.setConditionLabelText(
                            label: item.label,
                            color: hexStringToUIColor(hex: "#f85959"),
                            icon: #imageLiteral(resourceName: "icon-triangle-retract"))
                    result.triangle.image = #imageLiteral(resourceName: "icon-triangle-retract")
                } else {
                    result.setConditionLabelText(
                            label: item.label,
                            color: hexStringToUIColor(hex: "#f85959"),
                            icon: #imageLiteral(resourceName: "icon-triangle-open-highlighted"))
                    result.triangle.image = #imageLiteral(resourceName: "icon-triangle-open-highlighted")
                }

            } else {
                result.setConditionLabelText(
                        label: item.label,
                        color: hexStringToUIColor(hex: "#222222"),
                        icon: #imageLiteral(resourceName: "icon-triangle-open"))
                result.triangle.image = #imageLiteral(resourceName: "icon-triangle-open")
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

    func selectedItem() -> SearchConditionItem? {
        return items.first(where: { $0.isExpand })
    }

    func selectedIndex() -> Int {
        return items
            .enumerated()
            .first(where: { $0.1.isExpand })
            .map { $0.0 } ?? 0
    }

}

func setConditionItemTypeByParser(item: SearchConditionItem,
                                  reload: @escaping () -> Void,
                                  parser: @escaping ([Node]) -> ConditionItemType) -> ([Node]) -> Void {
    return { (nodes) in
        return setConditionItemType(item: item, reload: reload)(parser(nodes))
    }
}

func setConditionItemType(
    item: SearchConditionItem,
    reload: @escaping () -> Void) -> (ConditionItemType) -> Void {
    return { (type) in
        setFilterConditionItemBy(
            item: item,
            reload: reload,
            conditionItemType: type)
    }
}

func setFilterConditionItemBy(item: SearchConditionItem, reload: @escaping () -> Void, conditionItemType: ConditionItemType) {
    item.isExpand = false
    switch conditionItemType {
        case let .noCondition(label):
            item.label = label
            item.isHighlighted = false
            item.isSeted = false
        case let .condition(label):
            item.label = label
            item.isHighlighted = true
            item.isSeted = true
        case let .expand(label):
            item.label = label
            item.isHighlighted = true
            item.isExpand = true
    }
    reload()
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

    var isExpand: Bool = false {
        didSet {

        }
    }

    init() {
        super.init(frame: CGRect.zero)
        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.height.equalTo(15)
        }

        addSubview(clickBtn)
        clickBtn.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }

        addSubview(triangle)
        triangle.snp.makeConstraints { maker in
            maker.left.equalTo(conditionLabel.snp.right).priority(.high)
            maker.right.lessThanOrEqualToSuperview().priority(.high)
            maker.centerY.equalTo(conditionLabel.snp.centerY)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setConditionLabelText(label: String, color: UIColor, icon: UIImage) {
        conditionLabel.textColor = color
        let attributeText = NSMutableAttributedString(string: "\(label) ")
        let attributes: [NSAttributedStringKey: Any] = [.font: CommonUIStyle.Font.pingFangRegular(15)]
        attributeText.setAttributes(attributes, range: NSRange(location: 0, length: label.count + 1))
        conditionLabel.attributedText = attributeText
    }

}

class SearchConditionItem {
    var itemId: Int = -1
    var label: String = ""
    var onClick: ((Int) -> Void)? = nil
    var isHighlighted: Bool
    var isExpand: Bool
    var isSeted: Bool

    init(itemId: Int, label: String, onClick: ((Int) -> Void)? = nil) {
        self.isHighlighted = false
        self.isExpand = false
        self.label = label
        self.onClick = onClick
        self.itemId = itemId
        self.isSeted = false
    }
}

func transferSearchConfigFilterItemTo(_ configFilter: SearchConfigFilterItem) -> SearchConditionItem {
    return SearchConditionItem(
        itemId: configFilter.tabId ?? -1,
        label: configFilter.text ?? "")
}

func transferSearchConfigOptionToNode(
    options: [SearchConfigOption],
    isSupportMulti: Bool,
    parentLabel: String? = nil) -> [Node] {
    return options.map({ (option) -> Node in
        /// 服务器的格式设计造成这里只能在一遇到标记为可以多选后，则将其所有子节点都理解为可以多选。
        let theIsSupportMulti = option.supportMulti ?? false || isSupportMulti
        let externalConfig = option.getOptionValueString(supportMulti: theIsSupportMulti)
        return Node(
            id: option.text ?? "",
            label: option.text ?? "",
            externalConfig: externalConfig,
            isSupportMulti: theIsSupportMulti,
            isEmpty: option.isEmpty,
            isNoLimit: option.isNoLimit,
            parentLabel: parentLabel,
            children: transferSearchConfigOptionToNode(
                options: option.options ?? [],
                isSupportMulti: theIsSupportMulti,
                parentLabel: option.text))
    })
}

extension SearchConfigOption {

    func getOptionValueString(supportMulti: Bool) -> String {
        guard let type = self.type else {
            return ""
        }
        
        return "\(type)[]=\(self.value)"
//        if supportMulti == true {
//            return "\(type)[]=\(self.value)"
//        } else {
//            return "\(type)[]=\(self.value)"
//        }
    }
//
//    func getOptionValueString(supportMulti: Bool) -> String {
//        guard let type = self.type else {
//            return ""
//        }
//        if supportMulti == true {
//            if let theValue = value as? Array<Any> {
//                if let (head, tail) = theValue.slice.decomposed {
//                    return "\(type)[]=" + tail.reduce("[\(head)") { (result, obj) -> String in
//                            result + ",\(obj)"
//                        } + "]"
//                }
//            }
//            return "\(type)[]=\(value)"
//        } else {
//            if let theValue = value as? Array<Any>, let type = self.type {
//                if let (head, tail) = theValue.slice.decomposed {
//                    return tail.reduce("\(type)[]=\(head)") { (result, obj) -> String in
//                        result + "&\(type)[]=\(obj)"
//                    }
//                }
//            }
//            return supportMulti ? "\(type)[]=\(value)" : "\(type)=\(value)"
//        }
//
//    }
}
