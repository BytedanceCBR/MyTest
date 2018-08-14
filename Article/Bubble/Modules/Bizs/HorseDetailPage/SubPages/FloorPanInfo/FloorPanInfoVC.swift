//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class FloorPanInfoVC: BaseSubPageViewController {

    let floorPanId: String

    let newHouseData: NewHouseData

    var floorPanInfoViewModel: FloorPanInfoViewModel?

    init(isHiddenBottomBar: Bool,
         floorPanId: String,
         newHouseData: NewHouseData,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.floorPanId = floorPanId
        self.newHouseData = newHouseData
        super.init(identifier: floorPanId,
                   isHiddenBottomBar: isHiddenBottomBar,
                bottomBarBinder: bottomBarBinder)
        self.navBar.title.text = "楼盘信息"
        self.floorPanInfoViewModel = FloorPanInfoViewModel(tableView: tableView, newHouseData: newHouseData)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView.isHidden = false
            infoMaskView.label.text = "网络异常"
        } else {
            self.floorPanInfoViewModel?.request(
                floorPanId: floorPanId,
                newHouseData: newHouseData)
        }

        infoMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                self.floorPanInfoViewModel?.request(
                    floorPanId: self.floorPanId,
                    newHouseData: self.newHouseData)
            }
            .disposed(by: disposeBag)

        self.floorPanInfoViewModel?.datas.bind(onNext: { [unowned self] (datas) in
            if datas.count > 0 {
                self.infoMaskView.isHidden = true
            }
        })
            .disposed(by: disposeBag)

    }
}
