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
    var goDetailTraceParam: TracerParams?
    
    
    var houseType: HouseType = .newHouse
    var houseId: Int64 = -1
    
    //TODO: 将已有的showalert回调调整成与详情页一致
    var showMessageAlert: ((String) -> Void)?

    var dismissMessageAlert: (() -> Void)?

    var searchId: String?
    
    var groupId: String {
        get {
            return "be_null"
        }
    }

    var showLoading: ((String) -> Void)?

    var dismissLoading: (() -> Void)?

    var shareInfo: ShareInfo?

    var onNetworkError: ((Error) -> Void)?
    
    var onDataArrived: (() -> Void)?

    var onEmptyData: (() -> Void)?

    var logPB: Any?
    
    var favoriteHasMore: Bool = false

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "be_null")
    
    var traceParams = TracerParams.momoid()

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    let disposeBag = DisposeBag()

    var requestDisposeBag = DisposeBag()

    weak var tableView: UITableView?

    var dataSource: CategoryListDataSource

    private var cellFactory: UITableViewCellFactory

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool, Int) -> Void)?

    var contactPhone: BehaviorRelay<FHHouseDetailContact?> = BehaviorRelay<FHHouseDetailContact?>(value: nil)
    
    var navVC: UINavigationController?
    
    var oneTimeToast: ((String?) -> Void)?
    
    var onError: ((Error?) -> Void)?
    
    var onSuccess: ((Bool) -> Void)?

    var originSearchId: String?

    var houseSearchRecorder: ((String?) -> Void)?

    var houseSearch: [String: Any]?
    
    var currentHouseType: HouseType?

    var showTips:((String) -> Void)?

    // houseSearch补充埋点
    var limit = 20
    var offset = 0
    var time = 0 //点击搜索内容时间戳，等同于进入列表页的时机

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
        time = Int(Date().timeIntervalSince1970)
        
        //取消关注，删除到小于6个去自动请求
        dataSource.datasDeleteBehavior.skip(1).subscribe { [unowned self] (count) in
            if let countRetain = count.element , countRetain < 9
            {
                if let houseType = self.currentHouseType , self.favoriteHasMore
                {
                    self.requestFavoriteData(houseType: houseType)
                }else if countRetain == 0 //如果没有相关房源
                {
                    self.onSuccess?(false)
                }
            }
        }.disposed(by: disposeBag)
        
        showDefaultLoadTable()
    }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool) {
        
    }

    func getShareItem() -> ShareItem {
        return ShareItem(title: "", desc: "", webPageUrl: "", thumbImage: #imageLiteral(resourceName: "icon-bus"), shareType: TTShareType.webPage, groupId: "")
    }

    func requestData(
        houseType: HouseType,
        query: String,
        condition: String?,
        needEncode: Bool = true) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            return
        }
