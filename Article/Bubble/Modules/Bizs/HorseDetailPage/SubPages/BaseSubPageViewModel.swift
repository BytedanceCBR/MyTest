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
class BaseSubPageViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
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
