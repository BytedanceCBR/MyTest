//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class HouseCommentVC: BaseSubPageViewController, PageableVC {
    
    var hasMore = true

    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let courtId: Int64

    var houseCommentViewModel: HouseCommentViewModel?


    init(courtId: Int64, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.courtId = courtId
        super.init(identifier: "\(courtId)", bottomBarBinder: bottomBarBinder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "全网点评"
        houseCommentViewModel = HouseCommentViewModel(tableView: tableView)

        houseCommentViewModel?.request(courtId: courtId)
        houseCommentViewModel?.onDataLoaded = self.onDataLoaded()
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)

    }

    func loadMore() {
        houseCommentViewModel?.pageableLoader?()
    }
}
