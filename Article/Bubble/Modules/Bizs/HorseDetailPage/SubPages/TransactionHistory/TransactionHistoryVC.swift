//
// Created by leo on 2018/7/31.
//

import Foundation
import RxCocoa
import RxSwift
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
        self.transactionHistoryVM?.request(neighborhoodId: neighborhoodId)
    } 

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "小区成交历史"
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)

        tracerParams = tracerParams <|> toTracerParams(HouseCategory.neighborhood_trade_list.rawValue, key: EventKeys.category_name)
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
