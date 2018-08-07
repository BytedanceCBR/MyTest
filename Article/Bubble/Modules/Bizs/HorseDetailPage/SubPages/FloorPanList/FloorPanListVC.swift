//
//  FloorPanListVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class FloorPanListVC: BaseSubPageViewController, PageableVC {
    
    var hasMore = true

    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let courtId: Int64

    var floorPanListViewModel: FloorPanListViewModel?

    init(courtId: Int64, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.courtId = courtId
        super.init(identifier: "\(courtId)", bottomBarBinder: bottomBarBinder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "楼盘动态"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        floorPanListViewModel = FloorPanListViewModel(tableView: tableView)
        floorPanListViewModel?.request(courtId: courtId)
        floorPanListViewModel?.onDataLoaded = self.onDataLoaded()
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
    }

    func loadMore() {
        floorPanListViewModel?.pageableLoader?()
    }

}
