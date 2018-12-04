 //
//  ErshouHouseDetailPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class ErshouHouseDetailPageViewModel: NSObject, DetailPageViewModel, TableViewTracer {
    var goDetailTraceParam: TracerParams?
    
    
    var houseType: HouseType = .secondHandHouse
    var houseId: Int64 = -1
    

    var showMessageAlert: ((String) -> Void)?

    var dismissMessageAlert: (() -> Void)?

    var onDataArrived: (() -> Void)?

    var onNetworkError: ((Error) -> Void)?

    var onEmptyData: (() -> Void)?

    var logPB: Any?

    var searchId: String?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "old_detail")

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var ershouHouseData = BehaviorRelay<ErshouHouseDetailResponse?>(value: nil)

    var groupId: String {
        get {
            return ershouHouseData.value?.data?.id ?? "be_null"
        }
    }

    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)

    private var houseInSameNeighborhood = BehaviorRelay<SameNeighborhoodHouseResponse?>(value: nil)

    private var relateErshouHouseData = BehaviorRelay<RelatedHouseResponse?>(value: nil)

    var contactPhone: BehaviorRelay<FHHouseDetailContact?> = BehaviorRelay<FHHouseDetailContact?>(value: nil)
    
    var houseStatus: BehaviorRelay<Int?> = BehaviorRelay<Int?>(value: nil)

    weak var navVC: UINavigationController?

    weak var infoMaskView: EmptyMaskView?

    var traceParams = TracerParams.momoid()

    var isRecordRelated: Bool = false

    var shareInfo: ShareInfo?

    var sameNeighborhoodFollowUp = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var recordRowIndex: Set<IndexPath> = []

    init(
        tableView: UITableView,
        infoMaskView: EmptyMaskView,
        navVC: UINavigationController?) {
        self.navVC = navVC
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        self.infoMaskView = infoMaskView
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)
        tableView.register(MultitemCollectionNeighborhoodCell.self, forCellReuseIdentifier: "MultitemCollectionCell-neighborhood")
        ershouHouseData
            .map { (response) -> FHHouseDetailContact? in
                return response?.data?.contact
            }
            .bind(to: contactPhone)
            .disposed(by: disposeBag)
        ershouHouseData
            .map { (response) -> Int? in
                return response?.data?.status
            }
            .bind(to: houseStatus)
            .disposed(by: disposeBag)
        super.init()

        Observable
            .combineLatest(ershouHouseData, relateNeighborhoodData, houseInSameNeighborhood, relateErshouHouseData)
            .bind { [weak self] (_) in
                
                if let status = self?.ershouHouseData.value?.data?.status, status == -1 {
                    
                    self?.infoMaskView?.isHidden = false
                    self?.infoMaskView?.label.text = "该房源已下架"
                    self?.infoMaskView?.retryBtn.isHidden = true
                    self?.infoMaskView?.isUserInteractionEnabled = false
                    return
                }
                
                if let result = self?.processData()([]) {
                    
                    self?.dataSource.datas = result
                    self?.tableView?.reloadData()
                    DispatchQueue.main.async {
                        
                        if let tableView = self?.tableView, let datas = self?.dataSource.datas {
                            
                            self?.traceDisplayCell(tableView: tableView, datas: datas)
                        }
                    }
                    
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
        let params = (EnvContext.shared.homePageParams <|>
                toTracerParams("old_detail", key: "page_type") <|>
                toTracerParams("\(self.houseId)", key: "group_id"))
            .exclude("search")
            .exclude("filter")
        tableView?.indexPathsForVisibleRows?.forEach({ [unowned self] (indexPath) in

            if !recordRowIndex.contains(indexPath) {
                self.callTracer(
                    tracer: datas[indexPath.section].tracer,
                    atIndexPath: indexPath,
                    traceParams: params)
                recordRowIndex.insert(indexPath)
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                theCell.hasShowOnScreen = true
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionNeighborhoodCell {
                theCell.hasShowOnScreen = true
            }

            if indexPath.section == 13 , !isRecordRelated {
                let relatedParams = params <|>
                    toTracerParams("related", key: "element_type")
                recordEvent(key: "element_show", params: relatedParams)
                isRecordRelated = true
            }
        })
    }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool) {
        self.houseId = houseId
        if showLoading {
            self.showMessageAlert?("正在加载")
        }
        requestErshouHouseDetail(houseId: houseId, logPB: logPB)
                .subscribe(onNext: { [weak self] (response) in
                    if showLoading {
                        self?.dismissMessageAlert?()
                    }
                    if let response = response{

                        self?.contactPhone.accept(response.data?.contact)

                        if response.status == 0{
                            if let idStr = response.data?.id
                            {
                                if idStr != ""
                                {
                                    self?.titleValue.accept(response.data?.title)
                                    self?.ershouHouseData.accept(response)
                                    self?.requestReletedData()
                                    self?.onDataArrived?()
                                }else
                                {
                                    self?.onEmptyData?()
                                }
                            }else
                            {
                                self?.onEmptyData?()
                            }
                         }else
                        {
                            self?.onEmptyData?()
                        }
                    }else
                    {
                        self?.onEmptyData?()
                    }
                    if let status = response?.data?.userStatus {
                        self?.followStatus.accept(Result.success(status.houseSubStatus == 1))
                    }
                }, onError: { [weak self] (error) in
                    self?.onNetworkError?(error)
                    EnvContext.shared.toast.showToast("网络异常")
                })
                .disposed(by: disposeBag)

        requestRelatedHouseSearch(houseId: "\(houseId)", count:5)
            .subscribe(onNext: { [unowned self] response in
                self.relateErshouHouseData.accept(response)
            })
            .disposed(by: disposeBag)

    }

    func followThisItem(isNeedRecord: Bool, traceParam: TracerParams) {
        switch followStatus.value {
        case let .success(status):
            if status {
                cancelFollowIt(
                        houseType: .secondHandHouse,
                        followAction: .ershouHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag)()
            } else {
                followIt(
                        houseType: .secondHandHouse,
                        followAction: .ershouHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag)()
                self.recordFollowEvent(traceParam)

            }
        case .failure(_): do {}
        }

    }

    func requestReletedData() {
        if let neighborhoodId = ershouHouseData.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                .subscribe(onNext: { [unowned self] response in
                    self.relateNeighborhoodData.accept(response)
                })
                .disposed(by: disposeBag)
            
//            requestSearch(offset: 0, query: "neighborhood_id=\(neighborhoodId)&house_id=\(houseId)&house_type=\(HouseType.secondHandHouse.rawValue)")
            requestHouseInSameNeighborhoodSearch(neighborhoodId: neighborhoodId, houseId: "\(houseId)")
                .subscribe(onNext: { [unowned self] response in
                    self.houseInSameNeighborhood.accept(response)
                })
                .disposed(by: disposeBag)

        }
        
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = ershouHouseData.value?.data {
            shareInfo = data.shareInfo
            
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
            
            var searchIdForDetail : String?
            if let logPb = traceParamsDic["log_pb"] {
                if let logPbV = logPb as? Dictionary<String, Any>,let searchIdV = logPbV["search_id"] as? String
                {
                    searchIdForDetail = searchIdV
                }
            }
            
            /*
            if let code = traceParamsDic["search_id"] as? String {
                traceExtension = traceExtension <|>
                    toTracerParams(String(code), key: "search_id")
            }
            */
            
            let openBeighBor = openFloorPanDetailPage(
                floorPanId: data.neighborhoodInfo?.id,
                logPb: data.neighborhoodInfo?.logPB,
                searchId: searchIdForDetail,
                sameNeighborhoodFollowUp: sameNeighborhoodFollowUp)

            let theParams = EnvContext.shared.homePageParams <|>
                    toTracerParams(data.logPB ?? [:], key: "log_pb") <|>
                    toTracerParams("slide", key: "card_type")
            self.logPB = data.logPB

            let searchId = relateNeighborhoodData.value?.data?.searchId
            let relatedItems = relateNeighborhoodData.value?.data?.items?.map({ (item) -> NeighborhoodInnerItemEntity in
                var newItem = item
                newItem.fhSearchId = searchId
                return newItem
            })
            
            let relateSearchId = relateErshouHouseData.value?.data?.searchId
            let relatedErshouItems = relateErshouHouseData.value?.data?.items?.map({ (item) -> HouseItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = relateSearchId
                return newItem
            })
            
            
            var pictureParams = EnvContext.shared.homePageParams <|> toTracerParams("old_detail", key: "page_type")
            pictureParams = pictureParams <|>
                toTracerParams(self.houseId, key: "group_id") <|>
                toTracerParams(self.searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")

            let dataParser = DetailDataParser.monoid()
                <- parseErshouHouseCycleImageNode(data,traceParams: pictureParams, disposeBag: disposeBag)
                <- parseErshouHouseNameNode(data)
                <- parseErshouHouseCoreInfoNode(data)
                <- parsePriceChangeHistoryNode(data,traceExtension: traceExtension)
                <- parsePropertyListNode(data)
                <- parseFlineNode(data.baseInfo != nil ? 6: 0)
                <- parseHouseOutlineHeaderNode("房源概况", data,traceExtension: traceExtension) {
                    (data.outLineOverreview == nil) ? false : true
                }
                <- parseHouseOutlineListNode(data)
                <- parseHeaderNode("小区 \(data.neighborhoodInfo?.name ?? "")", subTitle: "查看更多", showLoadMore: data.neighborhoodInfo != nil ? true : false, adjustBottomSpace: -10, process: openBeighBor) {
                    return data.neighborhoodInfo != nil ? true : false
                }
                <- parseNeighborhoodInfoNode(data, traceExtension: traceExtension, neighborhoodId: "\(self.houseId)", navVC: self.navVC)
                <- parseHeaderNode("价格分析")
                <- parsePriceRankNode(data.housePriceRank, traceExtension: traceExtension)

                // 均价走势
                <- parseErshouHousePriceChartNode(data, traceExtension: traceExtension, navVC: self.navVC){
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
                            toTracerParams("old_detail", key: "page_type") <|>
                            toTracerParams(searchId, key: "search_id") <|>
                            toTracerParams(rankValue,key: "rank")
                            recordEvent(key: "click_price_trend", params: loadMoreParams)
                    }
                }
                <- parseFlineNode(6)
                // 购房小建议
                <- parsePriceRangeNode(data.housePriceRank, traceExtension: traceExtension)
                <- parseFlineNode(data.housePriceRank?.buySuggestion != nil ? 6: 0)
                <- parseHeaderNode("同小区房源(\(houseInSameNeighborhood.value?.data?.total ?? 0))", subTitle: "查看更多", showLoadMore: houseInSameNeighborhood.value?.data?.hasMore ?? false, adjustBottomSpace: -20, process: { [unowned self]  (traceParam) in
                        if let hasMore = self.houseInSameNeighborhood.value?.data?.hasMore, hasMore == true {
                            if let id = data.neighborhoodInfo?.id,
                                let title = data.neighborhoodInfo?.name {
                                
                                let loadMoreParams = EnvContext.shared.homePageParams <|>
                                    toTracerParams("same_neighborhood", key: "element_type") <|>
                                    toTracerParams(id, key: "group_id") <|>
                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                    toTracerParams("old_detail", key: "page_type") <|>
                                    toTracerParams("click", key: "enter_type")
                                recordEvent(key: "click_loadmore", params: loadMoreParams)
                                
                                let params = theParams <|>
                                    //                            toTracerParams("same_neighborhood", key: "element_type") <|>
                                    paramsOfMap([EventKeys.category_name: HouseCategory.same_neighborhood_list.rawValue]) <|>
                                    toTracerParams("same_neighborhood", key: "element_from") <|>
                                    toTracerParams("old_detail", key: "enter_from") <|>
                                    toTracerParams("click", key: "enter_type") <|>
                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb")

                                openErshouHouseList(
                                    title: title+"(\(self.houseInSameNeighborhood.value?.data?.total ?? 0))",
                                    neighborhoodId: id,
                                    houseId: data.id,
                                    searchId: self.houseInSameNeighborhood.value?.data?.searchId,
                                    disposeBag: self.disposeBag,
                                    navVC: self.navVC,
                                    searchSource: .oldDetail,
                                    tracerParams: params,
                                    bottomBarBinder: self.bindBottomView(params: loadMoreParams <|> toTracerParams("old_detail", key: "page_type")))
                            }
                        }
                    }, filter: {[unowned self] () -> Bool in
                        self.houseInSameNeighborhood.value?.data?.items.count ?? 0 > 0
                })
                <- parseSearchInNeighborhoodNodeCollection(houseInSameNeighborhood.value?.data, traceExtension: traceExtension, navVC: navVC, tracerParams: theParams)
                <- parseFlineNode(houseInSameNeighborhood.value?.data?.total ?? 0 > 0 ? 6 : 0)
                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.total ?? 0))", subTitle: "查看更多", showLoadMore: relateNeighborhoodData.value?.data?.hasMore ?? false, adjustBottomSpace: -20, process: { [unowned self]  (traceParam) in
                        if let hasMore = self.relateNeighborhoodData.value?.data?.hasMore, hasMore == true {
                            if let id = data.neighborhoodInfo?.id {
                                
                                let loadMoreParams = EnvContext.shared.homePageParams <|>
                                    toTracerParams("neighborhood_nearby", key: "element_type") <|>
                                    toTracerParams(id, key: "group_id") <|>
                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                    toTracerParams("old_detail", key: "page_type")
                                recordEvent(key: "neighborhood_nearby", params: loadMoreParams)
                                
                                let params = theParams <|>
                                    paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_nearby_list.rawValue]) <|>
                                    toTracerParams("neighborhood_nearby", key: "element_from") <|>
                                    toTracerParams("old_detail", key: "enter_from") <|>
                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                    toTracerParams("click", key: "enter_type")
                                
                                openRelatedNeighborhoodList(
                                    neighborhoodId: id,
                                    searchId: self.relateNeighborhoodData.value?.data?.searchId,
                                    disposeBag: self.disposeBag,
                                    tracerParams: params,
                                    navVC: self.navVC,
                                    bottomBarBinder: self.bindBottomView(params: loadMoreParams <|> toTracerParams("old_detail", key: "page_type")))
                            }
                        }
                    }, filter: { () -> Bool in
                        self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                })
                <- parseRelatedNeighborhoodCollectionNode(
                    relatedItems,
                    traceExtension: traceExtension,
                    itemTracerParams: theParams <|> toTracerParams("old_detail", key: "page_type") <|> toTracerParams("neighborhood", key: "house_type"),
                    navVC: self.navVC)
                <- parseFlineNode((relateNeighborhoodData.value?.data?.total ?? 0) > 0 ? 6 : 0)
                <- parseHeaderNode("周边房源", adjustBottomSpace: 0) {[unowned self] in
                    self.relateErshouHouseData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseErshouHouseListItemNode(
                    relatedErshouItems,
                    traceExtension: traceExtension,
                    disposeBag: disposeBag,
                    tracerParams: theParams <|>
                        toTracerParams("related", key: "element_type") <|>
//                        toTracerParams("related", key: "element_from") <|>
                        toTracerParams("old", key: "house_type") <|>
                        toTracerParams("old_detail", key: "page_type"),
                    navVC: self.navVC)
                <- parseOpenAllNode(relateErshouHouseData.value?.data?.hasMore ?? false, callBack: {[unowned self] in
                        if let id = data.neighborhoodInfo?.id {
                            let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("related", key: "element_type") <|>
                                toTracerParams(id, key: "group_id") <|>
                                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams("old_detail", key: "page_type") <|>
                                toTracerParams(self.searchId ?? "", key: "search_id") <|>
                                toTracerParams(self.searchId ?? "", key: "origin_search_id") <|>
                                toTracerParams("click", key: "enter_type") <|>
                                toTracerParams("old_detail", key: "enter_from")
                            
                            
                            openAroundHouseList(title: "周边房源", neighborhoodId: id,houseId: data.id ,  disposeBag: self.disposeBag,houseType:self.houseType,  navVC: self.navVC, searchSource: .oldDetail, tracerParams: loadMoreParams , bottomBarBinder: self.bindBottomView(params: loadMoreParams <|> toTracerParams("old_detail", key: "page_type")))
                        }
                    })
                <- parseErshouHouseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    fileprivate func openFloorPanDetailPage(
        floorPanId: String?,
        logPb: Any?,
        searchId: String?,
        sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>) -> (TracerParams) -> Void {
        return { [unowned self] (theTracerParams) in
            if let floorPanId = floorPanId, let id = Int64(floorPanId) {
                let params = TracerParams.momoid() <|>
                    EnvContext.shared.homePageParams <|>
                    toTracerParams("neighborhood_detail", key: "element_from") <|>
                    toTracerParams(logPb ?? "be_null", key: "log_pb") <|>
                    toTracerParams(searchId ?? "be_null", key: "search_id") <|>
                    toTracerParams("old_detail", key: "enter_from") <|>
                    toTracerParams("no_pic", key: "card_type")

                openNeighborhoodDetailPage(
                    neighborhoodId: Int64(id),
                    logPB: nil,
                    disposeBag: self.disposeBag,
                    tracerParams: params,
                    sameNeighborhoodFollowUp: sameNeighborhoodFollowUp,
                    navVC: self.navVC)(theTracerParams)
            }
        }
    }


}

