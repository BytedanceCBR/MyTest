//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift

class ErshouHouseListVC: BaseSubPageViewController, PageableVC {

    var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let neighborhoodId: String

    var ershouHouseListViewModel: ErshouHouseListViewModel?

    let disposeBag = DisposeBag()

    init(neighborhoodId: String) {
        self.neighborhoodId = neighborhoodId
        super.init(isHiddenBottomBar: true)
        self.navBar.title.text = "同小区房源"
        self.ershouHouseListViewModel = ErshouHouseListViewModel(tableView: tableView)
        ershouHouseListViewModel?.onDataLoaded = self.onDataLoaded()
        ershouHouseListViewModel?.request(neightborhoodId: neighborhoodId)

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        ershouHouseListViewModel?.pageableLoader?()
    }

    
}
