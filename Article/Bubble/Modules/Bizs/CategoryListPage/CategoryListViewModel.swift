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

    var onDataLoaded: ((Bool, Int) -> Void)?

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
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.dataSource.datas.accept([])
            return
        }
        EnvContext.shared.toast.showLoadingToast("正在加载")
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
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    cleanDataOnce()
                    self.oneTimeToast?(response?.data?.refreshTip)
                    self.onDataLoaded?(response?.data?.hasMore ?? false, response?.data?.items?.count ?? 0)
                    
                    if let data = response?.data {
                        return paresNewHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
                    } else {
                        return []
                    }
                }
                .subscribe(
                    onNext: dataReloader,
                    onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        pageableLoader?()
    }

    func requestErshouHouseList(query: String, condition: String?) {
        let loader = pageRequestErshouHouseSearch(query: query, suggestionParams: condition ?? "")
        oneTimeToast = createOneTimeToast()
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        cleanDataOnce()
                        self.onDataLoaded?(response?.data?.hasMore ?? false, response?.data?.items?.count ?? 0)
                        self.oneTimeToast?(response?.data?.refreshTip)
                        if let data = response?.data {
                            return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
                        } else {
                            return []
                        }
                    }
                    .subscribe(
                            onNext: dataReloader,
                            onError: self.processError())
                    .disposed(by: self.disposeBag)
        }
        pageableLoader?()
    }

    func requestNeigborhoodList(query: String, condition: String?) {
        let loader = pageRequestNeighborhoodSearch(query: query, suggestionParams: condition ?? "")
        oneTimeToast = createOneTimeToast()
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    cleanDataOnce()
                    self.onDataLoaded?(response?.data?.hasMore ?? false, response?.data?.items?.count ?? 0)
                    self.oneTimeToast?(response?.data?.refreshTip)
                    if let data = response?.data {
                        return parseNeighborhoodRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: dataReloader,
                           onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        pageableLoader?()
    }


    func requestFavoriteData(houseType: HouseType) {

        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.dataSource.datas.accept([])
            return
        }
        dataSource.canCancelFollowUp = true
        let loader = pageRequestFollowUpList(houseType: houseType)
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        cleanDataOnce()
                        if let data = response?.data {
                            self.onDataLoaded?(data.hasMore ?? false, data.items.count)

                            if self.dataSource.datas.value.count == 0 {
                                //TODO: f100
                            }
                            return parseFollowUpListRowItemNode(data, disposeBag: self.disposeBag, navVC: self.navVC)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: dataReloader,
                               onError: self.processError())
                    .disposed(by: self.disposeBag)
        }
        pageableLoader?()
    }

    func reloadData() -> ([TableRowNode]) -> Void {
        var scrollToTop = false
        return { [unowned self] datas in
//            EnvContext.shared.toast.dismissToast()
            self.dataSource.datas.accept(self.dataSource.datas.value + datas)
            self.tableView?.reloadData()
            if !scrollToTop {
                if datas.count > 0 {
                    self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                scrollToTop = true
            }
        }
    }

    func cleanData() {
        self.dataSource.datas.accept([])
        if let tableView = self.tableView {
            tableView.reloadData()
        }
    }
    
    func once(apply: @escaping () -> Void) -> () -> Void {
        var executed = false
        return {
            if !executed {
                apply()
                executed = true
            }
        }
    }
    
    func createOneTimeToast() -> (String?) -> Void {
        var hasToast = false
        return { (message) in
            EnvContext.shared.toast.dismissToast()
            if !hasToast, let message = message {
                EnvContext.shared.toast.showToast(message)
                hasToast = true
            }
        }
    }
    
    func processError() -> (Error?) -> Void {
        return { [unowned self] _ in
            if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("加载失败")
            } else {
                self.dataSource.datas.accept([])
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
                    .subscribe(onNext: { [unowned self] result in
                        tableView.beginUpdates()
                        var theDatas = self.datas.value
                        theDatas.remove(at: indexPath.row)
                        self.datas.accept(theDatas)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
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

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
