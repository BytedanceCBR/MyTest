//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class RelatedNeighborhoodListVC: BaseSubPageViewController, PageableVC  {
    
    var hasMore = true

    var relatedNeighborhoodListViewModel: RelatedNeighborhoodListViewModel?

    let neighborhoodId: String
    
    private var errorVM : NHErrorViewModel?

    var searchId: String?

    init(
        neighborhoodId: String,
        searchId: String? = nil,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        self.searchId = searchId
        super.init(
            identifier: neighborhoodId,
            isHiddenBottomBar: true,
                bottomBarBinder: bottomBarBinder)
        self.navBar.title.text = "周边小区"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomBar.snp.updateConstraints { (maker) in
            
            maker.height.equalTo(0)
        }
        //隐藏关注按钮
        self.navBar.rightBtn2.isHidden = true

        self.relatedNeighborhoodListViewModel = RelatedNeighborhoodListViewModel(tableView: tableView, navVC: self.navigationController)
        // 适配ios8上滑动滚动跳跃
        if #available(iOS 11.0, *) {
            self.tableView.estimatedRowHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
            self.tableView.estimatedSectionFooterHeight = 0
        }
        self.relatedNeighborhoodListViewModel?.datas
            .skip(1)
            .map { $0.count > 0 }
            .bind(to: infoMaskView.rx.isHidden)
            .disposed(by: disposeBag)
        self.relatedNeighborhoodListViewModel?.searchId = searchId
        self.relatedNeighborhoodListViewModel?.onDataLoaded = self.onDataLoaded()

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)

        if EnvContext.shared.client.reachability.connection != .none {
            self.errorVM?.onRequest()
            self.relatedNeighborhoodListViewModel?.request(neighborhoodId: neighborhoodId)
        } else {
            infoMaskView.isHidden = false
        }

        self.errorVM = NHErrorViewModel(errorMask:infoMaskView,requestRetryText:"网络异常",requestRetryImage:"group-4",retryAction:{
            [weak self] in
            if let neighborhoodId = self?.neighborhoodId{
                if self?.relatedNeighborhoodListViewModel?.datas.value.count == 0 {
                    self?.errorVM?.onRequest()
                    self?.relatedNeighborhoodListViewModel?.request(neighborhoodId: neighborhoodId)
                }
            }
        })

        self.relatedNeighborhoodListViewModel?.onError = { [weak self] (error) in
            self?.tableView.mj_footer.endRefreshing()
            self?.errorVM?.onRequestError(error: error)
        }
        
        self.relatedNeighborhoodListViewModel?.onSuccess = {
            [weak self] (isHaveData) in
            self?.tableView.mj_footer.endRefreshing()
            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }
        }
        
        // 进入列表页埋点
        tracerParams = tracerParams <|>
            toTracerParams(searchId ?? "be_null", key: "search_id")
        stayTimeParams = tracerParams.exclude("card_type") <|> traceStayTime()
        recordEvent(key: TraceEventName.enter_category, params: tracerParams.exclude("card_type"))
        
        self.errorVM?.onRequestViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
        EnvContext.shared.toast.dismissToast()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        self.errorVM?.onRequestRefreshData()
        let refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type")
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        errorVM?.onRequest()
        relatedNeighborhoodListViewModel?.pageableLoader?()
    }
}