func openErshouHouseList(
        title: String?,
        neighborhoodId: String,
        houseId: String? = nil,
        searchId: String? = nil,
        disposeBag: DisposeBag,
        navVC: UINavigationController?,
        searchSource: SearchSourceKey,
        followStatus: BehaviorRelay<Result<Bool>>? = nil,
        tracerParams: TracerParams = TracerParams.momoid(),
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
    let listVC = ErshouHouseListVC(
        title: title,
        neighborhoodId: neighborhoodId,
        houseId: houseId,
        searchSource: searchSource,
        searchId: searchId,
        bottomBarBinder: bottomBarBinder)
    listVC.followStatus = followStatus
    listVC.tracerParams = tracerParams
    navVC?.pushViewController(listVC, animated: true)
}

//跳转到小区租房列表页
func openRentHouseList(
    title: String?,
    neighborhoodId: String,
    houseId: String? = nil,
    searchId: String? = nil,
    disposeBag: DisposeBag,
    navVC: UINavigationController?,
    searchSource: SearchSourceKey,
    followStatus: BehaviorRelay<Result<Bool>>? = nil,
    tracerParams: TracerParams = TracerParams.momoid(),
    bottomBarBinder: @escaping FollowUpBottomBarBinder) {
            
    let listVC = ErshouHouseListVC(
        title: title,
        neighborhoodId: neighborhoodId,
        houseId: houseId,
        searchSource: searchSource,
        searchId: searchId,
        houseType:HouseType.rentHouse,
        bottomBarBinder: bottomBarBinder)
    listVC.followStatus = followStatus
    listVC.tracerParams = tracerParams 
    navVC?.pushViewController(listVC, animated: true)
}

