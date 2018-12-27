//
// Created by linlin on 2018/7/5.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum PullTriggerType: Int {
    case pullUpType = -1
    case pullDownType = -2
}

enum RequestSuccessType: Int {
    case requestSuccessTypeNormal = 1 //数据及网络正常
    case requestSuccessTypeNoData = 2 //暂无数据，该城市
    case requestSuccessTypeDataError = 3 //数据异常，缺少必要参数，转json不成功等
    case requestSuccessTypeInvalidNetWork = 4 //无网络
}


class HomeListViewModel: DetailPageViewModel {


    var source: String?
    
    var goDetailTraceParam: TracerParams?
    
    var houseType: HouseType = .newHouse
    var houseId: Int64 = -1
    
    var showMessageAlert: ((String) -> Void)?
    
    var dismissMessageAlert: (() -> Void)?
    
    var searchId: String?
    
    var groupId: String {
        get {
            return "be_null"
        }
    }
    
    var shareInfo: ShareInfo?
    
    var onDataArrived: (() -> Void)?
    
    var onNetworkError: ((Error) -> Void)?
    
    var onEmptyData: (() -> Void)?
    
    var logPB: Any?
    
    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "be_null")
    
    var traceParams = TracerParams.momoid()
    
    var followTraceParams: TracerParams = TracerParams.momoid()
    
    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))
    
    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    weak var tableView: UITableView?
    
    private var cellFactory: UITableViewCellFactory
    
    fileprivate var dataSource: FHFunctionListDataSourceDelegate?
    
    let disposeBag = DisposeBag()
    
    let disposeBagHouse = DisposeBag()
    
    var originSearchId: String?
    var originFrom: String?
    
    var stayHouseTraceType: HouseType?
    
    var contactPhone: BehaviorRelay<FHHouseDetailContact?> = BehaviorRelay<FHHouseDetailContact?>(value: nil)
    
    weak var navVC: UINavigationController?
    
    var homePageCommonParams: TracerParams = TracerParams.momoid()
    
    var onError: ((Error) -> Void)?
    
    var onSuccess: ((RequestSuccessType) -> Void)?
    
    var isShowTop: Bool = false
    
    var isCurrentShowHome: Bool = false //判断是否停留在当前页
    
    var oneTimeToast: ((String?) -> Void)?
    
    var isFirstEnterCategory: Bool = true
    
    var isHasLoadCategory: Bool = true
    
    var isFirstEnterCategorySwitch: Bool = true
    
    var itemsDataCache: [String : [HouseItemInnerEntity]] = [:] //列表数据缓存
    
    var itemsSearchIdCache: [String : String] = [:] //searchid缓存
    
    var isItemsHasMoreCache: [String : Bool] = [:] //has more缓存
    
    var itemsTraceCache: [String : [IndexPath]] = [:] //埋点上报缓存
    
    var isNeedUpdateSpringBoard: Bool = true //是否需要更新Board入口，防止重新加载
    
    var reloadFromType: TTReloadType?
    
    var stayTimeParams: TracerParams = TracerParams.momoid()
    
    var enterType: String?
    
    fileprivate var pageFrameObv: NSKeyValueObservation?
    
    var refreshTip : String?
    
    var showTips:((String) -> Void)?
    
    var listDataRequestDisposeBag = DisposeBag()
    
    var endTTUpdateCallBack: (() -> Void)?
    
    init(tableView: UITableView, navVC: UINavigationController?) {
        
        self.navVC = navVC
        self.tableView = tableView
        let cellFactory = getHouseDetailCellFactory()
        self.cellFactory = cellFactory
        cellFactory.register(tableView: tableView)
        
        tableView.register(FHHomeHeaderTableViewCell.self, forCellReuseIdentifier: "FHHomeHeaderTableViewCell")
        
        let datas = self.generateDefaultSection()
        self.dataSource = FHFunctionListDataSourceDelegate(tableView: tableView,datasV:datas)
        
        self.dataSource?.recordIndexChangedCallBack = { [weak self] in
            self?.itemsTraceCache[matchHouseTypeName(houseTypeV: self?.dataSource?.categoryView.houseTypeRelay.value)] = self?.dataSource?.recordIndexCache
        }
        
        tableView.rx.didScroll
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self, weak tableView] void in
                self?.traceDisplayCell(tableView: tableView, datas: self?.dataSource?.datas ?? [])
            }.disposed(by: disposeBag)
        
        //订阅切换二手房新房操作结果，切换城市默认操作第一个
        if let houseType = self.dataSource?.categoryView.houseTypeRelay
        {
            houseType.skip(1).subscribe(onNext:{ [weak self] (index) in
                
                if let enterTypeValue = TTCategoryStayTrackManager.share().enterType
                {
                    self?.enterType = enterTypeValue.count > 0 ? TTCategoryStayTrackManager.share().enterType : "switch"
                }else
                {
                    self?.enterType = "switch"
                }
                
                self?.tableView?.hasMore = self?.getHasMore() ?? true
                
                self?.dataSource?.recordIndexCache = self?.itemsTraceCache[matchHouseTypeName(houseTypeV: index)] ?? []
                
                let origin_from = houseTypeString(houseType.value)
                
                self?.originSearchId = self?.itemsSearchIdCache[matchHouseTypeName(houseTypeV: index)]
                
                EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                    toTracerParams(self?.originSearchId ?? "be_null", key: "origin_search_id")
                
                self?.originFrom = origin_from
                EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                    toTracerParams(origin_from, key: "origin_from")
                if EnvContext.shared.client.reachability.connection == .none
                {
                    EnvContext.shared.toast.showToast("网络异常")
                    return
                }
                
                let itemsCountV = self?.itemsDataCache[matchHouseTypeName(houseTypeV: index)]?.count ?? 0
                if itemsCountV == 0
                {
                    self?.showDefaultLoadTable()
                    
                    self?.dataSource?.categoryView.segmentedControl.touchEnabled = false
                    //如果没有数据缓存，则去请求第一页 （新房）
                    self?.requestData(houseId: -1, logPB:nil, showLoading: true)
                }
                self?.reloadDataChange(dataType: index)
                
            }).disposed(by: self.disposeBagHouse)
        }
        
        // 下拉刷新，修改tabbar条和请求数据
        tableView.tt_addDefaultPullDownRefresh { [weak self] in
            self?.resetHomeRecommendState()
            
            self?.itemsSearchIdCache.removeAll()
            
            self?.requestHomeRecommendData(pullType: .pullDownType, reloadFromType: self?.reloadFromType) // 下拉刷新
        }
        
        // 上拉刷新，请求上拉接口数据
        tableView.hasMore = getHasMore() //设置上拉状态
        tableView.tt_addDefaultPullUpLoadMore{
            [weak self] in
            self?.requestHomeRecommendData(pullType: .pullUpType, reloadFromType: self?.reloadFromType) // 上拉刷新
        }
        
        //城市切换，去除数据缓存
        EnvContext.shared.client.generalBizconfig.currentSelectCityId.skip(1)
            .filter({ $0 != nil })
            .bind { [unowned self] (_) in
                //切换城市默认触发信号
                self.resetHomeRecommendState()
                
                self.itemsSearchIdCache.removeAll()

                self.tableView?.setContentOffset(CGPoint.zero, animated: false)
                if EnvContext.shared.client.reachability.connection == .none
                {
                    self.onSuccess?(.requestSuccessTypeInvalidNetWork)
                }
                
            }.disposed(by: disposeBag)
        
        //判断是否展示tabbar 到顶
        tableView.rx.contentOffset.asObservable().subscribe(onNext: { [unowned self] (contentOffset) in
            
            if let bottom = self.dataSource?.categoryView.bottom, contentOffset.y > bottom {
                self.isShowTop = true
            }else {
                self.isShowTop = false
            }
            reloadHomeTabBarItem(self.isShowTop)
            
        })
            .disposed(by: disposeBag)
    }
    
    func homeViewControllerWillAppear()
    {
        let categoryStartName = SSCommonLogic.feedStartCategory()

        if categoryStartName == nil || categoryStartName == ""   {
            if categoryStartName != "f_find_house" && self.isHasLoadCategory
            {
                EnvContext.shared.client.generalBizconfig.updateConfig()
            }
            self.isHasLoadCategory = false
        }
    }
    
    func traceDisplayCell(tableView: UITableView?, datas: [TableSectionNode]) {
        
        tableView?.indexPathsForVisibleRows?.forEach({ [unowned self] (indexPath) in
            if let recordIndexCache = self.dataSource?.recordIndexCache, !recordIndexCache.contains(indexPath) {
                if let tracer = datas[indexPath.section].tracer {
                    self.dataSource?.callTracer(
                        tracer: tracer,
                        atIndexPath: indexPath,
                        traceParams: TracerParams.momoid())
                }
                self.dataSource?.recordIndexCache.append(indexPath)
                self.itemsTraceCache[matchHouseTypeName(houseTypeV: self.dataSource?.categoryView.houseTypeRelay.value)] = self.dataSource?.recordIndexCache
            }
        })
        
    }
    
    func showDefaultLoadTable()
    {
        self.dataSource?.datas = self.generateDefaultSection()
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    func getShareItem() -> ShareItem {
        return ShareItem(title: "", desc: "", webPageUrl: "", thumbImage: #imageLiteral(resourceName: "icon-bus"), shareType: TTShareType.webPage, groupId: "")
    }
    
    func reloadDataChange(dataType: HouseType?)
    {
        if let dataItems = itemsDataCache[matchHouseTypeName(houseTypeV: dataType)]
        {
            isNeedUpdateSpringBoard = false //纯切换推荐数据源，不需要更新board
            let datas = generateSectionNode(items: dataItems)
            if let dataSource = self.dataSource {
                dataSource.datas = datas
                UIView.performWithoutAnimation { [unowned self] in
                    self.tableView?.reloadData()
                }
            }
            
            if !self.isFirstEnterCategory
            {
                self.uploadTracker(isWithStayTime: true, stayTime: self.stayTimeParams, enterType:"switch",isStay: true, currentHouseType: self.stayHouseTraceType ?? .neighborhood)
            }
            
            if let dataTypeV = dataType
            {
                let origin_from = houseTypeString(dataTypeV)
                
                self.originFrom = origin_from
                EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                    toTracerParams(origin_from, key: "origin_from")
                
                self.stayTimeParams = TracerParams.momoid() <|> traceStayTime()
                self.uploadTracker(enterType: "switch")
                self.tableView?.finishPullDown(withSuccess: true)
            }
        }
    }
    
    func getHasMore() -> Bool {
        if let houseTypeV = self.dataSource?.categoryView.houseTypeRelay.value
        {
            return self.isItemsHasMoreCache[matchHouseTypeName(houseTypeV: houseTypeV)] ?? false
        }
        return false
    }
    //重置数据
    func resetHomeRecommendState()
    {
        self.isNeedUpdateSpringBoard = true
        self.itemsDataCache.removeAll()
        self.isItemsHasMoreCache.removeAll()
    }
    
    //生成默认加载图
    func generateDefaultSection() -> [TableSectionNode]
    {
        let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
        
        let entrys = config?.opData?.items
        let dataParser = DetailDataParser.monoid()
            <- parseSpringboardNode(entrys ?? [],isNeedUpdateBoard: true, disposeBag: self.disposeBag, navVC: self.navVC)
            <- parseHousePlaceholderNode()
        return dataParser.parser([])
    }
    
    //根据列表数据生成sectionnode
    func generateSectionNode(items: [HouseItemInnerEntity]?) -> [TableSectionNode]
    {

        let homeCommonParams = EnvContext.shared.homePageParams <|>
            toTracerParams("maintab", key: "page_type") <|>
            toTracerParams("maintab_list", key: "element_type") <|>
            toTracerParams("left_pic", key: "card_type")
        
        if let dataItems = items{
            let theDataItems = dataItems.map {[weak self] (item) -> HouseItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = self?.originSearchId
                return newItem
            }
            let dataParser = DetailDataParser.monoid()
//                <- parseSpringboardNode(entrys ?? [],isNeedUpdateBoard: isNeedUpdateSpringBoard, disposeBag: self.disposeBag, navVC: self.navVC)
                <- parseFHHomeHeaderSectionNode(navVC: navVC, disposeBag: self.disposeBag){
                    
                }
                <- parseFHHomeErshouHouseListItemNode(
                    self.dataSource?.categoryView.houseTypeRelay.value == HouseType.secondHandHouse ? theDataItems : [],
                    disposeBag: self.disposeBag,
                    tracerParams: homeCommonParams <|> toTracerParams("old", key: "house_type") <|> toTracerParams("maintab", key: "enter_from") <|> toTracerParams("maintab_list", key: "element_from"),
                    navVC: self.navVC)
                <- parseFHHomeNewHouseListItemNode(self.dataSource?.categoryView.houseTypeRelay.value == HouseType.newHouse ? theDataItems : [],
                                                   disposeBag: self.disposeBag,
                                                   tracerParams: homeCommonParams <|> toTracerParams("new", key: "house_type") <|> toTracerParams("maintab", key: "enter_from") <|> toTracerParams("maintab_list", key: "element_from"),
                                                   navVC: self.navVC)
                <- parseFHHomeRentHouseListRowItemNode(self.dataSource?.categoryView.houseTypeRelay.value == HouseType.rentHouse ? theDataItems : [],
                                                       disposeBag: self.disposeBag, tracerParams: homeCommonParams <|> toTracerParams("rent", key: "house_type") <|> toTracerParams("maintab", key: "enter_from") <|> toTracerParams("maintab_list", key: "element_from"),
                                                       navVC: self.navVC)
            return dataParser.parser([])
        } else {
            return []
        }
    }
    
    //isStay 是否取反
    func uploadTracker(isWithStayTime: Bool? = false,stayTime: TracerParams? = TracerParams.momoid(),enterType: NSString? = "be_null",isStay: Bool? = false, currentHouseType: HouseType = .neighborhood)
    {
        var params : TracerParams
        let isWithStayTimeV = isWithStayTime ?? false
        if  isWithStayTimeV
        {
            if let stayTimeV = stayTime
            {
                params = TracerParams.momoid() <|>
                stayTimeV
            }else
            {
                params = TracerParams.momoid() <|>
                    traceStayTime()
            }
        }else
        {
            params = TracerParams.momoid()
        }
        
        let category_name = houseTypeString(self.dataSource?.categoryView.houseTypeRelay.value ?? .secondHandHouse)
        var stay_category_name = houseTypeString(self.stayHouseTraceType ?? .secondHandHouse)
        
        if (isStay ?? false)
        {
            if currentHouseType != .neighborhood
            {
                stay_category_name = houseTypeString(currentHouseType)
            }else
            {
                stay_category_name = "be_null"
            }
        }
        
        params = params <|>
            EnvContext.shared.homePageParams <|>
            toTracerParams(enterType ?? "be_null", key: "enter_type") <|>
            toTracerParams((isStay ?? false) ? stay_category_name : category_name, key: "category_name") <|>
            //            toTracerParams(category_name, key: "origin_from") <|>
            toTracerParams("maintab", key: "enter_from") <|>
            toTracerParams("maintab_list",key:"element_from") <|>
            toTracerParams((self.originSearchId ?? "be_null"),key:"search_id") <|>
            toTracerParams((isStay ?? false) ? stay_category_name : category_name, key: "origin_from")
        
        
        let traceDict = params.paramsGetter([:])
        //      let categoryStartName = SSCommonLogic.feedStartCategory()
        
        if isWithStayTimeV
        {
            recordEvent(key: "stay_category", params: traceDict)
        }else
        {
            recordEvent(key: "enter_category", params: traceDict)
        }
        
        self.stayHouseTraceType = self.dataSource?.categoryView.houseTypeRelay.value
    }
    
    //第一次请求，继承协议方法
    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool) {
        
        listDataRequestDisposeBag = DisposeBag()
        
        self.houseId = houseId
        // 无网络时，仍然继续发起请求，等待网络恢复后，自动刷新首页。
        var cityId = 122
        if let cityIdV = EnvContext.shared.client.generalBizconfig.currentSelectCityId.value
        {
            cityId = cityIdV
        }
        
        if let typeValue = self.dataSource?.categoryView.houseTypeRelay.value
        {
            
            requestHouseRecommend(cityId: cityId,
                                  horseType: typeValue.rawValue,
                                  offset: 0,
                                  searchId: nil,
                                  count: 20)
                
                // TODO: 重试逻辑
                .map { [unowned self] response -> [TableSectionNode] in
                    
                    if let data = response?.data {
                        
                        self.originSearchId = data.searchId
                        self.refreshTip = data.refreshTip
                        
                        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                        
                    }else
                    {
                        self.onSuccess?(.requestSuccessTypeDataError)
                    }
                    
                    if let items = response?.data?.items {
                        
                        self.onSuccess?(items.count > 0 ? .requestSuccessTypeNormal : .requestSuccessTypeNoData)
                        
                        if items.count == 0
                        {
                            return self.generateDefaultSection()
                        }
                        
                        if let houseTypeValue = self.dataSource?.categoryView.houseTypeRelay.value
                        {
                            let houstTypeKey = matchHouseTypeName(houseTypeV: houseTypeValue)
                            
                            self.itemsDataCache[houstTypeKey]?.removeAll()
                            
                            self.itemsDataCache.updateValue(items, forKey: houstTypeKey)
                            
                            self.itemsSearchIdCache.updateValue(response?.data?.searchId ?? "", forKey: houstTypeKey)
                            
                            if let hasMore = response?.data?.hasMore
                            {
                                self.isItemsHasMoreCache.updateValue(hasMore, forKey: houstTypeKey)
                            }
                            
                            return self.generateSectionNode(items: self.itemsDataCache[houstTypeKey])
                        }
                    }
                    return [] //条件不符合返回空数组
                }
                .subscribe(onNext: { [unowned self] response in
                    if let dataSource = self.dataSource, response.count != 0 {
                        self.onSuccess?(.requestSuccessTypeNormal)
                        dataSource.datas = response
                        dataSource.recordIndexCache = []
                        self.tableView?.reloadData()
                    }else
                    {
                        self.onSuccess?(.requestSuccessTypeNoData)
                    }
                    self.tableView?.hasMore = self.getHasMore() //根据请求返回结果设置上拉状态
                    self.dataSource?.categoryView.segmentedControl.touchEnabled = true
                    self.tableView?.isHidden = false
                    self.endTTUpdateCallBack?()
                    if !self.isFirstEnterCategory
                    {
                        let enterTypeV = TTCategoryStayTrackManager.share().enterType ?? "switch"
                        self.uploadTracker(isWithStayTime: true, stayTime: self.stayTimeParams, enterType:enterTypeV as NSString, isStay: true,currentHouseType: self.stayHouseTraceType ?? .neighborhood)
                    }
                    
                    let origin_from = houseTypeString(typeValue)
                    
                    self.originFrom = origin_from
                    EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                        toTracerParams(origin_from, key: "origin_from")
                    
                    self.isFirstEnterCategorySwitch ? self.uploadTracker(enterType:((TTCategoryStayTrackManager.share().enterType ?? "be_null") as NSString)) : self.uploadTracker(enterType:"switch")
                    
                    self.stayTimeParams = TracerParams.momoid() <|> traceStayTime()
                    self.isFirstEnterCategory = false
                    self.isFirstEnterCategorySwitch = false
                    
                    self.tableView?.finishPullUp(withSuccess: true)
                    self.tableView?.finishPullDown(withSuccess: true)
                    
                    }, onError: { [unowned self] error in
                        //                        print(error)
                        self.dataSource?.categoryView.segmentedControl.touchEnabled = true
                        self.onError?(error)
                        
                        self.tableView?.finishPullUp(withSuccess: false)
                        self.tableView?.finishPullDown(withSuccess: false)
                        
                    }, onCompleted: {
                        
                }, onDisposed: {
                    [unowned self] in
                    self.tableView?.finishPullUp(withSuccess: true)
                    self.tableView?.finishPullDown(withSuccess: true)
                })
                .disposed(by: listDataRequestDisposeBag)
        }
        
    }
    
    func requestHomeRecommendData(pullType: PullTriggerType, reloadFromType: TTReloadType?) {
        listDataRequestDisposeBag = DisposeBag()
        oneTimeToast = createOneTimeToast()
        
        self.dataSource?.categoryView.segmentedControl.touchEnabled = true
        
        
        // 无网络时，仍然继续发起请求，等待网络恢复后，自动刷新首页。
        let cityId = EnvContext.shared.client.generalBizconfig.currentSelectCityId.value
        
        
        //区分上拉还是下拉请求，如果是下拉刷新，立刻完成上拉状态
        if pullType == .pullDownType
        {
            self.tableView?.finishPullUp(withSuccess: true)
        }
        
        if let typeValue = self.dataSource?.categoryView.houseTypeRelay.value
        {
            
            let requestId = self.itemsSearchIdCache[matchHouseTypeName(houseTypeV: typeValue)] ?? ""
            
            let offsetRequest = self.itemsDataCache[matchHouseTypeName(houseTypeV: typeValue)]?.count ?? 0
            
            requestHouseRecommend(cityId: cityId ?? 122,
                                  horseType: typeValue.rawValue,
                                  offset: offsetRequest,
                                  searchId: requestId,
                                  count: (houseId == -1 ? 20 : 20))
                
                // TODO: 重试逻辑
                .map { [unowned self] response -> [TableSectionNode] in
                    
                    if let data = response?.data {
                        
                        self.originSearchId = data.searchId
                        self.refreshTip = data.refreshTip
                        
                        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")
                        
                        var pullString: String = "be_null"
                        if pullType == .pullDownType {
                            
//                            self.oneTimeToast?(response?.data?.refreshTip)
                            pullString = "pull"
                            
                        }else if pullType == .pullUpType {
                            pullString = "pre_load_more"
                            
                        }
                        var categoryName: String?
                        if let houseTypeValue = self.dataSource?.categoryView.houseTypeRelay.value {
                            categoryName = houseTypeString(houseTypeValue)
                        }
                        let refreshType = reloadFromType != nil ? refreshTypeByReloadType(reloadType: reloadFromType!) : pullString
                        let enterType = self.enterType != nil ? self.enterType! : TTCategoryStayTrackManager.share().enterType
                        
                        let params = EnvContext.shared.homePageParams <|>
                            toTracerParams(categoryName ?? "be_null", key: "category_name") <|>
                            toTracerParams("maintab", key: "enter_from") <|>
                            toTracerParams(enterType ?? "be_null", key: "enter_type") <|>
                            toTracerParams("maintab_list", key: "element_from") <|>
                            toTracerParams(data.searchId ?? "be_null", key: "search_id") <|>
                            toTracerParams(refreshType, key: "refresh_type")
                        
                        recordEvent(key: TraceEventName.category_refresh, params: params)
                        self.reloadFromType = nil
                    }
                    
                    if let items = response?.data?.items {
                        if let houseTypeValue = self.dataSource?.categoryView.houseTypeRelay.value
                        {
                            
                            let houstTypeKey = matchHouseTypeName(houseTypeV: houseTypeValue)
                            
                            if items.count > 0
                            {
                                var currentItems = self.itemsDataCache[houstTypeKey] ?? []
                                
                                currentItems.append(contentsOf: items)
                                
                                self.itemsDataCache.updateValue(currentItems, forKey: houstTypeKey)
                            }
                            
                            self.itemsSearchIdCache.updateValue(response?.data?.searchId ?? "", forKey: houstTypeKey)
                            
                            if let hasMore = response?.data?.hasMore
                            {
                                self.isItemsHasMoreCache.updateValue(hasMore, forKey: houstTypeKey)
                            }
                            
                            return self.generateSectionNode(items: self.itemsDataCache[houstTypeKey])
                        }
                    }
                    return [] //条件不符合返回空数组
                }
                .subscribe(
                    onNext: { [unowned self] response in
                        
                        //区分上拉还是下拉请求，如果是上拉刷新，完成上拉状态
                        if pullType == .pullUpType
                        {
                            self.tableView?.finishPullUp(withSuccess: true)
                            self.tableView?.finishPullDown(withSuccess: true)
                        }else
                        {
                            self.tableView?.finishPullDown(withSuccess: true)
                            self.showTips?(self.refreshTip ?? "")
                        }
                        
                        if let dataSource = self.dataSource, response.count != 0 {
                            self.onSuccess?(.requestSuccessTypeNormal)
                            dataSource.datas = response
                            if pullType == .pullDownType
                            {
                                dataSource.recordIndexCache = []
                            }
                            self.tableView?.reloadData()
                        }
                        self.tableView?.hasMore = self.getHasMore() //根据请求返回结果设置上拉状态
                    },
                    onError: { [unowned self] error in
                        
                        pullType == .pullUpType ? self.tableView?.finishPullUp(withSuccess: false) :self.tableView?.finishPullDown(withSuccess: false)
                        
                        if EnvContext.shared.client.reachability.connection == .none
                        {
                            EnvContext.shared.toast.showToast("网络异常")
                        }else
                        {
                            EnvContext.shared.toast.showToast("请求失败,请检查网络后重试")
                        }
                    },
                    onCompleted: {
                        
                },
                    onDisposed: {
                        
                })
                .disposed(by: listDataRequestDisposeBag)
        }
    }
    
    func createOneTimeToast() -> (String?) -> Void {
        var hasToast = false
        return { (message) in
            EnvContext.shared.toast.dismissToast()
            if !hasToast, let message = message {
                if self.isCurrentShowHome
                {
                    EnvContext.shared.toast.showToast(message)
                    hasToast = true
                }
            }
        }
    }
    
    func followThisItem(isNeedRecord: Bool, traceParam: TracerParams) {
        followIt(
            houseType: .newHouse,
            followAction: .newHouse,
            followId: "\(houseId)",
            disposeBag: disposeBag,
            isNeedRecord: isNeedRecord)()
        self.recordFollowEvent(traceParam)
        
    }

    func isDataAvailable() -> Bool {
        return true
    }
    
}

