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

    var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let neighborhoodId: String

    let houseId: String?

    var ershouHouseListViewModel: ErshouHouseListViewModel?

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var conditionPanelView: UIControl = {
        let result = UIControl()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    let theHouseType = BehaviorRelay<HouseType>(value: .secondHandHouse)
    
    let searchSource: SearchSourceKey

    let titleName = BehaviorRelay<String>(value: "小区房源")

    init(title: String?,
         neighborhoodId: String,
         houseId: String? = nil,
         searchSource: SearchSourceKey,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        self.houseId = houseId
        self.searchSource = searchSource
        super.init(identifier: neighborhoodId, isHiddenBottomBar: true, bottomBarBinder: bottomBarBinder)
        self.titleName.accept(title ?? "小区房源")
    }

    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.ttHideNavigationBar = true
        ershouHouseListViewModel = ErshouHouseListViewModel(tableView: tableView, navVC: self.navigationController)

        ershouHouseListViewModel?.datas
            .skip(1)
            .debug()
            .map { $0.count > 0 }
            .bind(to: infoMaskView.rx.isHidden)
            .disposed(by: disposeBag)

        ershouHouseListViewModel?.onDataLoaded = self.onDataLoaded()
        Observable.combineLatest(self.titleName, ershouHouseListViewModel!.title)
                .map { $0.0 + $0.1 }
                .bind(to: self.navBar.title.rx.text)
                .disposed(by: disposeBag)

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        requestData()
        
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
            maker.height.equalTo(40)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }
        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
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
                    zip(items.0, items.1).forEach({ (e) in
                        let (item, nodes) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(reload: reload, item: item, data: nodes)
                    })
                    self.conditionFilterViewModel?.filterConditions = items.0
                    self.conditionFilterViewModel?.reloadConditionPanel()
                })
                .disposed(by: disposeBag)

        searchAndConditionFilterVM.queryCondition
                .skip(1)
                .map { [unowned self] (result) in
                    "house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" + result
                }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    self.ershouHouseListViewModel?.requestErshouHouseList(query: query, condition: nil)
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)


        // 绑定网络状态监控
        Reachability.rx.isReachable
            .debug("Reachability.rx.isReachable")
            .bind { [unowned self] reachable in
                if !reachable {
                    self.infoMaskView.label.text = "网络不给力，点击屏幕重试"
                } else {
                    if self.ershouHouseListViewModel?.datas.value.count == 0 {
                        self.requestData()
                    }
//                    self.infoMaskView.label.text = "没有找到相关的信息，换个条件试试吧~"
                }
            }
            .disposed(by: disposeBag)


//        self.searchAndConditionFilterVM.sendSearchRequest()
        stayTimeParams = tracerParams <|> traceStayTime()

        // 进入列表页埋点
        recordEvent(key: TraceEventName.enter_category, params: tracerParams)
    }

    fileprivate func requestData() {
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
        let refreshParams = self.tracerParams <|>
                toTracerParams("pre_load_more", key: "refresh_type")
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        ershouHouseListViewModel?.pageableLoader?()
    }

    
}
