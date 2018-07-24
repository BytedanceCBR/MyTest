//
//  CategoryListViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CategoryListViewModel: DetailPageViewModel {

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    let disposeBag = DisposeBag()

    weak var tableView: UITableView?

    var dataSource: CategoryListDataSource

    private var cellFactory: UITableViewCellFactory

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Int) -> Void)?

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = CategoryListDataSource(cellFactory: cellFactory)
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        cellFactory.register(tableView: tableView)
    }

    func requestData(houseId: Int64) {

    }

    func requestData(houseType: HouseType, query: String) {
        switch houseType {
        case .newHouse:
            requestNewHouseList(query: query)
        case .secondHandHouse:
            requestErshouHouseList(query: query)
        default:
            requestNeigborhoodList(query: query)
        }
    }


    func followThisItem() {
        // do nothing
    }

    func requestNewHouseList(query: String) {
        let loader = pageRequestCourtSearch(query: query)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return paresNewHouseListRowItemNode(data.items, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func requestErshouHouseList(query: String) {
        let loader = pageRequestErshouHouseSearch(query: query)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func requestNeigborhoodList(query: String) {
        let loader = pageRequestNeighborhoodSearch(query: query)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseNeighborhoodRowItemNode(data.items, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }


    func requestFavoriteData(houseType: HouseType) {
        dataSource.canCancelFollowUp = true
        let loader = pageRequestFollowUpList(houseType: houseType)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseFollowUpListRowItemNode(data, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func reloadData() -> ([TableRowNode]) -> Void {
        return { [unowned self] datas in
            self.dataSource.datas = self.dataSource.datas + datas
            self.tableView?.reloadData()
            self.onDataLoaded?(datas.count)
        }
    }

    func cleanData() {
        self.dataSource.datas = []
    }

}

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var datas: [TableRowNode] = []

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?

    var canCancelFollowUp: Bool = false

    let disposeBag = DisposeBag()

    var showHud: ((String, Int) -> Void)?

    init(cellFactory: UITableViewCellFactory) {
        self.cellFactory = cellFactory
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas[indexPath.row].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas[indexPath.row].itemRender(cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canCancelFollowUp
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            EnvContext.shared.toast.showLoadingToast("正在取消关注")
            datas[indexPath.row]
                    .editor?(editingStyle)
                    .debug()
                    .subscribe(onNext: { result in
                        EnvContext.shared.toast.dismissToast()
                        EnvContext.shared.toast.showToast("已取消关注")
                    }, onError: { error in
                        EnvContext.shared.toast.dismissToast()
                        switch error {
                            case let BizError.bizError(status, message):
                                EnvContext.shared.toast.showToast(message)
                            default:
                                EnvContext.shared.toast.showToast("请求失败")
                        }
                    })
                    .disposed(by: disposeBag)
        }
    }

}