//跳转到周边房源
func openAroundHouseList(
    title: String?,
    neighborhoodId: String,
    houseId: String? = nil,
    searchId: String? = nil,
    disposeBag: DisposeBag,
    houseType: HouseType ,
    navVC: UINavigationController?,
    searchSource: SearchSourceKey,
    followStatus: BehaviorRelay<Result<Bool>>? = nil,
    tracerParams: TracerParams = TracerParams.momoid(),
    bottomBarBinder: @escaping FollowUpBottomBarBinder) {
    
    let listVC = ErshouHouseListVC(
        title: title,
        neighborhoodId: neighborhoodId,
        houseId: houseId,
        searchSource: searchSource,
        searchId: searchId,
        houseType: houseType,
        relatedHouse: true ,
        bottomBarBinder: bottomBarBinder)
    listVC.followStatus = followStatus   
    
    listVC.tracerParams = tracerParams
    navVC?.pushViewController(listVC, animated: true)
}



fileprivate class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource, TableViewTracer {

    var datas: [TableSectionNode] = []

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?
    
    var priceChartFoldState:Bool = true
    
    var cellHeightCaches:[String:CGFloat] = [:]

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
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            
            if let refreshCell = cell as? ErshouHousePriceChartCell {
                let tempRefreshCell = refreshCell
                tempRefreshCell.isPriceChartFoldState = self.priceChartFoldState
                processRefreshableTableViewCell(
                    cell: tempRefreshCell,
                    indexPath: indexPath,
                    tableView: tableView)
            }
            
            datas[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }
    
    fileprivate func processRefreshableTableViewCell(
        cell: ErshouHousePriceChartCell,
        indexPath: IndexPath,
        tableView: UITableView) {
        let tempCell = cell
        tempCell.refreshCallback = { [weak tableView, weak self, weak tempCell] in
            self?.changePriceChartFoldState()
            tableView?.beginUpdates()
            if let refreshCell = tempCell {
                let tempRefreshCell = refreshCell
                tempRefreshCell.isPriceChartFoldState = self?.priceChartFoldState ?? true
                self?.datas[indexPath.section].items[indexPath.row](refreshCell)
                tempRefreshCell.setNeedsUpdateConstraints()
            }
            tableView?.endUpdates()
        }
    }
    
    fileprivate func changePriceChartFoldState()
    {
        self.priceChartFoldState = !self.priceChartFoldState
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
        let tempKey = "\(indexPath.section)_\(indexPath.row)"
        if let height = self.cellHeightCaches[tempKey] {
            return height
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let tempKey = "\(indexPath.section)_\(indexPath.row)"
        cellHeightCaches[tempKey] = cell.frame.size.height
    }
}

func getErshouHouseDetailPageViewModel() -> DetailPageViewModelProvider {
    return { (tableView, infoMaskView, navVC, searchId) in
        let viewModel = ErshouHouseDetailPageViewModel(tableView: tableView, infoMaskView: infoMaskView, navVC: navVC)
        viewModel.searchId = searchId
        return viewModel
    }
}

func parseFHHomeErshouHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        var traceParmas = tracerParams.paramsGetter([:])
        var elementFrom: String = "related"
        if let elementFromV = (traceParmas["element_from"] ?? elementFrom) as? String
        {
            elementFrom = elementFromV
        }
        
        let selectors = data?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                return openErshouHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                        logPB: item.logPB,
                disposeBag: disposeBag,
                tracerParams: tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
//                    toTracerParams("maintab", key: "enter_from") <|>
                    toTracerParams(elementFrom, key: "element_from") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                navVC: navVC)
        }

        let paramsElement = TracerParams.momoid() <|>
            toTracerParams("related", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
            traceExtension

        var records = data?
                .filter {
                    $0.id != nil
                }
                .enumerated()
                .map { (e) -> ElementRecord in
                    let (offset, item) = e
                    let theParams = tracerParams <|>
                            toTracerParams(offset, key: "rank") <|>
                            toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                            toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                            toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                            toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                    return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from").exclude("enter_from"))
                }
        records?.insert(elementShowOnceRecord(params:paramsElement), at: 0)
        
        let count = data?.count ?? 0
        if let renders = data?.enumerated().map({ (index, item) in
            data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
        }), let selectors = selectors ,count != 0 {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: nil,
                label: "",
                type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
        } else {
            return nil
        }
    }
}

func parseErshouHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        var traceParmas = tracerParams.paramsGetter([:])
        var elementFrom: String = "related"
        if let elementFromV = (traceParmas["element_from"] ?? elementFrom) as? String
        {
            elementFrom = elementFromV
        }
        
        let selectors = data?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                return openErshouHouseDetailPage(
                    houseId: Int64(item.id ?? "")!,
                    logPB: item.logPB,
                    disposeBag: disposeBag,
                    tracerParams: tracerParams <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                        //                    toTracerParams("maintab", key: "enter_from") <|>
                        toTracerParams(elementFrom, key: "element_from") <|>
                        toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                    navVC: navVC)
        }
        
        let paramsElement = TracerParams.momoid() <|>
            toTracerParams("related", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
        traceExtension
        
        var records = data?
            .filter {
                $0.id != nil
            }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from"))
        }
        records?.insert(elementShowOnceRecord(params:paramsElement), at: 0)
        
        let count = data?.count ?? 0
        if let renders = data?.enumerated().map({ (index, item) in
            data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
        }), let selectors = selectors ,count != 0 {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: nil,
                label: "",
                type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
        } else {
            return nil
        }
    }
}

func parseErshouHouseListItemNode(
    _ data: HouseRecommendSection?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let params = tracerParams <|>
            toTracerParams("old", key: "house_type") <|>
            toTracerParams("left_pic", key: "card_type") <|>
            beNull(key: "element_from") <|>
            toTracerParams("old_detail", key: "page_type")
        
        let paramsElement = TracerParams.momoid() <|>
            toTracerParams("related", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
            traceExtension
        
        let selectors = data?.items?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag, tracerParams: params, navVC: navVC) }
        let count = data?.items?.count ?? 0
        if let renders = data?.items?
            .enumerated()
            .map({ (arg) -> TableCellRender in
                
                let (index, item) = arg
                return curry(fillErshouHouseListitemCell)(item)(index == count - 1)
            }), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: [elementShowOnceRecord(params:paramsElement)],
                sectionTracer: nil,
                label: data?.title ?? "精选好房",
                type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func parseErshouHouseListRowItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>? = nil,
    houseSearchParams: TracerParams?,
    navVC: UINavigationController?) -> [TableRowNode] {
    // 二手房列表
    var traceDict = traceParams.paramsGetter([:])
    
    let params = traceParams <|>
        toTracerParams("old", key: "house_type") <|>
//        toTracerParams("old_list", key: "page_type") <|>
        toTracerParams("left_pic", key: "card_type")
    let selectors = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> (TracerParams) -> Void in
            let (_, item) = e
            return openErshouHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                logPB: item.logPB,
                followStatus: sameNeighborhoodFollowUp,
                disposeBag: disposeBag,
                tracerParams: params <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams("be_null", key: "element_from") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                houseSearchParams: houseSearchParams,
                navVC: navVC)
    }

    let records = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (_, item) = e
            let theParams = params <|>
