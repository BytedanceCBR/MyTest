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

    init(neighborhoodId: String) {
        self.neighborhoodId = neighborhoodId
        super.init(identifier: neighborhoodId)
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
    }
    
    func loadMore() {
        transactionHistoryVM?.pageableLoader?()
    }
    
}
