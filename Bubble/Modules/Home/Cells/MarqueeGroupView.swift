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
        let label = UILabel()
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        label.text = "hello"
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.frame = self.bounds
    }

    func loadData() {
        subviews.forEach { $0.removeFromSuperview() }
        itemViews = itemProvider?()
        itemViews?.forEach { addSubview($0) }
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
        return CGSize(
            width: self.bounds.height,
            height: self.bounds.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        layoutItems()
    }

}
