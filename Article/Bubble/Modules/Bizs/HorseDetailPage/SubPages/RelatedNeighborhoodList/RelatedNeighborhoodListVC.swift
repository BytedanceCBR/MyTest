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

    init(neighborhoodId: String, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        super.init(
            identifier: neighborhoodId,
            isHiddenBottomBar: true,
                bottomBarBinder: bottomBarBinder)
        self.navBar.title.text = "周边小区"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.relatedNeighborhoodListViewModel = RelatedNeighborhoodListViewModel(tableView: tableView, navVC: self.navigationController)

        self.relatedNeighborhoodListViewModel?.datas
            .skip(1)
            .debug()
            .map { $0.count > 0 }
            .bind(to: infoMaskView.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.relatedNeighborhoodListViewModel?.onDataLoaded = self.onDataLoaded()
        self.relatedNeighborhoodListViewModel?.request(neighborhoodId: neighborhoodId)
        // 进入列表页埋点
        stayTimeParams = tracerParams <|> traceStayTime()
        recordEvent(key: TraceEventName.enter_category, params: tracerParams)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        relatedNeighborhoodListViewModel?.pageableLoader?()
    }
}