//                toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
//                toTracerParams("be_null", key: "element_type") <|>
                toTracerParams("old", key: "house_type")
            return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from").exclude("enter_from"))
    }
    let count = data?.count ?? 0
    if let renders = data?.enumerated().map( { (index, item) in
        curry(fillErshouHouseListitemCell)(item)(index == count - 1)
    }),
        let selectors = selectors,
        let records = records {
        let items = zip(selectors, records)

        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                tracer: item.1,
                type: .node(identifier: SingleImageInfoCell.identifier),
                editor: nil)
        }
    } else {
        return []
    }
}


func parseErshouRelatedHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) ->  [TableRowNode] {
    
    var traceParmas = tracerParams.paramsGetter([:])
    var elementFrom: String = "related"
    if let elementFromV = (traceParmas["element_from"] ?? elementFrom) as? String
    {
        elementFrom = elementFromV
    }
    
    let selectors = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> (TracerParams) -> Void in
            let (offset, item) = e
            return openErshouHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                logPB: item.logPB,
                disposeBag: disposeBag,
                tracerParams: tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    //                    toTracerParams("maintab", key: "enter_from") <|>
                    toTracerParams(elementFrom, key: "element_from") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                navVC: navVC)
    }
    
    let paramsElement = TracerParams.momoid() <|>
        toTracerParams("related", key: "element_type") <|>
        toTracerParams("old_detail", key: "page_type") <|>
    traceExtension
    
    var records = data?
        .filter {
            $0.id != nil
        }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (offset, item) = e
            let theParams = tracerParams <|>
                toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb")
            return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from").exclude("enter_from"))
    }
    records?.insert(elementShowOnceRecord(params:paramsElement), at: 0)
    
    let count = data?.count ?? 0
    
    if let renders = data?.enumerated().map( { (index, item) in
        data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
//        curry(fillErshouHouseListitemCell)(item)(index == count - 1)
    }),
        let selectors = selectors,
        let records = records {
        let items = zip(selectors, records)
        
        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                tracer: item.1,
                type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier),
                editor: nil)
        }
    } else {
        return []
    }
    
