//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class RelatedNeighborhoodListVC: BaseSubPageViewController, PageableVC  {
    var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    var relatedNeighborhoodListViewModel: RelatedNeighborhoodListViewModel?

    let neighborhoodId: String

    let disposeBag = DisposeBag()

    init(neighborhoodId: String) {
        self.neighborhoodId = neighborhoodId
        super.init(isHiddenBottomBar: true)
        self.navBar.title.text = "周边小区"
        self.relatedNeighborhoodListViewModel = RelatedNeighborhoodListViewModel(tableView: tableView)
        self.relatedNeighborhoodListViewModel?.onDataLoaded = self.onDataLoaded()
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        self.relatedNeighborhoodListViewModel?.request(neighborhoodId: neighborhoodId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        relatedNeighborhoodListViewModel?.pageableLoader?()
    }
}
