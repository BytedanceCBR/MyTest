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
    
    var navVC: UINavigationController?
    
    var oneTimeToast: ((String?) -> Void)?

    init(
            tableView: UITableView,
            navVC: UINavigationController?) {
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = CategoryListDataSource(cellFactory: cellFactory)
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        cellFactory.register(tableView: tableView)
    }

    func requestData(houseId: Int64) {

    }

    func requestData(houseType: HouseType, query: String, condition: String?) {
        switch houseType {
        case .newHouse:
            requestNewHouseList(query: query, condition: condition)
        case .secondHandHouse:
            requestErshouHouseList(query: query, condition: condition)
        default:
            requestNeigborhoodList(query: query, condition: condition)
        }
    }


    func followThisItem() {
        // do nothing
    }

    func requestNewHouseList(query: String, condition: String?) {
        let loader = pageRequestCourtSearch(query: query, suggestionParams: condition ?? "")
        oneTimeToast = createOneTimeToast()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        self.oneTimeToast?(response?.data?.refreshTip)
                        if let data = response?.data {
                            return paresNewHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
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

    func requestErshouHouseList(query: String, condition: String?) {
        let loader = pageRequestErshouHouseSearch(query: query, suggestionParams: condition ?? "")
        oneTimeToast = createOneTimeToast()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        self.oneTimeToast?(response?.data?.refreshTip)
                        if let data = response?.data {
                            return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
                        } else {
                            return []
                        }
                    }
                    .subscribe(
                            onNext: self.reloadData(),
                            onError: { error in
                                print(error)
                            })
                    .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func requestNeigborhoodList(query: String, condition: String?) {
        let loader = pageRequestNeighborhoodSearch(query: query, suggestionParams: condition ?? "")
        oneTimeToast = createOneTimeToast()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        self.oneTimeToast?(response?.data?.refreshTip)
                        if let data = response?.data {
                            return parseNeighborhoodRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
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
                            if self.dataSource.datas.value.count == 0 {
                                //TODO: f100
                            }
                            return parseFollowUpListRowItemNode(data, disposeBag: self.disposeBag, navVC: self.navVC)
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
            self.dataSource.datas.accept(self.dataSource.datas.value + datas)
            self.tableView?.reloadData()
            self.onDataLoaded?(self.dataSource.datas.value.count)
        }
    }

    func cleanData() {
        self.dataSource.datas.accept([])
    }
    
    func createOneTimeToast() -> (String?) -> Void {
        var hasToast = false
        return { (message) in
            if !hasToast, let message = message {
                EnvContext.shared.toast.showToast(message)
                hasToast = true
            }
        }
    }

}

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    let datas = BehaviorRelay<[TableRowNode]>(value: [])

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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canCancelFollowUp
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas.value[indexPath.row].selector?()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            EnvContext.shared.toast.showLoadingToast("正在取消关注")
            datas.value[indexPath.row]
                    .editor?(editingStyle)
                    .subscribe(onNext: { result in
                        EnvContext.shared.toast.dismissToast()
                        EnvContext.shared.toast.showToast("已取消关注")
                    }, onError: { error in
                        EnvContext.shared.toast.dismissToast()
                        switch error {
                            case let BizError.bizError(_, message):
                                EnvContext.shared.toast.showToast(message)
                            default:
                                EnvContext.shared.toast.showToast("请求失败")
                        }
                    })
                    .disposed(by: disposeBag)
        }
    }

}
