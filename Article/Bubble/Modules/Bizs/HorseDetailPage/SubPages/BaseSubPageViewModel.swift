//
//  BaseSubPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class BaseSubPageViewModel: NSObject, UITableViewDataSource, UITableViewDelegate{
    weak var tableView: UITableView?

    let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool, Int) -> Void)?

    var cellFactory: UITableViewCellFactory

    let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?

    init(tableView: UITableView, navVC: UINavigationController?) {
        self.navVC = navVC
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        datas
            .subscribe(onNext: { [unowned self] datas in
                self.tableView?.reloadData()
            })
            .disposed(by: disposeBag)
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



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let params = TracerParams.momoid()
            <|> toTracerParams(indexPath.row, key: "rank")
        datas.value[indexPath.row].selector?(params)
    }

//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == datas.value.count - 1 {
            return 125
        }
        return 105
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func cleanData() {
        self.datas.accept([])
    }

    func processError() -> (Error?) -> Void {
        return { [weak self] error in
            
            self?.tableView?.mj_footer.endRefreshing()
            if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("加载失败")
            }

        }
    }
}
