//
//  MultiColumnTableSelectorPanel.swift
//  Bubble
//
//  Created by linlin on 2018/6/19.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class MultiColumnTableSelectorPanel: UIView {


    var columnLoader: ((Int) -> UIView)?

    var displayColumnCount: Int

    var viewItems: [UIView] = {
        []
    }()

    let columnWidthToFit: CGFloat

    init(displayColumnCount: Int,
         columnWidthToFit: CGFloat) {
        self.displayColumnCount = displayColumnCount
        self.columnWidthToFit = columnWidthToFit
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplayColumnCount(_ count: Int) {
        displayColumnCount = count
        loadView()
        layoutItems()
    }

    private func loadView() {
        if viewItems.count < displayColumnCount {
            (viewItems.count..<displayColumnCount)
                    .forEach { [unowned self] (index) in
                if let view = columnLoader?(index) {
                    view.frame = CGRect(
                            x: self.bounds.width,
                            y: 0,
                            width: 0,
                            height: self.bounds.height)
                    self.addSubview(view)
                }
            }
        }
    }

    func pushView() {
        displayColumnCount += 1
        loadView()
        layoutItems(animinated: true)
    }

    private func layoutItems(animinated: Bool = false) {
        func layoutSubItems(_ items: [UIView]) -> () -> Void {
            return {
                var indexX: CGFloat = 0
                let reviewList: [UIView] = items.reversed()
                if let (head, tail) = reviewList.decompose {
                    let tails: [UIView] = tail.reversed()
                    tails.enumerated().forEach({ (e) in
                        let (offset, v) = e
                        indexX = CGFloat(offset) * self.columnWidthToFit
                        v.frame = CGRect(
                                x: indexX,
                                y: 0,
                                width: self.columnWidthToFit,
                                height: self.bounds.height)
                    })
                    head.frame = CGRect(
                            x: indexX + self.columnWidthToFit,
                            y: 0,
                            width: self.bounds.width - (indexX + self.columnWidthToFit),
                            height: self.bounds.height)
                }
            }
        }

        if animinated {
            UIView.animate(withDuration: 0.5, animations: layoutSubItems(viewItems))
        } else {
            layoutSubItems(viewItems)()
        }
    }

}
