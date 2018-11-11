//
// Created by linlin on 2018/7/7.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NeighborhoodDetailPageViewModel: DetailPageViewModel, TableViewTracer {
    var goDetailTraceParam: TracerParams?
    
    
    var houseType: HouseType = .neighborhood
    var houseId: Int64 = -1
    

    var showMessageAlert: ((String) -> Void)?

    var dismissMessageAlert: (() -> Void)?

    var originalSearchId: String?

    var shareInfo: ShareInfo?

    var onDataArrived: (() -> Void)?

    var onNetworkError: ((Error) -> Void)?

    var onEmptyData: (() -> Void)?


    var logPB: Any?

    var searchId: String?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "neighborhood_detail")

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var neighborhoodDetailResponse = BehaviorRelay<NeighborhoodDetailResponse?>(value: nil)

    var groupId: String {
        get {
            return neighborhoodDetailResponse.value?.data?.id ?? "be_null"
        }
    }

    //相关小区
    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)
    //小区内相关
    private var houseInSameNeighborhood = BehaviorRelay<SameNeighborhoodHouseResponse?>(value: nil)

    var contactPhone: BehaviorRelay<FHHouseDetailContact?> = BehaviorRelay<FHHouseDetailContact?>(value: nil)
    
    weak var navVC: UINavigationController?

    var cellsDisposeBag: DisposeBag!

    weak var infoMaskView: EmptyMaskView?

    var traceParams = TracerParams.momoid()

    var recordRowIndex: Set<IndexPath> = []
    
    init(tableView: UITableView, infoMaskView: EmptyMaskView, navVC: UINavigationController?) {
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        self.infoMaskView = infoMaskView
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.register(MultitemCollectionNeighborhoodCell.self, forCellReuseIdentifier: "MultitemCollectionCell-neighborhood")
        cellFactory.register(tableView: tableView)

        Observable.combineLatest(neighborhoodDetailResponse, relateNeighborhoodData, houseInSameNeighborhood)
                .bind {  [unowned self] (_) in
                    let diss = DisposeBag()
                    self.cellsDisposeBag = diss
                    let result = self.processData(diss)([])
                    self.dataSource.datas = result
                    self.tableView?.reloadData()
                    DispatchQueue.main.async {
                        self.traceDisplayCell(tableView: self.tableView, datas: self.dataSource.datas)
                    }
                }
                .disposed(by: disposeBag)

        tableView.rx.didScroll
                .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
                .bind { [weak self, weak tableView] void in
                    self?.traceDisplayCell(tableView: tableView, datas: self?.dataSource.datas ?? [])
                }.disposed(by: disposeBag)
        
        self.bindFollowPage()
        
    }

    func traceDisplayCell(tableView: UITableView?, datas: [TableSectionNode]) {
        let params = EnvContext.shared.homePageParams <|>
                toTracerParams("\(self.houseId)", key: "group_id") <|>
                toTracerParams("neighborhood_detail", key: "page_type")

        tableView?.indexPathsForVisibleRows?.forEach({ [unowned self] (indexPath) in
            if !recordRowIndex.contains(indexPath) {
                self.callTracer(
                    tracer: datas[indexPath.section].tracer,
                    atIndexPath: indexPath,
                    traceParams: params.exclude("search").exclude("filter"))
                recordRowIndex.insert(indexPath)
            }
            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                theCell.hasShowOnScreen = true
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionNeighborhoodCell {
                theCell.hasShowOnScreen = true
            }
        })
    }

    func requestReletedData() {
        if let neighborhoodId = neighborhoodDetailResponse.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.relateNeighborhoodData.accept(response)
                    })
                    .disposed(by: disposeBag)
//            requestSearch(offset: 0, query: "neighborhood_id=\(neighborhoodId)&house_type=\(HouseType.secondHandHouse.rawValue)")
            requestHouseInSameNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.houseInSameNeighborhood.accept(response)
                    })
                    .disposed(by: disposeBag)

        }

    }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool) {
        self.houseId = houseId
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView?.isHidden = false
        } else {
            infoMaskView?.isHidden = true
        }
        if showLoading {
            self.showMessageAlert?("正在加载")
        }
