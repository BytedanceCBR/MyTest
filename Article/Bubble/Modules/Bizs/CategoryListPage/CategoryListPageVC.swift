//
//  CategoryListPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/14.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Reachability

class ConditionPanelState {
    var currentIndex: Int
    var isShowPanel: Bool

    init() {
        self.currentIndex = -1
        self.isShowPanel = false
    }
}

typealias ConditionSelectAction = (Int, [Node]) -> Void

typealias ConditionPathParser = ([Node], String) -> String

typealias ConditionFilterPanelGenerator = (Int, UIView?) -> UIView?

struct ConditionAggregator {
    let aggregator: (String) -> String
}

extension ConditionAggregator {
    static func monoid() -> ConditionAggregator {
        return ConditionAggregator {
            $0
        }
    }
}

typealias FilterConditionResetter = () -> Void

fileprivate func getPlaceholderText(inputText: String?, inputField: UITextField) -> String? {
    if inputText?.isEmpty ?? true {
        return inputField.placeholder
    } else {
        return inputText
    }
}

class CategoryListPageVC: BaseViewController, TTRouteInitializeProtocol {

    let disposeBag = DisposeBag()

    var suggestionParams: String?

    var tracerParams = TracerParams.momoid()

    var stayTimeParams: TracerParams?

    lazy var navBar: CategorySearchNavBar = {
        let result = CategorySearchNavBar()
//        result.searchInput.placeholder = "请输入小区/商圈/地铁"
        result.searchTypeLabel.text = houseType.value.stringValue()
        return result
    }()

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView(frame: CGRect.zero, style: .plain)
        result.separatorStyle = .none
        if CommonUIStyle.Screen.isIphoneX {
            
            result.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        }
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()


