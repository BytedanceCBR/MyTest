//
// Created by leo on 2018/7/31.
//

import Foundation
import RxCocoa
import RxSwift
import Reachability

class TransactionHistoryVC: BaseSubPageViewController, PageableVC {

    var hasMore: Bool = true

    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let neighborhoodId: String

    var transactionHistoryVM: TransactionHistoryVM?

    init(neighborhoodId: String, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        super.init(identifier: neighborhoodId, bottomBarBinder: bottomBarBinder)
        self.transactionHistoryVM = TransactionHistoryVM(tableView: tableView)
        self.transactionHistoryVM?.onDataLoaded = self.onDataLoaded()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "小区成交历史"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView.isHidden = false
            infoMaskView.label.text = "网络异常"
        } else {
            self.transactionHistoryVM?.request(neighborhoodId: neighborhoodId)
        }
        infoMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                self.transactionHistoryVM?.request(neighborhoodId: self.neighborhoodId)
            }
            .disposed(by: disposeBag)

        self.transactionHistoryVM?.datas.bind(onNext: { [unowned self] (datas) in
            if datas.count > 0 {
                self.infoMaskView.isHidden = true
            }
            })
            .disposed(by: disposeBag)

        tracerParams = tracerParams <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams("pre_load_more", key: "refresh_type") <|>
            toTracerParams(HouseCategory.neighborhood_trade_list.rawValue, key: EventKeys.category_name)
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
    
    func loadMore() {
        transactionHistoryVM?.pageableLoader?()
    }
    
}
