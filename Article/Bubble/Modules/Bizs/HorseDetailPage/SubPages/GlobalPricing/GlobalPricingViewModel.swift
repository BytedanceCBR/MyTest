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

    var onDataLoaded: ((Bool, Int) -> Void)?

    private var cellFactory: UITableViewCellFactory

    private let disposeBag = DisposeBag()

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        datas
            .skip(1)
            .subscribe(onNext: { [unowned self] datas in
                self.tableView?.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func request(courtId: Int64) {
        
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.datas.accept([])
            return
        }
        EnvContext.shared.toast.showLoadingToast("正在加载")
        let loader = pageRequestNewHousePrice(houseId: courtId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    
                    if let list = response?.data?.list {
                        let datas = parseGlobalPricingNode(list)()
                        self.datas.accept(self.datas.value + datas)
                    }
                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    EnvContext.shared.toast.dismissToast()
                    },
                           onError: { [weak self] in
                            
                            self?.processError()
                            
                            }())
                .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }
    func processError() -> (Error?) -> Void {
        return { [weak self] error in
            self?.tableView?.mj_footer.endRefreshing()
            if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("加载失败")
            } else {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("网络异常")
            }
        }
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
        datas.value[indexPath.row].selector?(TracerParams.momoid())
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func cleanData() {
        self.datas.accept([])
    }
}
