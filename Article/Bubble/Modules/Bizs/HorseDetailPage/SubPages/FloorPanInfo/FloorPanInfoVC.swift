//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

class FloorPanInfoVC: BaseSubPageViewController {

    let floorPanId: String

    let newHouseData: NewHouseData

    var floorPanInfoViewModel: FloorPanInfoViewModel?

    init(isHiddenBottomBar: Bool, floorPanId: String, newHouseData: NewHouseData) {
        self.floorPanId = floorPanId
        self.newHouseData = newHouseData
        super.init(identifier: floorPanId, isHiddenBottomBar: isHiddenBottomBar)
        self.navBar.title.text = "楼盘信息"
        self.floorPanInfoViewModel = FloorPanInfoViewModel(tableView: tableView, newHouseData: newHouseData)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.floorPanInfoViewModel?.request(
                floorPanId: floorPanId,
                newHouseData: newHouseData)
    }
}
