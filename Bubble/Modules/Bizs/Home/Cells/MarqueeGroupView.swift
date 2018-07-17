//
//  MarqueeGroupView.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class MarqueeItemView: UIView {
    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class MarqueeGroupView: UIScrollView {

    var itemProvider: (() -> [MarqueeItemView])?

    private var itemViews: [MarqueeItemView]?

    lazy var contentView: UIView = {
        UIView()
    }()

    var catulateQubeSize: ((MarqueeGroupView) -> CGSize)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.frame = self.bounds
    }

    func loadData() {
        itemViews?.forEach { itemView in
            itemView.removeFromSuperview()
        }
        itemViews = itemProvider?()
        itemViews?.forEach {
            addSubview($0)
        }
        layoutItems()
    }

    func layoutItems() {
        let qubeSize = self.qubeSize()
        if let itemViews = itemViews {
            itemViews.enumerated()
                    .forEach({ (e) in
                        let (index, ele) = e
                        self.layoutItem(
                                index: index,
                                itemView: ele,
                                qubeSize: qubeSize)
                    })
            resetContentSize()
        }
    }

    func resetContentSize() {
        let qubeSize = self.qubeSize()
        if let itemViews = itemViews {

            self.contentSize = CGSize(
                    width: qubeSize.width * CGFloat(itemViews.count),
                    height: qubeSize.height)
        }
    }

    func layoutItem(
            index: Int,
            itemView: MarqueeItemView,
            qubeSize: CGSize) {
        itemView.frame = CGRect(
                x: qubeSize.width * CGFloat(index),
                y: 0,
                width: qubeSize.width,
                height: qubeSize.height)
    }

    func qubeSize() -> CGSize {
        return catulateQubeSize?(self) ?? CGSize(
                width: self.bounds.height,
                height: self.bounds.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        layoutItems()
    }
    
    func count() -> Int {
        return itemViews?.count ?? 0
    }
}
