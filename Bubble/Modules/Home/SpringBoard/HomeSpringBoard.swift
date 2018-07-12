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

    typealias SpringBoardItemClick = () -> Void

    weak var springBoard: HomeSpringBoard?

    let disposeBag = DisposeBag()

    init(springBoard: HomeSpringBoard) {
        self.springBoard = springBoard
        let springItems: [HomeSpringBoardItemView] = [
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-ershoufang"), label: "二手房"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-xinfang"), label: "新房"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-xiaoqu"), label: "找小区"),
            createSpringBoardItemView(image: #imageLiteral(resourceName: "icon-zixun-1"), label: "咨询")
        ]

        let clicks: [SpringBoardItemClick] = [
            openCategoryVC(.secondHandHouse),
            openCategoryVC(.newHouse),
            openCategoryVC(.neighborhood),
            {}
        ]

        zip(springItems, clicks).forEach { (e) in
            let (view, click) = e
            view.clickGesture.rx.event
                    .subscribe(onNext: { recognizer in
                        click()
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

    private func openCategoryVC(_ houseType: HouseType) -> () -> Void {
        return { [unowned self] in
            let vc = CategoryListPageVC(isOpenConditionFilter: true)
            vc.houseType.accept(houseType)
            vc.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator.monoid()
            vc.navBar.isShowTypeSelector = false
            let nav = EnvContext.shared.rootNavController
            nav.pushViewController(vc, animated: true)
            vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: self.disposeBag)
        }
    }

}
