//
//  HomeSpringBoard.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class HomeSpringBoard: MarqueeGroupView {

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        self.isScrollEnabled = false
        self.itemProvider = {
            [HomeSpringBoardItemView(),
             HomeSpringBoardItemView(),
             HomeSpringBoardItemView(),
             HomeSpringBoardItemView()]
        }
        self.catulateQubeSize = HomeSpringBoardItemView.qubeSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resetContentSize() {
        self.contentSize.equalTo(self.bounds.size)
    }
}
