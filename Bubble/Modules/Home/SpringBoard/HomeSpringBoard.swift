//
//  HomeSpringBoard.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeSpringBoard: MarqueeGroupView {

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 116))
        self.isScrollEnabled = false
        self.catulateQubeSize = HomeSpringBoardItemView.qubeSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resetContentSize() {
        self.contentSize.equalTo(self.bounds.size)
    }
}

class HomeSpringBoardViewModel {

    weak var springBoard: HomeSpringBoard?

    let disposeBag = DisposeBag()

    init(springBoard: HomeSpringBoard) {
        self.springBoard = springBoard
        let springItems: [HomeSpringBoardItemView] = [
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-ershoufang"), label: "二手房"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-xinfang"), label: "新房"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-zufang"), label: "租房"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-xiaoqu"), label: "找小区")
        ]

        springItems.forEach { view in
            view.clickGesture.rx.event
                    .subscribe(onNext: { recognizer in
                        let categoryVC = CategoryListPageVC()
                        EnvContext.shared.rootNavController.pushViewController(categoryVC, animated: true)
                    })
                    .disposed(by: disposeBag)
        }

        springBoard.itemProvider = {
            springItems
        }
    }


    func createSpringBoardItemView(image: UIImage, label: String) -> HomeSpringBoardItemView {
        let itemView = HomeSpringBoardItemView()
        itemView.imageView.image = image
        itemView.label.text = label
        return itemView
    }

    func loadData() {
        springBoard?.loadData()
    }

}
