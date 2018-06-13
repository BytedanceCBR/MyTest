//
//  HeaderViewControl.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

typealias CGPointObserve = (CGPoint) -> Void

struct CGPointObserver {
    let observe: CGPointObserve
    init(_ observe: @escaping CGPointObserve) {
        self.observe = observe
    }
}

extension CGPointObserver {
    func join(_ observe: @escaping CGPointObserve) -> CGPointObserver {
        return CGPointObserver() {(point) in
            self.observe(point)
            observe(point)
        }
    }

    func filter(_ predict: @escaping (CGPoint) -> Bool) -> CGPointObserver {
        return CGPointObserver() {(point) in
            if predict(point) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.observe(point)
                })
            }
        }
    }
}

func offsetCriticalPointThrottle(_ criticalPoint: CGFloat) -> (CGFloat) -> Bool {
    var oldOffset: CGFloat = 0
    return {(offset) in
        let preOffset = oldOffset
        oldOffset = offset
        if (offset > criticalPoint && preOffset <= criticalPoint) ||
            (offset < criticalPoint && preOffset >= criticalPoint) ||
            preOffset == 0 {
            return true
        } else {
            return false
        }
    }
}

func hiddenSearchItemByContentOffset(headerView: HomeHeaderSearchView) -> CGPointObserve {
    return { [weak headerView] (contentOffset) in
        if contentOffset.y > 0 {
            headerView?.hiddenSearchItem()
        } else {
            headerView?.showSearchItem()
        }
    }
}

func adjustNavBarByContentOffset(navController: UINavigationController?) -> CGPointObserve {
    return { [weak navController] (contentOffset) in
        if contentOffset.y > 0 {
            navController?.setNavigationBarHidden(false, animated: false)
        } else {
            navController?.setNavigationBarHidden(true, animated: false)
        }
    }
}
