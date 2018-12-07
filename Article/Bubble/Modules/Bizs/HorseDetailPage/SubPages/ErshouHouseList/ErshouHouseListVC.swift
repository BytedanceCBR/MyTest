//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
import Reachability
class ErshouHouseListVC: BaseSubPageViewController, PageableVC, TTRouteInitializeProtocol, UIViewControllerErrorHandler{

    var hasMore = true

    let neighborhoodId: String

    let houseId: String?

    var ershouHouseListViewModel: ErshouHouseListViewModel?

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var conditionPanelView: UIControl = {
        let result = UIControl()
        result.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.3)
        return result
    }()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?
    
    var errorVM:NHErrorViewModel?

    let theHouseType = BehaviorRelay<HouseType>(value: .secondHandHouse)
    
    let searchSource: SearchSourceKey

    let titleName = BehaviorRelay<String>(value: "小区房源")

    var searchId: String?
    
    fileprivate var userInteractionObv: NSKeyValueObservation?
    
    var sameNeighborhoodFollowUp = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var followStatus: BehaviorRelay<Result<Bool>>? = nil
    
    var relatedHouse = false
    
    init(title: String?,
         neighborhoodId: String,
         houseId: String? = nil,
         searchSource: SearchSourceKey,
         searchId: String? = nil,
         houseType: HouseType = HouseType.secondHandHouse ,
         relatedHouse: Bool = false ,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        self.houseId = houseId
        self.searchSource = searchSource
        self.searchId = searchId
        self.theHouseType.accept(houseType)
        self.relatedHouse = relatedHouse
        super.init(identifier: neighborhoodId, isHiddenBottomBar: true, bottomBarBinder: bottomBarBinder)
        self.titleName.accept(title ?? "小区房源")
    }
    
    required convenience init(routeParamObj paramObj: TTRouteParamObj?) {
        let title = (paramObj?.userInfo.allInfo["title"] as? String) ?? ""
        let houseId = (paramObj?.userInfo.allInfo["houseId"] as? String) ?? ""
        let searchId = (paramObj?.userInfo.allInfo["searchId"] as? String) ?? ""
        let searchSource = SearchSourceKey(rawValue: ((paramObj?.userInfo.allInfo["searchSource"] as? String) ?? "")) ?? .neighborhoodDetail
        let neighborhoodId = (paramObj?.userInfo.allInfo["neighborhoodId"] as? String) ?? ""
        let bottomBarBinder = paramObj?.userInfo.allInfo["bottomBarBinder"] as! FollowUpBottomBarBinder
        let traceParam = (paramObj?.userInfo.allInfo["tracerParams"] as? TracerParams) ?? TracerParams.momoid()
        var followStatus: BehaviorRelay<Result<Bool>>? = nil
        followStatus = paramObj?.userInfo.allInfo["followStatus"] as? BehaviorRelay<Result<Bool>>
        
        var houseTypeValue = HouseType.secondHandHouse
        
        if let hType = paramObj?.userInfo.allInfo["house_type"] as? Int {
            if let ht = HouseType(rawValue: hType) {
                houseTypeValue = ht
            }
        }
        
        let relatedHouse = (paramObj?.userInfo.allInfo["related_house"] as? Bool) ?? false

        self.init(title: title, neighborhoodId: neighborhoodId, houseId: houseId, searchSource: searchSource, searchId: searchId, houseType: houseTypeValue , relatedHouse: relatedHouse , bottomBarBinder: bottomBarBinder)
        self.tracerParams = traceParam
        self.followStatus = followStatus
    }


    override func viewDidLoad() {
        
        userInteractionObv = self.view.observe(\.isUserInteractionEnabled, options: [.new]) { [weak self] (view, value) in
            if let _ = value.newValue {
                self?.view.endEditing(true)
            }
        }
        
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.ttHideNavigationBar = true
        //隐藏关注按钮
        self.navBar.rightBtn2.isHidden = true
        // 适配ios8上滑动滚动跳跃
        if #available(iOS 11.0, *) {
            self.tableView.estimatedRowHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
            self.tableView.estimatedSectionFooterHeight = 0
        }
        ershouHouseListViewModel = ErshouHouseListViewModel(tableView: tableView, navVC: self.navigationController)
        ershouHouseListViewModel?.sameNeighborhoodFollowUp = self.sameNeighborhoodFollowUp
        ershouHouseListViewModel?.searchId = searchId
        ershouHouseListViewModel?.traceParams = self.tracerParams
        
        ershouHouseListViewModel?.datas
            .skip(1)
            .map { $0.count < 1 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
       
        if let fs = self.followStatus {
            self.sameNeighborhoodFollowUp.accept(fs.value)
            self.sameNeighborhoodFollowUp
                .bind(to: fs)
                .disposed(by: disposeBag)
        }
        
        ershouHouseListViewModel?.onDataLoaded = self.onDataLoaded()
        self.navBar.title.text = self.titleName.value
        
        ershouHouseListViewModel?.onSuccess = {
            [weak self] (result) in
            switch result {
            case .Success:
                self?.errorVM?.onRequestNormalData()
            case .NoData:
                self?.errorVM?.onRequestNilData()
            case .BadData:
                self?.errorVM?.onRequestError(error: nil)
            }
            self?.tt_endUpdataData()
        }

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        
        self.conditionFilterViewModel = ConditionFilterViewModel(
                conditionPanelView: conditionPanelView,
                searchFilterPanel: searchFilterPanel,
                searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        self.navBar.seperatorLine.isHidden = true
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        navBar.backBtn.rx.tap.subscribe({[weak self] void in
            self?.navigationController?.popViewController(animated: true)
        })
            .disposed(by: disposeBag)
        
        view.addSubview(searchFilterPanel)
        searchFilterPanel.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(44)
        }
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.bottom.equalToSuperview()
        }
       
        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        conditionPanelView.isHidden = true

        Observable
                .zip(theHouseType, EnvContext.shared.client.configCacheSubject)
                .filter { (e) in
                    let (_, config) = e
                    return config != nil
                }
                .map { (e) -> ([SearchConfigFilterItem]?) in
                    let (type, config) = e
                    var theConfig: [SearchConfigFilterItem]? = nil
                    switch type {
                    case HouseType.newHouse:
                        theConfig = config?.courtFilter
                    case HouseType.secondHandHouse:
                        theConfig = config?.filter
                    case HouseType.neighborhood:
                        theConfig = config?.neighborhoodFilter
                    case HouseType.rentHouse:
                        theConfig = config?.rentFilter
                    default:
                        theConfig = config?.filter
                    }
                    return theConfig?.filter { $0.text != "区域" }
                }
                .map { items in
                    let result: [SearchConditionItem] = items?
                            .map(transferSearchConfigFilterItemTo) ?? []
                    let panelData: [[Node]] = items?.map {
                        if let options = $0.options {
                            return transferSearchConfigOptionToNode(
                                    options: options,
                                    rate: $0.rate,
                                    isSupportMulti: $0.supportMulti)
                        } else {
                            return []
                        }
                    } ?? []
                    return (result, panelData)
                }
                .subscribe(onNext: { [unowned self] (items: ([SearchConditionItem], [[Node]])) in
                    let reload: () -> Void = { [weak self] in
                        self?.conditionFilterViewModel?.reloadConditionPanel()
                    }
                    zip(items.0, items.1).enumerated().forEach({ (e) in
                        let (offset, (item, nodes)) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(
                            index: offset,
                            reload: reload,
                            item: item,
                            data: nodes)
                    })
                    self.conditionFilterViewModel?.filterConditions = items.0
                    self.conditionFilterViewModel?.reloadConditionPanel()
                })
                .disposed(by: disposeBag)

        searchAndConditionFilterVM.queryCondition
            .skip(1)
            .map { [unowned self] (result) -> String in
                
                if self.relatedHouse {
                    return "house_type=\(self.theHouseType.value.rawValue)"+result
                }else{
                    return "exclude_id[]=\(self.houseId ?? "")&exclude_id[]=\(self.neighborhoodId)&neighborhood_id=\(self.neighborhoodId)&house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" + result
                }
            }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    if EnvContext.shared.client.reachability.connection == .none
                    {
                        EnvContext.shared.toast.showToast("网络异常")
                        return
                    }
                    self.errorVM?.onRequest()
                    if self.relatedHouse {
                        
                        self.ershouHouseListViewModel?.requestRelatedHouseList(query: query, houseId: self.houseId ?? "", condition: nil)
                        
                    } else {
                        
                        if self.theHouseType.value == HouseType.rentHouse {
                            self.ershouHouseListViewModel?.requestRentHouseList(query: query, condition: nil)
                        }else{
                            self.ershouHouseListViewModel?.requestErshouHouseList(query: query, condition: nil)
                        }
                    }
                }, onError: { error in
//                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)
        
        //第一次进入请求数据
        if self.ershouHouseListViewModel?.datas.value.count == 0 {
            self.tt_startUpdate()
            self.requestData()
        }
        self.tracerParams = tracerParams <|>
            toTracerParams(searchId ?? "be_null", key: "search_id")
//        self.searchAndConditionFilterVM.sendSearchRequest()
        if relatedHouse {
            self.tracerParams = self.tracerParams <|>
            toTracerParams("related_list", key: "category_name")
        }
        let enterCategoryParams = tracerParams
            .exclude("card_type")
            .exclude("element_type")
            .exclude("search_id")
            .exclude("group_id")
            .exclude("page_type")
            .exclude("rank")

        stayTimeParams = enterCategoryParams.exclude("card_type") <|> traceStayTime()

        // 进入列表页埋点
        recordEvent(key: TraceEventName.enter_category, params: enterCategoryParams)
        setupErrorDisplay()
        self.errorVM?.onRequestViewDidLoad()
        self.errorVM?.onRequest()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.bringSubview(toFront: conditionPanelView)
        self.view.bringSubview(toFront: searchFilterPanel)

    }

    private func setupErrorDisplay() {
        //增加error页
        self.errorVM = NHErrorViewModel(errorMask:infoMaskView,requestRetryText:"网络异常",requestRetryImage:"group-4",requestNilDataText:"没有找到相关的信息，换个条件试试吧~",requestNilDataImage:"group-9",requestErrorText:"数据走丢了",requestErrorImage:"group-8")
        infoMaskView.isHidden = true
        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }
    }

    fileprivate func requestData() {
        errorVM?.onRequest()
//        ershouHouseListViewModel?.requestErshouHouseList(
//            query: "exclude_id[]=\(houseId ?? "")&exclude_id[]=\(neighborhoodId)&neighborhood_id=\(neighborhoodId)&house_id=\(houseId ?? "")&house_type=\(HouseType.secondHandHouse.rawValue)&search_source=\(searchSource.rawValue)",
//            condition: nil)
        if self.relatedHouse {
            ershouHouseListViewModel?.requestRelatedHouse(houseId: houseId ?? "")
        }else{
            if self.theHouseType.value == HouseType.rentHouse {
                ershouHouseListViewModel?.requestRent(neightborhoodId: neighborhoodId, houseId: houseId ?? "")
            }else{
                ershouHouseListViewModel?.request(neightborhoodId: neighborhoodId, houseId: houseId ?? "")
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let stayTimeParams = stayTimeParams {
            
            let params = stayTimeParams <|>
                toTracerParams(self.ershouHouseListViewModel?.searchId ?? "be_null", key: "search_id")
            
            recordEvent(key: TraceEventName.stay_category, params: params)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        self.errorVM?.onRequestRefreshData()
        
        let sid = self.ershouHouseListViewModel?.searchId
        
        let refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type") <|>
                toTracerParams(sid ?? "be_null", key: "search_id")
        let finalRefreshParams = refreshParams
            .exclude("card_type")
            .exclude("element_type")
            .exclude("search_id")
            .exclude("group_id")
            .exclude("page_type")
            .exclude("rank")
        recordEvent(key: TraceEventName.category_refresh, params: finalRefreshParams)
        errorVM?.onRequest()
        ershouHouseListViewModel?.pageableLoader?()
    }

    func tt_hasValidateData() -> Bool {
        return self.ershouHouseListViewModel?.datas.value.count ?? 0 > 0
    }

    
}