//        "\(houseId)"
//        houseId =
        requestNeighborhoodDetail(neighborhoodId: "6581417114710573326", logPB: logPB)
                .subscribe(onNext: { [unowned self] (response) in
  
                    if let status = response?.data?.neighbordhoodStatus {
                        self.followStatus.accept(Result.success(status.neighborhoodSubStatus ?? 0 == 1))
                    }
                    self.contactPhone.accept(nil)

                    self.shareInfo = response?.data?.shareInfo
                    self.titleValue.accept(response?.data?.name)
                    self.neighborhoodDetailResponse.accept(response)
                    self.requestReletedData()
                    self.infoMaskView?.isHidden = true
                    self.onDataArrived?()
                    if showLoading {
                        self.dismissMessageAlert?()
                    }
                }, onError: { [unowned self] (error) in
                    EnvContext.shared.toast.showToast("网络异常")
                    self.onNetworkError?(error)
                })
                .disposed(by: disposeBag)
    }

    func followThisItem(isNeedRecord: Bool, traceParam: TracerParams) {
        switch followStatus.value {
        case let .success(status):
            if status {
                cancelFollowIt(
                    houseType: .neighborhood,
                    followAction: .neighborhood,
                    followId: "\(houseId)",
                    disposeBag: disposeBag)()

            } else {
                followIt(
                    houseType: .neighborhood,
                    followAction: .neighborhood,
                    followId: "\(houseId)",
                    disposeBag: disposeBag,
                    isNeedRecord: isNeedRecord)()
                self.recordFollowEvent(traceParam)


            }
        case .failure(_): do {}
        }
    }
    
    fileprivate func processData(_ theDisposeBag: DisposeBag) -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = neighborhoodDetailResponse.value?.data {

            
            let theParams = EnvContext.shared.homePageParams <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb") <|>
                beNull(key: "card_type") <|>
                toTracerParams("neighborhood_detail", key: "enter_from") <|>
                toTracerParams("click", key: "enter_type")
            
            let traceParamsDic = traceParams.paramsGetter([:])
            var traceExtension: TracerParams = TracerParams.momoid()
            if let code = traceParamsDic["rank"] as? Int {
                traceExtension = traceExtension <|>
                    toTracerParams(String(code), key: "rank")
            }
            
            if let logPb = traceParamsDic["log_pb"] {
                traceExtension = traceExtension <|>
                    toTracerParams(logPb, key: "log_pb")
            }
            
            /*
            if let code = traceParamsDic["search_id"] as? String {
                traceExtension = traceExtension <|>
                    toTracerParams(String(code), key: "search_id")
            }
            */

            self.logPB = data.logPB
            let searchId = relateNeighborhoodData.value?.data?.searchId
            let relatedItems = relateNeighborhoodData.value?.data?.items?.map({ (item) -> NeighborhoodInnerItemEntity in
                var newItem = item
                newItem.fhSearchId = searchId
                return newItem
            })
            
            var pictureParams = EnvContext.shared.homePageParams <|> toTracerParams("neighborhood_detail", key: "page_type")
            pictureParams = pictureParams <|>
                toTracerParams(self.houseId, key: "group_id") <|>
                toTracerParams(self.searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")
            print("xxxxxx= \(String(describing: data)) ")
            
            let dataParser = DetailDataParser.monoid()
                <- parseCycleImageNode(data.neighborhoodImage,traceParams: pictureParams, disposeBag: self.disposeBag)
                <- parseNeighborhoodNameNode(data, traceExtension: traceExtension, navVC: self.navVC, disposeBag: theDisposeBag)
                <- parseNeighborhoodStatsInfo(data, traceExtension: traceExtension, disposeBag: self.disposeBag) {[weak self] (info) in
                    if let openUrl = info.openUrl {
                        self?.openTransactionHistoryOrHouseListVCWithURL(url: openUrl, data: data)
                    }
                }
                <- parseHeaderNode("小区概况", adjustBottomSpace: 0) {
                    data.baseInfo?.count ?? 0 > 0
                }
                <- parseNeighborhoodPropertyListNode(data, traceExtension: traceExtension)
                <- parseHeaderNode("小区评测", subTitle: "查看更多", showLoadMore: true, adjustBottomSpace: -10, process: nil) {
                    return data.neighborhoodInfo != nil ? true : false
                }
                <- parseNeighborhoodEvaluationCollectionNode(
                    data,
                    traceExtension: traceExtension,
                    followStatus: self.followStatus,
                    navVC: self.navVC)
                <- parseFlineNode(6)
                <- parseHeaderNode("周边配套",adjustBottomSpace: 0){
                    data.neighborhoodInfo != nil
                }
                <- parseNeighorhoodNearByNode(data, traceExtension: traceExtension, houseId: "\(self.houseId)",navVC: self.navVC, disposeBag: self.disposeBag){
                    [weak self] in
                    
                    UIView.performWithoutAnimation { [weak self] in
                        if let visibleCells = self?.tableView?.indexPathsForVisibleRows
                        {
                            visibleCells.forEach({ [weak self] (indexPath) in
                                if let cell = self?.tableView?.cellForRow(at: indexPath),cell is NewHouseNearByCell
                                {
                                    self?.tableView?.reloadRows(at: [indexPath], with: .none)
                                }
                            })
                           
                        }
                    }
                }
                <- parseHeaderNode("均价走势")
                <- parseNeighboorhoodPriceChartNode(data, traceExtension: traceExtension, navVC: self.navVC) { 
                    if let id = data.neighborhoodInfo?.id
                    {
                        var rankValue: String =  "be_null"
                        var searchId: String =  "be_null"
                        if let code = traceParamsDic["rank"] as? Int {
                            rankValue = String(code)
                        }
                        
                        if let logPb = traceParamsDic["log_pb"] {
                            if let logPbV = logPb as? Dictionary<String, Any>,let searchIdV = logPbV["search_id"] as? String
                            {
                                searchId = searchIdV
                            }
                        }
                        
                        let loadMoreParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(id, key: "group_id") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb")  <|>
                            toTracerParams("neighborhood_detail", key: "page_type") <|>
                            toTracerParams(searchId, key: "search_id") <|>
                            toTracerParams(rankValue,key: "rank")
                        recordEvent(key: "click_price_trend", params: loadMoreParams)
                    }
                }
                <- parseFlineNode(6)
                <- parseHeaderNode("小区成交历史(\(data.totalSalesCount ?? 0))") {
                    data.totalSalesCount ?? 0 > 0
                }
                <- parseTransactionRecordNode(data.totalSales?.list, traceExtension: traceExtension)
                <- parseOpenAllNode(data.totalSales?.hasMore ?? false, "全部成交房源", barHeight: 0) { [unowned self] in
                    if let id = data.id {

                        let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("neighborhood_trade", key: "element_type") <|>
                                toTracerParams(id, key: "group_id") <|>
                                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams("neighborhood_detail", key: "page_type")
                        recordEvent(key: "click_loadmore", params: loadMoreParams)

                        let transactionTrace = theParams <|>
                            toTracerParams("neighborhood_trade_list", key: "category_name") <|>
                            toTracerParams("neighborhood_trade", key: "element_from") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb")

                        self.openTransactionHistoryPage(
                            neighborhoodId: id,
                            traceParams: transactionTrace,
                            bottomBarBinder: self.bindBottomView(params: TracerParams.momoid()))
                    }
                }
                <- parseFlineNode(((data.totalSales?.hasMore ?? false) == false && data.totalSales?.list?.count ?? 0 > 0) ? 6 : 0)
                <- parseHeaderNode("小区房源(\(houseInSameNeighborhood.value?.data?.total ?? 0))") { [unowned self] in
                    self.houseInSameNeighborhood.value?.data?.items.count ?? 0 > 0
                }
                <- parseSearchInNeighborhoodCollectionNode(
                    houseInSameNeighborhood.value?.data,
                    traceExtension: traceExtension,
                    followStatus: self.followStatus,
                    navVC: self.navVC)
                <- parseOpenAllNode(houseInSameNeighborhood.value?.data?.hasMore ?? false, "查看同小区在售\(houseInSameNeighborhood.value?.data?.total ?? 0)套房源", barHeight: 0) { [unowned self] in
                    if let id = data.id ,
                        let title = data.name {

                        let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("same_neighborhood", key: "element_type") <|>
                                toTracerParams(id, key: "group_id") <|>
                                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams("neighborhood_detail", key: "page_type")
                        recordEvent(key: "click_loadmore", params: loadMoreParams)

                        let params = paramsOfMap([EventKeys.category_name: HouseCategory.same_neighborhood_list.rawValue]) <|>
                            theParams <|>
                            toTracerParams("slide", key: "card_type") <|>
                            toTracerParams("neighborhood_detail", key: "enter_from") <|>
                            // TODO: 埋点缺失logPB
//                            toTracerParams(self.houseInSameNeighborhood.value?.data?.logPB ?? [:], key: "log_pb") <|>
                            toTracerParams("same_neighborhood", key: "element_from") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb")

                        openErshouHouseList(
                                title: title+"(\(self.houseInSameNeighborhood.value?.data?.total ?? 0))",
                                neighborhoodId: id,
                                searchId: self.houseInSameNeighborhood.value?.data?.searchId,
                                disposeBag: self.disposeBag,
                                navVC: self.navVC,
                                searchSource: .neighborhoodDetail,
                                followStatus: self.followStatus,
                                tracerParams: params,
                                bottomBarBinder: self.bindBottomView(params: TracerParams.momoid()))
                    }
                }
                <- parseFlineNode(((houseInSameNeighborhood.value?.data?.hasMore ?? false) == false && houseInSameNeighborhood.value?.data?.total ?? 0 > 0) ? 6 : 0)

                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.total ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelatedNeighborhoodCollectionNode(
                    relatedItems,
                    traceExtension: traceExtension,
                    itemTracerParams: theParams <|> toTracerParams("neighborhood_detail", key: "page_type") <|> toTracerParams("neighborhood", key: "house_type"),
                    navVC: navVC)
                <- parseOpenAllNode(relateNeighborhoodData.value?.data?.hasMore ?? false, "查看\(relateNeighborhoodData.value?.data?.total ?? 0)个周边小区", barHeight: 6) { [unowned self] in
                    if let id = data.neighborhoodInfo?.id {
                        let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("neighborhood_nearby", key: "element_type") <|>
                                toTracerParams(id, key: "group_id") <|>
                                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                            toTracerParams("neighborhood_detail", key: "page_type") <|>
                            toTracerParams("click", key: "enter_type")
                        recordEvent(key: "click_loadmore", params: loadMoreParams)
                        let params = paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_nearby_list.rawValue]) <|>
                            theParams <|>
                            toTracerParams("slide", key: "card_type") <|>
                            toTracerParams(self.relateNeighborhoodData.value?.data?.logPB ?? [:], key: "log_pb") <|>
                            toTracerParams("neighborhood_nearby", key: "element_from") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb")

                        openRelatedNeighborhoodList(
                            neighborhoodId: id,
                            searchId: self.relateNeighborhoodData.value?.data?.searchId,
                            disposeBag: self.disposeBag,
                            tracerParams: params,
                            navVC: self.navVC,
                            bottomBarBinder: self.bindBottomView(params: TracerParams.momoid()))
                    }
                }
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }
    
    fileprivate func openTransactionHistoryPage(
        neighborhoodId: String,
        traceParams: TracerParams,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        let vc = TransactionHistoryVC(neighborhoodId: neighborhoodId, bottomBarBinder: bottomBarBinder)
        vc.tracerParams = traceParams
        navVC?.pushViewController(vc, animated: true)
    }
    
    fileprivate func openTransactionHistoryOrHouseListVCWithURL(url:String, data: NeighborhoodDetailData) {
        let decodedUrl = url.removingPercentEncoding ?? ""
        let arrUrls = decodedUrl.components(separatedBy: "?")
        if arrUrls.count > 0 {
            let openUrl = arrUrls[0]
            if let theUrl = URL(string: openUrl) {
                var params:[String:Any] = [:]
                if let id = data.id {
                    params["neighborhoodId"] = id
                }
                if let title = data.name {
                    params["title"] = title+"(\(self.houseInSameNeighborhood.value?.data?.total ?? 0))"
                }
                if let searchId = self.houseInSameNeighborhood.value?.data?.searchId {
                    params["searchId"] = searchId
                }
                params["searchSource"] = SearchSourceKey.neighborhoodDetail.rawValue
                params["followStatus"] = self.followStatus
                // add by zyk 要修改埋点数据，以及参数,区分不同的点击  important
                let tracePramas = TracerParams.momoid()
                params["tracerParams"] = tracePramas
                
                let bottomBarBinder = self.bindBottomView(params: TracerParams.momoid())
                params["bottomBarBinder"] = bottomBarBinder
                
                let userInfo = TTRouteUserInfo(info: params)
                TTRoute.shared().openURL(byPushViewController: theUrl,userInfo:userInfo)
            }
        }
    }
}

func getNeighborhoodDetailPageViewModel() -> (UITableView, EmptyMaskView, UINavigationController?, String?) -> DetailPageViewModel {
    return { (tableView, infoMaskView, navVC, searchId) in
        let viewModel = NeighborhoodDetailPageViewModel(tableView: tableView, infoMaskView: infoMaskView, navVC: navVC)
        viewModel.searchId = searchId
        return viewModel
    }
}


fileprivate class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var datas: [TableSectionNode] = []

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?

    var nearByCell : NewHouseNearByCell?

    init(cellFactory: UITableViewCellFactory) {
        self.cellFactory = cellFactory
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas[indexPath.section].type {
        case let .node(identifier):
            if identifier == "NewHouseNearByCell",let cellV = nearByCell
            {
                return cellV
            }
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas[indexPath.section].items[indexPath.row](cell)
            if cell is NewHouseNearByCell
            {
                nearByCell = cell as? NewHouseNearByCell
            }
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datas[indexPath.section].selectors?.isEmpty ?? true == false {
            datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