//    if let renders = data?.enumerated().map({ (index, item) in
//        data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
//    }), let selectors = selectors ,count != 0 {
//        return TableSectionNode(
//            items: renders,
//            selectors: selectors,
//            tracer: records,
//            sectionTracer: nil,
//            label: "",
//            type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
//    } else {
//        return []
//    }
    
}



func fillErshouHouseListitemCell(_ data: HouseItemInnerEntity,
                                 isLastCell: Bool = false,
                                 cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.displayTitle
        theCell.extendTitle.text = data.displaySubtitle
        theCell.isTail = isLastCell

        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
            createTagAttrString(
                item.content,
                isFirst: offset == 0,
                textColor: hexStringToUIColor(hex: item.textColor),
                backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
        })
        
        var height: CGFloat = 0
        attrTexts?.enumerated().forEach({ (e) in
            let (offset, tag) = e
            
            text.append(tag)
            
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 170, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        })
        
        theCell.areaLabel.attributedText = text
        theCell.areaLabel.snp.updateConstraints { (maker) in

            maker.left.equalToSuperview().offset(-3)
        }

        theCell.priceLabel.text = data.displayPrice
        theCell.roomSpaceLabel.text = data.displayPricePerSqm
        theCell.majorImageView.bd_setImage(with: URL(string: data.houseImage?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        if let houseImageTag = data.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            theCell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            theCell.imageTopLeftLabel.text = houseImageTag.text
            theCell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            theCell.imageTopLeftLabelBgView.isHidden = false
        } else {
            theCell.imageTopLeftLabelBgView.isHidden = true
        }
        theCell.updateOriginPriceLabelConstraints(originPriceText: data.originPrice)
        theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
    }
}

