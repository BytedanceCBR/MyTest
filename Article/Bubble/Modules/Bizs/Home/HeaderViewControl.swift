//
//  HeaderViewControl.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

enum HomeHeaderState {
    case normal
    case suspend
}

class HomeHeaderStateControl {

    private var state: HomeHeaderState = .suspend

    var onStateChanged: ((HomeHeaderState) -> Void)?

    var onContentOffsetChanged: ((HomeHeaderState, CGPoint) -> Void)?
    
    var disable: Bool = false

    func scrollViewContentYOffsetObserve(offset: CGPoint) {
        if disable {
            return
        }
        if offset.y > 0 && state == .suspend {
            state = .normal
            onStateChanged?(state)
        } else if offset.y <= 0 && state == .normal {
            state = .suspend
            onStateChanged?(state)
        }
        onContentOffsetChanged?(state, offset)
    }
}
