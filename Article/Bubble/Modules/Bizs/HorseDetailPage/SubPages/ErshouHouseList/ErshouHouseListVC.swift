//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
import Reachability
class ErshouHouseListVC: BaseSubPageViewController, PageableVC {
    
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
    
    var sameNeighborhoodFollowUp = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    init(title: String?,
         neighborhoodId: String,
         houseId: String? = nil,
         searchSource: SearchSourceKey,
         searchId: String? = nil,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        self.houseId = houseId
        self.searchSource = searchSource
        self.searchId = searchId
        super.init(identifier: neighborhoodId, isHiddenBottomBar: true, bottomBarBinder: bottomBarBinder)
        self.titleName.accept(title ?? "小区房源")
    }

    override func viewDidLoad() {
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
        ershouHouseListViewModel?.datas
            .skip(1)
            .map { $0.count < 1 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
       
        
        ershouHouseListViewModel?.onDataLoaded = self.onDataLoaded()
        self.navBar.title.text = self.titleName.value
        
        ershouHouseListViewModel?.onSuccess = {
            [weak self] (isHaveData) in
            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }else
            
            {
                self?.errorVM?.onRequestNilData()
            }
        }

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        
        self.conditionFilterViewModel = ConditionFilterViewModel(
                conditionPanelView: conditionPanelView,
                searchFilterPanel: searchFilterPanel,
                searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

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
                    let (_, config) = e
                    return config?.filter?.filter { $0.text != "区域" }
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
                .map { [unowned self] (result) in
                    "exclude_id[]=\(self.houseId ?? "")&exclude_id[]=\(self.neighborhoodId)&neighborhood_id=\(self.neighborhoodId)&house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" + result
                }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    if EnvContext.shared.client.reachability.connection == .none
                    {
                        EnvContext.shared.toast.showToast("网络异常")
                        return
                    }
                    self.errorVM?.onRequest()
                    self.ershouHouseListViewModel?.requestErshouHouseList(query: query, condition: nil)
                }, onError: { error in
//                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)
        
        //第一次进入请求数据
        if self.ershouHouseListViewModel?.datas.value.count == 0 {
                        self.requestData()
        }
        self.tracerParams = tracerParams <|>
            toTracerParams(searchId ?? "be_null", key: "search_id")
//        self.searchAndConditionFilterVM.sendSearchRequest()
        stayTimeParams = tracerParams.exclude("card_type") <|> traceStayTime()

        // 进入列表页埋点
        recordEvent(key: TraceEventName.enter_category, params: tracerParams.exclude("card_type"))
        setupErrorDisplay()
        self.errorVM?.onRequestViewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.bringSubview(toFront: conditionPanelView)
        self.view.bringSubview(toFront: searchFilterPanel)

    }

    private func setupErrorDisplay() {
        //增加error页
        self.errorVM = NHErrorViewModel(errorMask:infoMaskView,requestRetryText:"网络异常",requestRetryImage:"group-4",requestNilDataText:"没有找到相关的信息，换个条件试试吧~",requestNilDataImage:"group-9")
        infoMaskView.isHidden = true
        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }
    }

    fileprivate func requestData() {
        errorVM?.onRequest()
        ershouHouseListViewModel?.requestErshouHouseList(
            query: "exclude_id[]=\(houseId ?? "")&exclude_id[]=\(neighborhoodId)&neighborhood_id=\(neighborhoodId)&house_id=\(houseId ?? "")&house_type=\(HouseType.secondHandHouse.rawValue)&search_source=\(searchSource.rawValue)",
            condition: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        self.errorVM?.onRequestRefreshData()
        let refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type")
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        errorVM?.onRequest()
        ershouHouseListViewModel?.pageableLoader?()
    }

    
}