func parseFollowUpListRowItemNode(_ data: UserFollowData,
                                  hasMore: Bool = true,
                                  disposeBag: DisposeBag,
                                  navVC: UINavigationController?) -> [TableRowNode] {
    
    let count = data.items.count
    let adapters = data.items
        .enumerated()
        .filter { $1.followId != nil }
        .map { (index, item) -> (TableCellSelectedProcess, ElementRecord, (BaseUITableViewCell) -> Void, (UITableViewCellEditingStyle) -> Observable<TableRowEditResult>) in
            
            var item = item
            item.fhSearchId = data.searchId
            
            let selector = openDetailPage(
                houseType: HouseType(rawValue: item.houseType!),
                followUpId: Int64(item.followId!) ?? 0,
                disposeBag: disposeBag,
                logPB: item.logPB as? [String : Any],
                navVC: navVC)
            
            let houseType = HouseType(rawValue: item.houseType ?? 0) ?? .newHouse
            let houseShowParams = TracerParams.momoid() <|>
                toTracerParams(houseTypeStringByHouseType(houseType: houseType), key: "house_type") <|>
                toTracerParams("left_pic", key: "card_type") <|>
                toTracerParams(categoryNameByHouseType(houseType: houseType), key: "page_type") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams("be_null", key: "element_type")
            
            let tracer = onceRecord(key: TraceEventName.house_show, params: houseShowParams.exclude("element_from"))
            
            let render = curry(fillFollowUpListItemCell)(item)(!hasMore && index == count - 1)
            let editor = { (style: UITableViewCellEditingStyle) -> Observable<TableRowEditResult> in
                if let ht = HouseType(rawValue: item.houseType ?? -1), let followId = item.followId {
                    
                    var tracerParams = TracerParams.momoid()
                    tracerParams = tracerParams <|>
                        toTracerParams(categoryNameByHouseType(houseType: ht), key: "page_type")
                    tracerParams = tracerParams <|>
                        toTracerParams(followId, key: "group_id") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                    recordEvent(key: TraceEventName.delete_follow, params: tracerParams)
                    
                    return cancelFollowUp(houseType: ht, followId: followId)
                } else {
                    return .empty()
                }
            }
            return (selector, tracer, render, editor)
        }

    return adapters.map({ e -> TableRowNode in
        let (selector, tracer, render, editor) = e
        return TableRowNode(
            itemRender: render,
            selector: selector,
            tracer: tracer,
            type: .node(identifier: SingleImageInfoCell.identifier),
            editor: editor)
    })

}

fileprivate func categoryNameByHouseType(houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "new_follow_list"
    case .rentHouse:
        return "rent_follow_list"
    case .secondHandHouse:
        return "old_follow_list"
    case .neighborhood:
        return "neighborhood_follow_list"
    default:
        return "be_null"
    }
}

fileprivate func houseTypeStringByHouseType(houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "new"
    case .secondHandHouse:
        return "old"
    case .neighborhood:
        return "neighborhood"
    case .rentHouse:
        return "rent"
    default:
        return "be_null"
    }
}


fileprivate func openDetailPage(
    houseType: HouseType?,
    followUpId: Int64,
    disposeBag: DisposeBag,
    logPB: [String: Any]? = nil,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    var params = TracerParams.momoid() <|>
        toTracerParams("old", key: "house_type") <|>
        beNull(key: "element_from") <|>
        toTracerParams("left_pic", key: "card_type")
    guard let houseType = houseType else {
        return openErshouHouseDetailPage(houseId: followUpId, disposeBag: disposeBag, tracerParams: params, navVC: navVC)
    }
    
    switch houseType {
    case .newHouse:
        params = params <|>
            toTracerParams("new_follow_list", key: "enter_from") <|>
            toTracerParams(logPB ?? "be_null", key: "log_pb")
        return openNewHouseDetailPage(
            houseId: followUpId,
            logPB: logPB,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: navVC)
    case .secondHandHouse:
        params = params <|>
            toTracerParams("old_follow_list", key: "enter_from") <|>
        toTracerParams(logPB ?? "be_null", key: "log_pb")
        return openErshouHouseDetailPage(
            houseId: followUpId,
            logPB: logPB,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: navVC)
    case .rentHouse:
        params = params <|>
            toTracerParams("rent_follow_list", key: "enter_from") <|>
            toTracerParams(logPB ?? "be_null", key: "log_pb")
        return openRentHouseDetailPage(
            houseId: followUpId,
            logPB: logPB,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: navVC)
    case .neighborhood:
        params = params <|>
            toTracerParams("neighborhood_follow_list", key: "enter_from") <|>
        toTracerParams(logPB ?? "be_null", key: "log_pb")
        return openNeighborhoodDetailPage(
            neighborhoodId: followUpId,
            logPB: logPB,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: navVC)
    case .rentHouse:
        params = params <|>
            toTracerParams("rent_follow_list", key: "enter_from") <|>
            toTracerParams(logPB ?? "be_null", key: "log_pb")
        return openRentHouseDetailPage(houseId: followUpId,
                                       tracerParams: params)
    default:
        return openErshouHouseDetailPage(
            houseId: followUpId,
            logPB: logPB,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: navVC)
    }
}

