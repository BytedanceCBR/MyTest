//
// Created by leo on 2018/7/31.
//

import Foundation
import RxSwift
import RxCocoa
class TransactionHistoryVM: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var tableView: UITableView?

    let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool, Int) -> Void)?

    private var cellFactory: UITableViewCellFactory

    private let disposeBag = DisposeBag()

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.dataSource = self
        datas
                .skip(1)
                .subscribe(onNext: { [unowned self] datas in
                    self.tableView?.reloadData()
                })
                .disposed(by: disposeBag)

    }

    func request(neighborhoodId: String) {
        let loader = pageRequestNeighborhoodTotalSales(neighborhoodId: neighborhoodId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let hasMore = response?.data?.hasMore {
                            self.onDataLoaded?(hasMore, response?.data?.list?.count ?? 0)
                        }
                        return parseTransactionRecordNode(response)()
                    }
                    .subscribe(onNext: { [unowned self] (datas) in
                        self.datas.accept(self.datas.value + datas)
                    })
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas.value[indexPath.row].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas.value[indexPath.row].itemRender(cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas.value[indexPath.row].selector?()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func cleanData() {
        self.datas.accept([])
    }
}

