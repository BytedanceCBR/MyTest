//
//  GlobalPricingVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
class GlobalPricingVC: BaseSubPageViewController, PageableVC {

    var hasMore = true
    
    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let courtId: Int64

    var globalPricingViewModel: GlobalPricingViewModel?

    init(courtId: Int64) {
        self.courtId = courtId
        super.init(identifier: "\(courtId)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "全网比价"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        globalPricingViewModel = GlobalPricingViewModel(tableView: tableView)
        globalPricingViewModel?.request(courtId: courtId)
        globalPricingViewModel?.onDataLoaded = self.onDataLoaded()
    }

    func loadMore() {
        globalPricingViewModel?.pageableLoader?()
    }

}
