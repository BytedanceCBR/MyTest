//
//  FloorPanCategoryDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class FloorPanCategoryDetailPageVC: BaseSubPageViewController {

    private let floorPanId: Int64
    
    private var viewModel: FloorPanCategoryDetailPageViewModel?

    private var followPage: BehaviorRelay<String> = BehaviorRelay(value: "house_model_detail")

    init(isHiddenBottomBar: Bool,
         floorPanId: Int64,
         followPage: BehaviorRelay<String>,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.floorPanId = floorPanId
        self.followPage = followPage

        super.init(identifier: "\(floorPanId)",
            isHiddenBottomBar: false,
                bottomBarBinder: bottomBarBinder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = FloorPanCategoryDetailPageViewModel(
                tableView: tableView,
                navVC: self.navigationController,
                followPage: self.followPage)
        self.viewModel?.bottomBarBinder = bottomBarBinder
        self.viewModel?.floorPanId = self.floorPanId

        viewModel?.request(floorPanId: floorPanId)
        self.viewModel?.request(floorPanId: floorPanId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


func openFloorPanCategoryDetailPage(
        floorPanId: Int64,
        disposeBag: DisposeBag,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> Void {
    return {
        let detailPage = FloorPanCategoryDetailPageVC(
                isHiddenBottomBar: false,
                floorPanId: floorPanId,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder)

        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}
