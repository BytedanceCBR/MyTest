//
// Created by leo on 2018/7/31.
//

import Foundation
import RxCocoa
import RxSwift
import Reachability

/// 楼盘动态
class TransactionHistoryVC: BaseSubPageViewController, PageableVC {

    var hasMore: Bool = true

    let neighborhoodId: String

    private var errorVM : NHErrorViewModel?

    var transactionHistoryVM: TransactionHistoryVM?

    init(neighborhoodId: String,
         isHiddenBottomBar: Bool = true,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        super.init(identifier: neighborhoodId, isHiddenBottomBar: true, bottomBarBinder: bottomBarBinder)
        self.transactionHistoryVM = TransactionHistoryVM(tableView: tableView)
        self.transactionHistoryVM?.onDataLoaded = self.onDataLoaded()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //隐藏关注按钮
        self.navBar.rightBtn2.isHidden = true
        navBar.title.text = "小区成交历史"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView.isHidden = false
            infoMaskView.label.text = "网络异常"
            infoMaskView.isUserInteractionEnabled = false
        } else {
            self.transactionHistoryVM?.request(neighborhoodId: neighborhoodId)
        }
        
//        infoMaskView.tapGesture.rx.event
//            .bind { [unowned self] (_) in
//                if EnvContext.shared.client.reachability.connection == .none {
//                    // 无网络时直接返回空，不请求
//                    EnvContext.shared.toast.showToast("网络异常")
//                    return
//                }
//                self.transactionHistoryVM?.request(neighborhoodId: self.neighborhoodId)
//            }
//            .disposed(by: disposeBag)
        self.errorVM = NHErrorViewModel(errorMask:infoMaskView,requestRetryText:"网络异常",requestNilDataImage:"group-4")
        
        transactionHistoryVM?.onError = { [weak self] (error) in
            self?.tableView.mj_footer.endRefreshing()
            self?.errorVM?.onRequestError(error: error)
        }
        
        transactionHistoryVM?.onSuccess = {
            [weak self] (isHaveData) in

            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }else
            {
                self?.errorVM?.onRequestNilData()
            }
        }
        
        self.transactionHistoryVM?.datas.bind(onNext: { [unowned self] (datas) in
            if datas.count > 0 {
                self.infoMaskView.isHidden = true
            }
            })
            .disposed(by: disposeBag)
            
        tracerParams = tracerParams <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams(HouseCategory.neighborhood_trade_list.rawValue, key: EventKeys.category_name)
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
    
    func loadMore() {
        self.errorVM?.onRequestRefreshData()

        let refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type")
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        transactionHistoryVM?.pageableLoader?()
    }
    
}