func cancelFollowUp(houseType: HouseType, followId: String) -> Observable<TableRowEditResult> {
    if let actionType = FollowActionType(rawValue: houseType.rawValue) {
        EnvContext.shared.toast.dismissToast()
        return requestCancelFollow(
                houseType: houseType,
                followId: followId,
                actionType: actionType)
                .map { response -> TableRowEditResult in
                    if response?.status ?? -1 != 0 {
                        return TableRowEditResult.success(response?.message ?? "取消成功")
                    } else {
                        if let status = response?.status, let message = response?.message {
                            return TableRowEditResult.error(BizError.bizError(status, message))
                        } else {
                            return TableRowEditResult.error(BizError.unknownError)
                        }
                    }
                }
    } else {
        return .empty()
    }
}

func fillFollowUpListItemCell(_ data: UserFollowData.Item,
                              isLastCell: Bool = false,
                              cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.title
        theCell.extendTitle.text = data.description
        theCell.isTail = isLastCell

        if data.houseType == HouseType.neighborhood.rawValue {
            
            let text = NSMutableAttributedString(string: "\(data.saleInfo ?? "")")
            text.yy_font = CommonUIStyle.Font.pingFangRegular(12)
            text.yy_color = hexStringToUIColor(hex: kFHCoolGrey2Color)
            theCell.areaLabel.attributedText = text
            theCell.areaLabel.snp.updateConstraints { (maker) in

                maker.height.equalTo(17)
            }
            theCell.priceLabel.text = data.pricePerSqm
            theCell.priceLabel.snp.makeConstraints { maker in
                maker.top.equalTo(theCell.areaLabel.snp.bottom).offset(3)
            }
            
        } else {
            
            theCell.priceLabel.snp.makeConstraints { maker in
                maker.top.equalTo(theCell.areaLabel.snp.bottom).offset(5)
            }
            let text = NSMutableAttributedString()
            let attrTexts = data.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
                createTagAttrString(
                    item.content,
                    isFirst: offset == 0,
                    textColor: hexStringToUIColor(hex: item.textColor),
                    backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
            })
            
            var height: CGFloat = 0
            attrTexts?.enumerated().forEach({ (e) in
                let (offset, tag) = e
                
                text.append(tag)
                
                let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 170, height: CGFloat.greatestFiniteMagnitude), text: text)
                let lineHeight = tagLayout?.textBoundingSize.height ?? 0
                if lineHeight > height {
                    if offset != 0 {
                        text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                    }
                    if offset == 0 {
                        height = lineHeight
                    }
                }
            })
            theCell.areaLabel.attributedText = text
            theCell.areaLabel.snp.updateConstraints { (maker) in
                maker.left.equalToSuperview().offset(-3)
            }
            
            if data.houseType == HouseType.secondHandHouse.rawValue {
                theCell.roomSpaceLabel.text = data.pricePerSqm
                theCell.priceLabel.text = data.price

            }else if data.houseType == HouseType.rentHouse.rawValue{
                theCell.priceLabel.text = data.price
            }
            else {
                theCell.priceLabel.text = data.pricePerSqm
            }
        }


        theCell.majorImageView.bd_setImage(with: URL(string: data.images.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        theCell.updateOriginPriceLabelConstraints(originPriceText: nil)
    }
}

func openRentHouseDetailPage(houseId: Int64,
                             tracerParams: TracerParams,
                             houseSearchParams: TracerParams? = nil)  -> (TracerParams) -> Void {
    return { (params) in
        var tracer: [String: Any?] = tracerParams.paramsGetter([:])

        var houseSearchDict : [String : Any]? = nil
        if let houseSearchParams = houseSearchParams?.paramsGetter([:]) {
            houseSearchDict = houseSearchParams
            tracer.merge(houseSearchParams, uniquingKeysWith: { (left, right) -> Any? in
                right
            })
        }
        if let paramsDict: [String: Any?] = params.paramsGetter([:]) {
            tracer.merge(paramsDict, uniquingKeysWith: { (left, right) -> Any? in
                right
            })
        }
        tracer["element_from"] = "be_null"
        tracer["card_type"] = "left_pic"
        tracer["origin_from"] = "minetab_rent"

        var info = ["tracer": tracer]
        if let hsp = houseSearchDict  {
            info["house_search_params"] = hsp
        }
        
        let userInfo = TTRouteUserInfo(info: info)
        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(houseId)"), userInfo: userInfo)
    }
}

func openErshouHouseDetailPage(
    houseId: Int64,
    logPB: [String: Any]? = nil,
    followStatus: BehaviorRelay<Result<Bool>>? = nil,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    houseSearchParams: TracerParams? = nil,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    return { (params) in

        let detailPage = HorseDetailPageVC(
            houseId: houseId,
            houseType: .secondHandHouse,
            isShowBottomBar: true,
            provider: getErshouHouseDetailPageViewModel())
        detailPage.logPB = logPB
        detailPage.houseSearchParams = houseSearchParams
        if let followStatus = followStatus {
            detailPage.sameNeighborhoodFollowUp.accept(followStatus.value)

            detailPage.sameNeighborhoodFollowUp
                .debug("sameNeighborhoodFollowUp")
                .bind(to: followStatus)
                .disposed(by: disposeBag)
        }
        detailPage.traceParams = EnvContext.shared.homePageParams <|> tracerParams <|> params
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { [weak navVC] void in
                EnvContext.shared.toast.dismissToast()
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}
