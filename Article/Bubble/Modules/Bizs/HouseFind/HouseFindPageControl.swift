//
//  HouseFindPageControl.swift
//  NewsLite
//
//  Created by leo on 2018/11/25.
//

import Foundation
import RxSwift
class HouseFindPageControl: NSObject, UIScrollViewDelegate {
    let segmentControl: FWSegmentedControl
    let pageView: UIScrollView
    private var pageIndex: Int
    var didPageIndexChanged: ((Int) -> Void)?

    init(segmentControl: FWSegmentedControl,
         pageView: UIScrollView) {
        self.segmentControl = segmentControl
        self.pageView = pageView
        self.pageIndex = 0
        super.init()
        pageView.delegate = self
    }

    func pageOffsetXByIndex(_ index: Int) -> Int {
        return index * Int(pageView.frame.width)
    }

    func pageIndexOfContentOffsetX() -> Int {
        let halfScreenWidth = pageView.frame.size.width / 2;
        if pageView.contentOffset.x < 0 || pageView.frame.width == 0 {
            return 0
        }
        return Int((pageView.contentOffset.x + halfScreenWidth) / pageView.frame.width)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = pageIndexOfContentOffsetX()
        segmentControl.setSelectedSegmentIndex(index: index, animated: true)
        if pageIndex != index {
            pageIndex = index
            didPageIndexChanged?(index)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = pageIndexOfContentOffsetX()
        segmentControl.setSelectedSegmentIndex(index: index, animated: true)
        if pageIndex != index {
            pageIndex = index
            didPageIndexChanged?(index)
        }
    }
}
