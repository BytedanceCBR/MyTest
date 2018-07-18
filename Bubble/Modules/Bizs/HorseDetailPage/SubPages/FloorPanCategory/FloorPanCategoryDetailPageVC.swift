//
//  FloorPanCategoryDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
class FloorPanCategoryDetailPageVC: BaseSubPageViewController {

    private let floorPanId: Int64

    private var viewModel: FloorPanCategoryDetailPageViewModel?

    init(isHiddenBottomBar: Bool, floorPanId: Int64) {
        self.floorPanId = floorPanId
        super.init(identifier: "\(floorPanId)", isHiddenBottomBar: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = FloorPanCategoryDetailPageViewModel(tableView: tableView)
        viewModel?.request(floorPanId: floorPanId)
        self.viewModel?.request(floorPanId: floorPanId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


func openFloorPanCategoryDetailPage(floorPanId: Int64, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = FloorPanCategoryDetailPageVC(
                isHiddenBottomBar: false,
                floorPanId: floorPanId)

        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}