//        self.showLoading?("正在加载")
        switch houseType {
        case .newHouse:
            requestNewHouseList(query: query, condition: condition, needEncode: needEncode)
        case .secondHandHouse:
            requestErshouHouseList(query: query, condition: condition, needEncode: needEncode)
        default:
            requestNeigborhoodList(query: query, condition: condition, needEncode: needEncode)
        }
    }


    func followThisItem(isNeedRecord: Bool, traceParam: TracerParams) {
        // do nothing
    }

    func requestNewHouseList(
        query: String,
        condition: String?,
        needEncode: Bool = true) {
        self.requestDisposeBag = DisposeBag()

        let loader = pageRequestCourtSearch(query: query, suggestionParams: condition ?? "", needEncode: needEncode)
        oneTimeToast = createOneTimeToast()
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
//                .debug("requestNewHouseList")
                .map { [unowned self] response -> (Bool, [TableRowNode]) in
                    cleanDataOnce()
                    self.oneTimeToast?(response?.data?.refreshTip)
                    self.houseSearchRecorder?(response?.data?.searchId)
                    if let data = response?.data {

                        self.originSearchId = data.searchId
                        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                        
                        let theDatas = data.items?.map({ (item) -> CourtItemInnerEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })
                        
                        let params = TracerParams.momoid() <|>
                            toTracerParams("new_list", key: "enter_from") <|>
                            toTracerParams("be_null", key: "element_from")

                        var houseSearch: TracerParams? = nil
                        if let hs = self.houseSearch {
                            var hs = hs
                            hs["time"] = self.time
                            hs["offset"] = self.offset
                            hs["limit"] = self.limit
                            houseSearch = paramsOfMap(hs)
                        }
                        self.offset = self.offset + (data.items?.count ?? 0)

                        return (response?.data?.hasMore ?? false, paresNewHouseListRowItemNode(
                            theDatas,
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            houseSearchParams: houseSearch,
                            navVC: self.navVC))
                    } else {
                        return (response?.data?.hasMore ?? false, [])
                    }
                }
                .subscribe(
                    onNext: dataReloader,
                    onError: self.processError())
                .disposed(by: self.requestDisposeBag)
        }
        pageableLoader?()
    }
    
    func showDefaultLoadTable()
    {
        self.dataSource.datas.accept(parseHousePlaceholderRowNode(nodeCount: 10)())
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    func requestErshouHouseList(
        query: String,
        condition: String?,
        needEncode: Bool = true) {
        self.requestDisposeBag = DisposeBag()

        let loader = pageRequestErshouHouseSearch(query: query, suggestionParams: condition ?? "", needEncode: needEncode)
        oneTimeToast = createOneTimeToast()
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        var hasRecordSearch = false
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> (Bool, [TableRowNode]) in
                        cleanDataOnce()
                        self.oneTimeToast?(response?.data?.refreshTip)
                    if hasRecordSearch == false {
                        self.houseSearchRecorder?(response?.data?.searchId)
                        hasRecordSearch = true
                    }

                        if let data = response?.data {

                            self.originSearchId = data.searchId

                            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                                toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                            
                            let theDatas = data.items?.map({ (item) -> HouseItemInnerEntity in
                                var newItem = item
                                newItem.fhSearchId = data.searchId
                                return newItem
                            })

                            var houseSearch: TracerParams? = nil
                            if let hs = self.houseSearch {
                                var hs = hs
                                hs["time"] = self.time
                                hs["offset"] = self.offset
                                hs["limit"] = self.limit
                                houseSearch = paramsOfMap(hs)
                            }
                            
                            let params = TracerParams.momoid() <|>
                                toTracerParams("old_list", key: "enter_from") <|>
                                toTracerParams("be_null", key: "element_from") <|>
                                toTracerParams("old_list", key: "page_type") <|>
                                beNull(key: "element_type")
                            self.offset = self.offset + (data.items?.count ?? 0)
                            return (response?.data?.hasMore ?? false,
                                    parseErshouHouseListRowItemNode(
                                theDatas,
                                traceParams: params,
                                disposeBag: self.disposeBag,
                                houseSearchParams: houseSearch,
                                navVC: self.navVC))
                        } else {
                            return (response?.data?.hasMore ?? false, [])
                        }
                    }
                    .subscribe(
                            onNext: dataReloader,
                            onError: self.processError())
                    .disposed(by: self.requestDisposeBag)
        }
        pageableLoader?()
    }

    func requestNeigborhoodList(
        query: String,
        condition: String?,
        needEncode: Bool = true) {
        self.requestDisposeBag = DisposeBag()

        let loader = pageRequestNeighborhoodSearch(
            query: query,
            suggestionParams: condition ?? "",
            needEncode: needEncode)

        oneTimeToast = createOneTimeToast()
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> (Bool, [TableRowNode]) in
                    cleanDataOnce()
                    self.oneTimeToast?(response?.data?.refreshTip)
                    if let data = response?.data {
                        self.houseSearchRecorder?(response?.data?.searchId)

                        self.originSearchId = data.searchId

                        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                        
                        let theDatas = data.items?.map({ (item) -> NeighborhoodInnerItemEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })

                        var houseSearch: TracerParams? = nil
                        if let hs = self.houseSearch {
                            var hs = hs
                            hs["time"] = self.time
                            hs["offset"] = self.offset
                            hs["limit"] = self.limit
                            houseSearch = paramsOfMap(hs)
                        }
                        
                        let params = TracerParams.momoid() <|>
                            toTracerParams("neighborhood_list", key: "enter_from") <|>
                            toTracerParams("neighborhood_list", key: "page_type") <|>
                            toTracerParams("be_null", key: "element_from") <|>
                            beNull(key: "element_type")
                        self.offset = self.offset + (data.items?.count ?? 0)

                        return (response?.data?.hasMore ?? false, parseNeighborhoodRowItemNode(
                            theDatas,
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            houseSearchParams: houseSearch,
                            navVC: self.navVC))
                    } else {
                        return (response?.data?.hasMore ?? false, [])
                    }
                }
                .subscribe(onNext: dataReloader,
                           onError: self.processError())
                .disposed(by: self.requestDisposeBag)
        }
        pageableLoader?()
    }


    func requestFavoriteData(houseType: HouseType) {

        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.dataSource.datas.accept([])
            return
        }
        EnvContext.shared.toast.showLoadingToast("正在加载")
        dataSource.canCancelFollowUp = true
        currentHouseType = houseType
        let loader = pageRequestFollowUpList(houseType: houseType)
        let cleanDataOnce = once(apply: { [weak self] in
            self?.cleanData()
        })
        let dataReloader = reloadData()
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> (Bool, [TableRowNode]) in
                        cleanDataOnce()
                        if let data = response?.data {

                            self.originSearchId = data.searchId

                            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                                toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                            self.favoriteHasMore = data.hasMore ?? false
                            return (data.hasMore ?? false, parseFollowUpListRowItemNode(data, hasMore: data.hasMore ?? false, disposeBag: self.disposeBag, navVC: self.navVC))
                        } else {
                            return (false, [])
                        }
                    }
                    .subscribe(onNext: dataReloader,
                               onError: self.processError())
                    .disposed(by: self.disposeBag)
        }
        pageableLoader?()
    }

    func reloadData() -> (Bool, [TableRowNode]) -> Void {
        var scrollToTop = false
        return { [unowned self] (hasMore, datas) in
            self.dataSource.datas.accept(self.dataSource.datas.value + datas)
            self.offset = self.dataSource.datas.value.count
            self.tableView?.reloadData()
            if !scrollToTop {
                if datas.count > 0 {
                    self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                self.onSuccess?(datas.count > 0)
                scrollToTop = true
            }
            
            self.onDataLoaded?(hasMore, self.dataSource.datas.value.count)

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
        return { [weak self] (message) in
//            EnvContext.shared.toast.dismissToast()
            self?.dismissLoading?()
            if !hasToast, let message = message {
//                EnvContext.shared.toast.showToast(message)
                self?.showTips?(message)
                hasToast = true
            }
        }
    }
    
    func processError() -> (Error?) -> Void {
        return { [weak self] error in
             if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                self?.dismissLoading?()
                EnvContext.shared.toast.showToast("加载失败")
            }
            self?.onError?(error)
        }
    }

}

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate , TableViewTracer {

    var datas = BehaviorRelay<[TableRowNode]>(value: [])

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?

    var canCancelFollowUp: Bool = false

    let disposeBag = DisposeBag()

    var showHud: ((String, Int) -> Void)?
    
    let datasDeleteBehavior = BehaviorRelay<Int>(value: 0)
    
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
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canCancelFollowUp
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let params = TracerParams.momoid() <|>
            toTracerParams(indexPath.row, key: "rank")
        datas.value[indexPath.row].selector?(params)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < datas.value.count {
            let params = EnvContext.shared.homePageParams <|>
                toTracerParams(indexPath.row, key: "rank")
            callTracer(tracer: datas.value[indexPath.row].tracer, traceParams: params)
        }
        
        if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消关注"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == datas.value.count - 1 {
            return 125
        }
        return 105
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            EnvContext.shared.toast.showLoadingToast("正在取消关注")
            datas.value[indexPath.row]
                    .editor?(editingStyle)
                    .subscribe(onNext: { [unowned self] result in
                        var theDatas = self.datas.value
//                        if (theDatas.count > 0) {
//                            let offset = tableView.contentOffset // TODO: 会出现超过一页时，底部大部分留白的问题，后续需优化
//                            tableView.beginUpdates()
//                            theDatas.remove(at: indexPath.row)
//                            self.datas.accept(theDatas)
//                            tableView.deleteRows(at: [indexPath], with: .none)
//                            tableView.endUpdates()
//                            tableView.setNeedsLayout()
//                            tableView.layoutIfNeeded()
//                            tableView.contentOffset = offset
//                            UIView.setAnimationsEnabled(true)
//
//                        } else {

                        theDatas.remove(at: indexPath.row)
                        self.datas.accept(theDatas)
                        UIView.performWithoutAnimation {
                            tableView.reloadData()
                        }
                        
                        if self.canCancelFollowUp
                        {
                            self.datasDeleteBehavior.accept(theDatas.count)
                        }
                        
                        
//                        }
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

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        return nil
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "取消关注", handler: {[unowned self] (action, view, handler) in

            handler(true)

            EnvContext.shared.toast.showLoadingToast("正在取消关注")
            self.datas.value[indexPath.row]
                .editor?(.delete)
                .subscribe(onNext: { [unowned self] result in

                    var theDatas = self.datas.value
//                    if (theDatas.count > 0) {
//                        let offset = tableView.contentOffset
//                        UIView.setAnimationsEnabled(false)
//                        tableView.beginUpdates()
//                        theDatas.remove(at: indexPath.row)
//                        self.datas.accept(theDatas)
//                        tableView.deleteRows(at: [indexPath], with: .none)
//                        tableView.endUpdates()
//                        tableView.setNeedsLayout()
//                        tableView.layoutIfNeeded()
//                        tableView.contentOffset = offset
//                        UIView.setAnimationsEnabled(true)
//
//                    } else {

                    theDatas.remove(at: indexPath.row)
                    self.datas.accept(theDatas)
                    
                    UIView.performWithoutAnimation {
                        tableView.reloadData()
                    }
                    
                    if self.canCancelFollowUp
                    {
                        self.datasDeleteBehavior.accept(theDatas.count)
                    }
                    
                    
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
                .disposed(by: self.disposeBag)
        })
        action.backgroundColor = UIColor(red: 236/255.0, green: 77/255.0, blue: 61/255.0, alpha: 1)
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }


}
