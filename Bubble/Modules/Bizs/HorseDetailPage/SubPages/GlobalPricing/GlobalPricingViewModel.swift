//
//  GlobalPricingViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GlobalPricingViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var tableView: UITableView?

    let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool) -> Void)?

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

    func request(courtId: Int64) {
        let loader = pageRequestNewHousePrice(houseId: courtId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    if let hasMore = response?.data?.hasMore {
                        self.onDataLoaded?(hasMore)
                    }
                    if let data = response?.data {
                        return parseGlobalPricingNode(data.list ?? [])()
                    } else {
                        return []
                    }
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