    lazy var conditionPanelView: UIControl = {
        let result = UIControl()
        result.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.3)
        return result
    }()

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        re.icon.image = UIImage(named:"group-9")
        re.label.text = "网络异常"
        return re
    }()

    let conditionPanelState = ConditionPanelState()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    private var categoryListViewModel: CategoryListViewModel?
    
    private var errorVM : NHErrorViewModel?

    private let isOpenConditionFilter: Bool

    var queryString = ""

    var associationalWord: String?
    
    var hasMore: Bool = true
    
    var hasNone: Bool = false

    var disposeable: Disposable?

    var hasRecordEnterCategory = false

    //TTRouter 会对url参数做一次endoce，因此需要去除掉请求层的encode。
    var isNeedEncode = true

    var queryParams: [String: Any]?

    var allParams: [String: Any]?

    var searchSortBtnBG: UIView = {
        let re = UIView()
        re.lu.addBottomBorder()
        return re
    }()

    var searchSortBtn: UIButton = {
        let re = ExtendHotAreaButton()
        re.setImage(UIImage(named: "sort"), for: .normal)
        re.setImage(UIImage(named: "sort_selected"), for: .selected)
        re.setImage(UIImage(named: "sort_selected"), for: .highlighted)
        re.adjustsImageWhenHighlighted = false
        return re
    }()

    init(isOpenConditionFilter: Bool, associationalWord: String? = nil) {
        self.isOpenConditionFilter = isOpenConditionFilter
        self.associationalWord = associationalWord
        super.init(nibName: nil, bundle: nil)
    }

    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        self.isOpenConditionFilter = false
        self.associationalWord = nil
        super.init(nibName: nil, bundle: nil)
        self.isNeedEncode = false
        self.navBar.isShowTypeSelector = false

        self.resetFilterCondition(routeParamObj: paramObj)
        //暂时在这里需要检测一下是否配置已经被加载
        if EnvContext.shared.client.configCacheSubject.value == nil {
            EnvContext.shared.client.loadSearchCondition()
        }

        self.navBar.backBtn.rx.tap.bind { [weak self] void in
            EnvContext.shared.toast.dismissToast()
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: conditionPanelView,
            searchFilterPanel: searchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM)

    }

    func resetFilterCondition(routeParamObj paramObj: TTRouteParamObj?) {
        self.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator.monoid()
        self.searchAndConditionFilterVM.conditions = [:]
        self.searchAndConditionFilterVM.searchSortCondition = nil

        self.queryString = ""
        if let theHouseType = paramObj?.allParams["house_type"] as? String {
            houseType.accept(HouseType(rawValue: Int(theHouseType)!) ?? .secondHandHouse)
        }

        if let userInfo = paramObj?.userInfo,let params = userInfo.allInfo["tracer"]{
            self.tracerParams = paramsOfMap(params as? [String : Any] ?? [:]) <|>
                toTracerParams(houseTypeString(houseType.value), key: "category_name")
        }

        self.allParams = paramObj?.allParams as? [String: Any]
        if let condition = paramObj?.allParams["suggestion"] as? String {
            self.suggestionParams = condition
        }
        fillAssociationalWord(queryParams: paramObj?.queryParams as? [String : Any] ?? [:])

        self.queryParams = paramObj?.queryParams.filter {
            if let key = $0.key as? String {
                return key != "placeholder"
            } else {
                return false
            }
        } as? [String: Any]

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setupSortCondition() {
        let searchView = SortConditionPanel()
        searchView.isHidden = true
        self.conditionPanelView.addSubview(searchView)
        searchView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(433)
        }
        self.conditionFilterViewModel?.sortPanelView = searchView
        self.conditionFilterViewModel?.searchSortBtn = searchSortBtn
        self.searchSortBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
                self.conditionFilterViewModel?.openOrCloseSortPanel()
            })
            .disposed(by: disposeBag)

        self.houseType
            .bind { [unowned self, weak searchView] (type) in
                searchView?.snp.updateConstraints({ (maker) in
                    maker.height.equalTo(self.categulateSortPanelHeight(by: self.houseType.value))
                })
                if let options = self.filterSortCondition(by: type)?.first?.options {
                    let nodes: [Node] = transferSearchConfigOptionToNode(
                        options: options,
                        rate: 1,
                        isSupportMulti: false)
                    if let orderConditions = nodes.first {
                        searchView?.setSortConditions(nodes: orderConditions.children)
                    } else {
                        assertionFailure()
                    }
                }
            }
            .disposed(by: disposeBag)
        if let queryParams = self.queryParams {
            searchView.setSelectedConditions(conditions: queryParams)
        }
    }


    fileprivate func categulateSortPanelHeight(by houseType: HouseType) -> CGFloat {
        if let condition = filterSortCondition(by: houseType)?.first?.options?.first?.options {
            return CGFloat(45 * condition.count + 15)
        } else {
            return 433
        }
    }

    fileprivate func filterSortCondition(by houseType: HouseType) -> [SearchConfigFilterItem]? {
        switch houseType {
        case .neighborhood:
            return EnvContext.shared.client.configCacheSubject.value?.neighborhoodFilterOrder
        case .newHouse:
            return EnvContext.shared.client.configCacheSubject.value?.courtFilterOrder
        default:
            return EnvContext.shared.client.configCacheSubject.value?.filterOrder
        }
    }

    fileprivate func fillAssociationalWord(queryParams: [String: Any]?) {
        if let queryParams = queryParams,
            let associationalWord = queryParams["full_text"] {
            self.navBar.searchInput.placeholder = getPlaceholderText(
                inputText: associationalWord as? String,
                inputField: self.navBar.searchInput)
            if let associationalWord = associationalWord as? String {
                self.associationalWord = associationalWord
                self.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator { q in
                    q + "&full_text=\(associationalWord)"
                }
                self.navBar.searchInput.text = nil
            }
        }

        if let queryParams = queryParams,
            let placeholder = queryParams["placeholder"] as? String {
            if placeholder.isEmpty {
                self.navBar.searchInput.placeholder = searchBarPlaceholder(self.houseType.value)
            } else {
                self.navBar.searchInput.placeholder = placeholder
            }
            self.navBar.searchInput.text = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let associationalWord = self.associationalWord {
            self.navBar.searchInput.placeholder = associationalWord
        }
        if self.associationalWord?.isEmpty ?? true &&
            navBar.searchInput.placeholder == nil {
            navBar.searchInput.placeholder = searchBarPlaceholder(self.houseType.value)
        }
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: conditionPanelView,
            searchFilterPanel: searchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 11.0, *) {
            self.tableView.estimatedRowHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
            self.tableView.estimatedSectionFooterHeight = 0

        }
        
        self.errorVM = NHErrorViewModel(
            errorMask:infoMaskView,
            requestRetryText:"网络异常",
            requestNilDataText:"没有找到相关的信息，换个条件试试吧~",
            requestNilDataImage:"group-9",
            isUserClickEnable:false,
            retryAction:{ [weak self] in
                if let hasNone = self?.hasNone{
                    if !hasNone {
                        self?.searchAndConditionFilterVM.sendSearchRequest()
                    }
                }
        })

        
        UIApplication.shared.statusBarStyle = .default
        self.categoryListViewModel = CategoryListViewModel(tableView: self.tableView, navVC: self.navigationController)

        bindHouseSearchParams()
        
        view.addSubview(navBar)

        //loadingView
        self.categoryListViewModel?.showLoading = { [weak self] (message) in
            self?.showLoadingAlert(message: message)
        }

        self.categoryListViewModel?.dismissLoading = { [weak self] in
            self?.dismissLoadingAlert()
        }

        self.categoryListViewModel?.onError = { [weak self] (error) in
            self?.tableView.mj_footer.endRefreshing()
            self?.errorVM?.onRequestError(error: error)
        }
        
        self.categoryListViewModel?.onSuccess = { [weak self] (isHaveData) in
            
            self?.tableView.mj_footer.endRefreshing()

            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }
        }
        
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(44 + CommonUIStyle.StatusBar.height)
        }

        navBar.searchAreaBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.recordClickHouseSearch()

                    self.conditionFilterViewModel?.closeConditionFilterPanel(index: -1)
                    let vc = SuggestionListVC(isFromHome: EnterSuggestionType.enterSuggestionTypeList)
                    let params = TracerParams.momoid() <|>
                            toTracerParams(categoryEnterNameByHouseType(houseType: self.houseType.value), key: "enter_from") <|>
                            toTracerParams("click", key: "enter_type") <|>
                            toTracerParams("click", key: "category_name") <|>
                            beNull(key: "element_from")
                    self.tracerParams = self.tracerParams <|>
                        toTracerParams("maintab_search", key: "element_from")
                    vc.tracerParams = params
                    vc.filterConditionResetter = self.filterConditionResetter()
                    vc.houseType.accept(self.houseType.value)
                    vc.navBar.searchable = true
                    let nav = self.navigationController
                    nav?.pushViewController(vc, animated: true)
                    vc.navBar.backBtn.rx.tap
                            .subscribe(onNext: { [weak nav] void in
                                nav?.popViewController(animated: true)
                            })
                            .disposed(by: self.disposeBag)

                    vc.onSuggestionSelected = { [weak nav, unowned self, unowned vc] (params) in
//                        self.isNeedEncode = true
                        self.conditionFilterViewModel?.cleanSortCondition()
                        self.suggestionParams = nil
                        self.resetFilterCondition(routeParamObj: params)
                        self.houseType.accept(vc.houseType.value)
                        self.resetConditionData()
//                        }
                        if let queryParams = self.queryParams {
                            self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
                        }
                        nav?.popViewController(animated: true)
                        self.navBar.searchInput.text = nil
//                        self.searchAndConditionFilterVM.sendSearchRequest()
//                        self.navBar.searchInput.placeholder = associationalWord
                    }
                })
                .disposed(by: disposeBag)

        navBar.searchTypeBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    if self.navBar.canSelectType {
                        self.displayPopupMenu()
                        self.conditionFilterViewModel?.closeConditionFilterPanel(index: -1)
                    }
                })
                .disposed(by: disposeBag)

        view.addSubview(searchSortBtnBG)
        searchSortBtnBG.addSubview(searchSortBtn)
        view.addSubview(searchFilterPanel)

        searchSortBtnBG.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview()
            maker.left.equalTo(searchFilterPanel.snp.right)
            maker.top.equalTo(navBar.snp.bottom)
            maker.height.equalTo(44)
        }

        searchSortBtn.snp.makeConstraints { (maker) in
            maker.height.width.equalTo(20)
            maker.right.equalTo(-15)
            maker.bottom.equalTo(searchFilterPanel.snp.bottom).offset(-10)
        }

        searchFilterPanel.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.equalToSuperview()
            maker.right.equalTo(searchSortBtn.snp.left)
            maker.height.equalTo(44)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.bottom.equalToSuperview()
        }
        
        self.categoryListViewModel?.dataSource.datas
            .skip(1)
            .map { $0.count < 1 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        view.addSubview(infoMaskView)
        infoMaskView.isHidden = true
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }

        setupSortCondition()

        bindLoadMore()

        bindSearchRequest()


        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview()

        }
        conditionPanelView.isHidden = true
        self.errorVM?.onRequest()
        self.searchAndConditionFilterVM.sendSearchRequest()
        self.resetConditionData()