func parseFHHomeHeaderSectionNode(
    navVC: UINavigationController?,
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void) -> () -> TableSectionNode {
    return {
        var selector: ((TracerParams) -> Void)?
        var mapSelector: ((TracerParams) -> Void)?

        let cellRender = curry(fillFHHomeHeaderCell)(disposeBag)(callBack)(mapSelector)
        
        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors:  nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: "FHHomeHeaderTableViewCell"))
    }
}

func fillFHHomeHeaderCell(
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void,
    selector: ((TracerParams) -> Void)?,
    cell: UITableViewCell) -> Void {
    if let theCell = cell as? FHHomeHeaderTableViewCell {
        theCell.refreshUI(FHHomeHeaderCellPositionType.forFindHouse)
        let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
        let entrys = config?.opData?.items
        
    }
}

func parseFHHomeNewHouseListItemNode(
    _ items: [HouseItemInnerEntity]?,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    
    return {
        let selectors = items?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                return openNewHouseDetailPage(
                    houseId: Int64(item.id ?? "")!,
                    logPB: item.logPB ?? [:],
                    disposeBag: disposeBag,
                    tracerParams: tracerParams <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams("maintab", key: "enter_from") <|>
                        toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                    navVC:navVC)
        }
        
        
        let records = items?
            .filter { $0.id != nil }
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
        
        let count = items?.count ?? 0
        
        if let renders = items?.enumerated().map({(index, item) in
            items?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(true) : curry(fillHomeNewHouseListitemCell)(item)(index == count - 1)
            
        }), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: nil,
                label: "",
                type: .node(identifier:items?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
        } else {
            return nil
        }
    }
}

