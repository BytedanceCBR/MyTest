//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class RelatedNeighborhoodListVC: BaseSubPageViewController, PageableVC  {
    
    var hasMore = true

    var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    var relatedNeighborhoodListViewModel: RelatedNeighborhoodListViewModel?

    let neighborhoodId: String

    init(neighborhoodId: String, followStatus: BehaviorRelay<Result<Bool>>) {
        self.neighborhoodId = neighborhoodId
        super.init(
            identifier: neighborhoodId,
            isHiddenBottomBar: true,
            followStatus: followStatus)
        self.navBar.title.text = "周边小区"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.relatedNeighborhoodListViewModel = RelatedNeighborhoodListViewModel(tableView: tableView, navVC: self.navigationController)
        self.relatedNeighborhoodListViewModel?.onDataLoaded = self.onDataLoaded()
        self.relatedNeighborhoodListViewModel?.request(neighborhoodId: neighborhoodId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        relatedNeighborhoodListViewModel?.pageableLoader?()
    }
}