//        stayTimeParams = tracerParams <|> traceStayTime() <|> EnvContext.shared.homePageParams
//        // 进入列表页埋点
//        recordEvent(key: TraceEventName.enter_category, params: tracerParams)
        self.errorVM?.onRequestViewDidLoad()
    }
    
    func bindHouseSearchParams() {
        if let houseSearchParams = allParams?["houseSearch"] as? [String: Any] {
            self.categoryListViewModel?.houseSearchRecorder = self.recordHouseSearch(
                pageType: (houseSearchParams["page_type"] as? String) ?? "be_null",
                houseSearchParams: TracerParams.momoid(),
                searchParams: houseSearchParams)
            self.categoryListViewModel?.houseSearch = houseSearchParams
        }
    }

    func bindLoadMore() {
        
        let footer: NIHRefreshCustomFooter = NIHRefreshCustomFooter { [weak self] in
            self?.loadData()
        }

        tableView.mj_footer = footer
        footer.isHidden = true

        self.categoryListViewModel?.onDataLoaded = { [weak self] (hasMore, count) in

            if self?.hasRecordEnterCategory ?? true == false,
                let tracerParams = self?.tracerParams {

                let params = tracerParams <|> EnvContext.shared.homePageParams <|>
                toTracerParams(self?.categoryListViewModel?.originSearchId ?? "be_null", key: "search_id")

                recordEvent(key: TraceEventName.enter_category, params: params)
                self?.hasRecordEnterCategory = true
                self?.stayTimeParams = tracerParams <|> traceStayTime() <|> EnvContext.shared.homePageParams
            }

            self?.hasMore = hasMore
            self?.tableView.mj_footer.isHidden = false

            if hasMore == false {
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                self?.tableView.mj_footer.endRefreshing()
            }
            if count > 0 {
                self?.infoMaskView.isHidden = true
            } else {
                self?.infoMaskView.label.text = "没有找到相关的信息，换个条件试试吧~"
                self?.errorVM?.onRequestNilData()
                self?.hasNone = true
            }
            var rankType = "default"
            if let node = self?.searchAndConditionFilterVM.searchSortCondition,
                let theRankType = node.rankType {
                rankType = theRankType
            }
            self?.traceHouseRank(
                searchId: self?.categoryListViewModel?.originSearchId ?? "be_null",
                rankType: rankType)

            self?.traceHouseFilter(searchId: self?.categoryListViewModel?.originSearchId ?? "be_null")
        }

    }

    @objc func loadData() {
        let refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type") <|>
                toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "origin_search_id")
            
            
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        errorVM?.onRequest()
        categoryListViewModel?.pageableLoader?()
    }

    // MARK: 搜索请求
    func bindSearchRequest() {
        searchAndConditionFilterVM.queryCondition
                .map { [unowned self] (result) -> String in
                    var theResult = result
                    //增加设置，如果关闭API部分的转码，需要这里将条件过滤器拼接的条件，进行转码
                    if !self.isNeedEncode {
                        if let encodeUrl = result.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            theResult = encodeUrl
                        }
                    }
                    return "house_type=\(self.houseType.value.rawValue)" + theResult + self.queryString
                }
                .debounce(0.1, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    if EnvContext.shared.client.reachability.connection == .none
                    {
                        EnvContext.shared.toast.showToast("网络异常")
                        return
                    }
                    self.errorVM?.onRequest()
                    self.categoryListViewModel?.requestData(
                            houseType: self.houseType.value,
                            query: query,
                            condition: self.suggestionParams,
                            needEncode: self.isNeedEncode)
                    let theTracerParams = EnvContext.shared.homePageParams
                    self.tracerParams = self.tracerParams <|> theTracerParams
                    self.stayTimeParams = self.tracerParams <|> traceStayTime()

                    // 进入列表页埋点
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if disposeable == nil {
            disposeable = houseType.subscribe(onNext: { [weak self] (type) in
                self?.navBar.searchTypeLabel.text = type.stringValue()
                self?.searchAndConditionFilterVM.pageType = houseTypeString(type)
                self?.searchAndConditionFilterVM.sendSearchRequest()
            })
        }
        bindHouseSearchParams()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams <|> toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "search_id"))
        }
        stayTimeParams = nil
        self.hasRecordEnterCategory = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EnvContext.shared.client.loadSearchCondition()
        
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "origin_search_id")
        UIApplication.shared.statusBarStyle = .default
        self.ttStatusBarStyle = UIStatusBarStyle.default.rawValue
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }

    func filterConditionResetter() -> () -> Void {
        return { [weak self] in
            self?.conditionFilterViewModel?.closeConditionFilterPanel(index: -1)
            self?.searchAndConditionFilterVM.cleanCondition()
            self?.resetConditionData()
            self?.disposeable?.dispose()
            self?.disposeable = nil
        }
    }

    private func resetConditionData() {
        Observable
            .zip(houseType, EnvContext.shared.client.configCacheSubject)
//            .debug("resetConditionData")
            .filter { (e) in
                let (_, config) = e
//                assert(config != nil)
                return config != nil
            }
            .map { [unowned self] (e) -> ( [SearchConfigFilterItem]?) in
                let (type, config) = e
                self.searchAndConditionFilterVM.pageType = houseTypeString(type)

                switch type {
                case HouseType.newHouse:
                    return config?.courtFilter
                case HouseType.secondHandHouse:
                    return config?.filter
                case HouseType.neighborhood:
                    return config?.neighborhoodFilter
                default:
                    return config?.filter
                }

            }
            .map { items in //
//                assert(items?.count != 0)
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
            // 绑定点击事件，实现弹出相应的条件选择控件
            .subscribe(onNext: { [unowned self] (items: ([SearchConditionItem], [[Node]])) in
                let reload: () -> Void = { [weak self] in
                    self?.conditionFilterViewModel?.reloadConditionPanel()
                }
                let ns = items.1.reduce([], { (result, nodes) -> [Node] in
                    result + nodes
                })
                let keys = self.allKeysFromNodes(nodes: ns)
                var conditions = ""
                self.queryParams?.forEach({ (key, value) in
                    if !keys.contains(key) {
                        //
                        conditions = conditions + convertKeyValueToCondition(key: key, value: value).reduce("", { (result, value) -> String in
                            result + "&\(value)"
                        })
                    }
                })
                zip(items.0, items.1)
                    .enumerated()
                    .forEach({ [unowned self] (e) in
                        let (offset, (item, nodes)) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(
                            index: offset,
                            reload: reload,
                            item: item,
                            data: nodes)

                    })
                self.queryString = self.queryString + conditions
                if let queryParams = self.queryParams {
                    self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
                }
                self.conditionFilterViewModel?.filterConditions = items.0
                self.conditionFilterViewModel?.reloadConditionPanel()
            })
            .disposed(by: disposeBag)
    }



    fileprivate func allKeysFromNodes(nodes: [Node]) -> Set<String> {
        return nodes.reduce([], { (result, node) -> Set<String> in
            var theResult = result
            if !node.children.isEmpty {
                let keys = allKeysFromNodes(nodes: node.children)
                keys.forEach({ (key) in
                    theResult.insert(key)
                })
            }
            if let key = node.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                theResult.insert(key)
            }
            return theResult
        })
    }

    private func displayPopupMenu() {
        let menuItems = [HouseType.secondHandHouse,
                         HouseType.newHouse,
                         HouseType.neighborhood]

        let popupMenuItems = menuItems.map { type -> PopupMenuItem in
            let result = PopupMenuItem(label: type.stringValue(), isSelected: self.houseType.value == type)
            result.onClick = { [weak self] in
                self?.houseType.accept(type)
                self?.popupMenuView?.removeFromSuperview()
                self?.popupMenuView = nil
            }
            return result
        }
        popupMenuView = PopupMenuView(targetView: navBar.searchTypeBtn, menus: popupMenuItems)
        view.addSubview(popupMenuView!)
        popupMenuView?.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        popupMenuView?.showOnTargetView()
    }


    /// 找房搜索打点
    /// 需要传入queryType
    /// - Parameters:
    ///   - pageType: 页面类型
    ///   - houseSearchParams: 打点传参
    ///   - searchParams:
    fileprivate func recordHouseSearch(
        pageType: String,
        houseSearchParams: TracerParams,
        searchParams: [String: Any]? = nil) -> (String?) -> Void {
        var hasRecord = false
        return { [weak self] (searchId) in

            if hasRecord {
                return
            }
            hasRecord = true
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams(searchId ?? "be_null", key: "origin_search_id")

            let params = EnvContext.shared.homePageParams <|>
                houseSearchParams <|>
                paramsOfMap(searchParams ?? [:]) <|>
                toTracerParams(searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(self?.houseType.value.traceTypeValue() ?? "be_null", key: "house_type") <|>
                toTracerParams(pageType, key: "page_type")
            recordEvent(key: "house_search", params: params)
        }
    }

    // 记录 click_house_search
    fileprivate func recordClickHouseSearch() {
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams(pageTypeString(), key: "page_type")
        recordEvent(key: "click_house_search", params: params)
    }

    fileprivate func pageTypeString() -> String {
        switch self.houseType.value {
        case .neighborhood:
            return "neighborhood_list"
        case .newHouse:
            return "new_list"
        default:
            return "old_list"
        }
    }

    fileprivate func traceHouseRank(searchId: String, rankType: String) {
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams(searchId, key: "search_id") <|>
            toTracerParams(pageTypeString(), key: "page_type") <|>
            toTracerParams(rankType, key: "rank_type")
        recordEvent(key: "house_rank", params: params)
    }

    fileprivate func traceHouseFilter(searchId: String) {
        let json = self.searchAndConditionFilterVM.conditionTracer.value
            .map { $0.value }
            .reduce([:], mapCondition)

        let params = EnvContext.shared.homePageParams <|>
            toTracerParams(self.houseType.value.traceTypeValue(), key: "house_type") <|>
            toTracerParams(jsonStringMapper(json), key: "filter") <|>
            toTracerParams(searchId, key: "search_id") <|>
            toTracerParams(pageTypeString(), key: "page_type")
        recordEvent(key: "house_filter", params: params)
    }

}

func houseTypeString(_ houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "new_list"
    case .neighborhood:
        return "neighborhood_list"
    case .secondHandHouse:
        return "old_list"
    default:
        return "be_null"
    }
}

func convertKeyValueToCondition(key: String, value: Any) -> [String] {
    if let arrays = value as? Array<Any> {
        return arrays.map { e in
            if let value = "\(e)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return "\(key)=\(value)"
            } else {
                return "\(key)=\(e)"
            }
        }
    } else {
        if let valueStr = value as? String,
            let theValue = valueStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return ["\(key)=\(theValue)"]
        } else {
            return ["\(key)=\(value)"]
        }
    }
}


fileprivate func mapCondition(result: [String: [Any]], nodes: [Node]) -> [String: [Any]] {
    var result = result
    nodes.forEach { node in
        var values = valueWithDefault(map: result, key: node.key, defaultValue: [Node]())
        if let filterCondition = node.filterCondition {
            values.append(filterCondition)
        }
        result[node.key] = values
    }
    return result
}

fileprivate func jsonStringMapper(_ value:  [String: [Any]]) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: value, options: []) as Data,
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        return json as String
    }
    return ""
}