func paresNewHouseListRowItemNode(
    _ data: [CourtItemInnerEntity]?,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    houseSearchParams: TracerParams?,
    navVC: UINavigationController?) -> [TableRowNode] {
    let theParams = traceParams
    let selectors = data?
        .enumerated()
        .map { (e) -> (TracerParams) -> Void in
            let (offset, item) = e
            return openNewHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                logPB: item.logPB as? [String: Any],
                disposeBag: disposeBag,
                tracerParams: theParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams("new_list", key: "enter_from") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                houseSearchParams: houseSearchParams,
                navVC: navVC) }
    let params = TracerParams.momoid() <|>
        toTracerParams("new", key: "house_type") <|>
        toTracerParams("left_pic", key: "card_type")
    
    let records = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (_, item) = e
            let theParams = params <|>
                //                        toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams("new_list", key: "page_type") <|>
                beNull(key: "element_type") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb")
            return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from").exclude("enter_from"))
    }
    if let renders = data?.map( {
        
        return fillNewHouseListitemCell($0)
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
        
    }
    return []
}

func fillNewHouseListitemCell(_ data: CourtItemInnerEntity,
                              isLastCell: Bool = false) -> ((BaseUITableViewCell) -> Void) {
    
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
    
    
    return { cell in
        
        if let theCell = cell as? SingleImageInfoCell {
            theCell.majorTitle.text = data.displayTitle
            theCell.extendTitle.text = data.displayDescription
            
            theCell.areaLabel.attributedText = text
            theCell.areaLabel.snp.updateConstraints { (maker) in
                
                maker.left.equalToSuperview().offset(-3)
            }
            
            theCell.isTail = isLastCell
            
            theCell.priceLabel.text = data.displayPricePerSqm
            theCell.roomSpaceLabel.text = ""
            theCell.majorImageView.bd_setImage(with: URL(string: data.courtImage?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
            theCell.updateOriginPriceLabelConstraints(originPriceText: nil)
            theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
        }
        
    }
}

func fillHomeNewHouseListitemCell(_ data: HouseItemInnerEntity, isLastCell: Bool = false) -> ((BaseUITableViewCell) -> Void) {
    
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
    
    
    return { cell in
        
        if let theCell = cell as? SingleImageInfoCell {
            theCell.majorTitle.text = data.displayTitle
            theCell.extendTitle.text = data.displayDescription
            theCell.areaLabel.attributedText = text
            theCell.areaLabel.snp.updateConstraints { (maker) in
                
                maker.left.equalToSuperview().offset(-3)
            }
            
            theCell.isTail = isLastCell
            
            theCell.priceLabel.text = data.displayPricePerSqm
            theCell.roomSpaceLabel.text = ""
            theCell.majorImageView.bd_setImage(with: URL(string: data.images?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
            theCell.updateOriginPriceLabelConstraints(originPriceText: nil)
            theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
        }
    }
}

func openNewHouseDetailPage(
    houseId: Int64,
    logPB: [String: Any]?,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    houseSearchParams: TracerParams? = nil,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    return { (theTracerParams) in
        let detailPage = HorseDetailPageVC(
            houseId: houseId,
            houseType: .newHouse,
            isShowBottomBar: true)
        detailPage.logPB = logPB
        detailPage.traceParams = EnvContext.shared.homePageParams <|>
            theTracerParams <|>
            tracerParams <|>
            toTracerParams("left_pic", key: "card_type")
        detailPage.houseSearchParams = houseSearchParams
        
        let mainEntrance = tracerParams.paramsGetter([:])["maintab_entrance"]
        if let mainEntrance = mainEntrance {
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams(mainEntrance, key: "origin_from")
            
        }
        
        detailPage.pageViewModelProvider = { [unowned detailPage] (tableView, infoMaskView, navVC, searchId) in
            let viewModel = getNewHouseDetailPageViewModel(
                detailPageVC: detailPage,
                infoMaskView: infoMaskView,
                navVC: navVC,
                tableView: tableView)
            viewModel.searchId = searchId
            return viewModel
        }
        
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}

func openNeighborhoodDetailPage(
    neighborhoodId: Int64,
    logPB: [String: Any]?,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>? = nil,
    houseSearchParams: TracerParams? = nil,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    return { (theParams) in
        let detailPage = HorseDetailPageVC(
            houseId: neighborhoodId,
            houseType: .neighborhood,
            isShowFollowNavBtn: true,
            provider: getNeighborhoodDetailPageViewModel())
        detailPage.logPB = logPB
        detailPage.houseSearchParams = houseSearchParams
        
        if let sameNeighborhoodFollowUp = sameNeighborhoodFollowUp {
            detailPage.sameNeighborhoodFollowUp.bind(to: sameNeighborhoodFollowUp).disposed(by: disposeBag)
        }
        detailPage.traceParams = EnvContext.shared.homePageParams <|>
            tracerParams <|>
        theParams
        
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}

func parseFHHomeRentHouseListRowItemNode(
    _ items: [HouseItemInnerEntity]?,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    
    return {
        let selectors = items?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                
                return { (params) in
                    if let houseId = item.id {
                        let tracer = tracerParams <|>
                            toTracerParams(offset, key: "rank") <|>
                            toTracerParams("maintab", key: "enter_from") <|>
                            toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                            toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                            toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                        let userInfo = TTRouteUserInfo(info: ["tracer": tracer.paramsGetter([:])])
                        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(houseId)"), userInfo: userInfo)
                    }
                }
        }
        
        
        let records = items?
            .filter { $0.id != nil }
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
        
        let count = items?.count ?? 0
        
        if let renders = items?.enumerated().map({(index, item) in
            items?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(true) : curry(fillFHHomeRentHouseListitemCell)(item)(index == count - 1)
            
        }), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records, sectionTracer: nil,
                label: "",
                type: .node(identifier:items?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
        } else {
            return nil
        }
    }
}

func fillFHHomeRentHouseListitemCell(_ data: HouseItemInnerEntity, isLastCell: Bool = false) -> ((BaseUITableViewCell) -> Void) {
    
    let text = NSMutableAttributedString()
    let attrTexts = data.tags?.enumerated().map({ (arg) -> NSAttributedString in
        
        let (offset, item) = arg
        return createTagAttrString(
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
    
    
    return { cell in
        
        if let theCell = cell as? SingleImageInfoCell {
            
            theCell.majorTitle.text = data.title
            theCell.extendTitle.text = data.subtitle
            theCell.isTail = isLastCell
            
            let text = NSMutableAttributedString()
            let attrTexts = data.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
                return createTagAttrString(
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
            theCell.priceLabel.text = data.pricing
            theCell.roomSpaceLabel.text = nil  //data.displayPricePerSqm
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
            theCell.updateOriginPriceLabelConstraints(originPriceText: nil )
            theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
        }
        
    }

}




class FHFunctionListDataSourceDelegate: FHListDataSourceDelegate, TableViewTracer {
    
    var recordIndexCache: [IndexPath] = []
    
    var recordIndexChangedCallBack: () -> () = {}
    
    lazy var categoryView : CategorySectionView = {
        let view = CategorySectionView()
        return view
    }()
    
    override init(tableView: UITableView,datasV: [TableSectionNode]? = []) {
        super.init(tableView:tableView,datasV:datasV)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let disposeBag = DisposeBag()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (datas.count > 0) ? datas[section].items.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FHHomeHeaderTableViewCell") as? FHHomeHeaderTableViewCell ?? FHHomeHeaderTableViewCell()
            cell.refreshUI(FHHomeHeaderCellPositionType.forFindHouse)
            return cell
        }
        
        //控件展现打点
        if !recordIndexCache.contains(indexPath) {
            
            if let tracer = datas[indexPath.section].tracer {
                callTracer(
                    tracer: tracer,
                    atIndexPath: indexPath,
                    traceParams: TracerParams.momoid())
            }
            recordIndexCache.append(indexPath)
            recordIndexChangedCallBack()
        }
        
        switch datas[indexPath.section].type {
        case let .node(identifier):
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseUITableViewCell {
                datas[indexPath.section].items[indexPath.row](cell)
                return cell
            } else
            {
                return BaseUITableViewCell()
            }
        default:
            return BaseUITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
           return FHHomeCellHelper.sharedInstance().heightForFHHomeHeaderCellViewType()
        }
        
        if !tableView.fd_indexPathHeightCache.existsHeight(at: indexPath) {
            var cellModel : FHCellModel?
            
            tableView.fd_heightForCell(withIdentifier: identifierByIndexPath(indexPath), cacheBy: indexPath) { [unowned self] (cell) in
                
                if indexPath.section < self.fhSections.count {
                    let aSection = self.fhSections[indexPath.section]
                    if indexPath.row < aSection.count {
                        cellModel = aSection[indexPath.row]
                    }
                }
                
                if let cell = cell as? UITableViewCell {
                    self.fillCellData(cell: cell, indexPath: indexPath, model: cellModel)
                } else {
                    assertionFailure()
                }
            }
        }
        return tableView.fd_indexPathHeightCache.height(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid() <|> toTracerParams(indexPath.row, key: "rank"))
    }
    
    override func fillCellData(cell: UITableViewCell, indexPath: IndexPath, model: Any?) {
        if let cell = cell as? BaseUITableViewCell {
            datas[indexPath.section].items[indexPath.row](cell)
        }else if let cell = cell as? FHHomeHeaderTableViewCell
        {
            cell.refreshUI(FHHomeHeaderCellPositionType.forFindHouse)
        }
    }
    
    override func identifierByIndexPath(_ indexPath: IndexPath) -> String {
        if datas.count > indexPath.section {
            switch datas[indexPath.section].type {
            case let .node(identifier):
                return identifier
            default:
                return FHDefaultCellID
            }
        } else {
            return FHDefaultCellID
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if datas.count == 0 || section != 1 {
            return nil
        } else {
            return categoryView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if datas.count == 0 || section != 1 {
            return 0
        } else {
            return 35
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
}
func reloadHomeTabBarItem(_ isBackTop: Bool) {
    
    guard let tabBarItem = TTTabBarManager.shared().tabItem(withIdentifier: kTTTabHomeTabKey) else {
        return
    }
    if isBackTop {
        tabBarItem.setTitle("回到顶部")
        tabBarItem.setNormalImage(UIImage(named: "tab-home"), highlightedImage: UIImage(named: "ic-tab-return-normal"), loading: UIImage(named: "tab-home_press"))
    }else {
        tabBarItem.setTitle("首页")
        tabBarItem.setNormalImage(UIImage(named: "tab-home"), highlightedImage: UIImage(named: "tab-home_press"), loading: UIImage(named: "tab-home_press"))
    }
    
}
fileprivate func homeListTypeBySection(_ section: Int) -> String? {
    switch section {
    case 2:
        return "maintab_old_list"
    case 4:
        return "maintab_new_list"
    default:
        return nil
    }
}

fileprivate func refreshTypeByReloadType(reloadType: TTReloadType) -> String {
    switch reloadType {
    case TTReloadTypePreLoadMore:
        return "pre_load_more"
    case TTReloadTypeTab,TTReloadTypeTabWithTip:
        return "tab"
    case TTReloadTypeClickCategory, TTReloadTypeClickCategoryWithTip:
        return "click"
    case TTReloadTypePull:
        return "pull"
    default:
        return "be_null"
    }
    
}
