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

    let tipViewHeight: CGFloat = 32

    fileprivate var userInteractionObv: NSKeyValueObservation?
    
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
        result.backgroundColor = UIColor.white
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

    var resetConditionDisposeBag: DisposeBag = DisposeBag()

    var searchSortBtnBG: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        re.lu.addBottomBorder()
        return re
    }()

    private var conditions: [Node]?

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
        self.navBar.mapBtn.rx.tap
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] void in
                self?.gotoMapSearch()
            }.disposed(by: disposeBag)
    }

    var integratedMessageBar: ArticleListNotifyBarView?

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
        self.navBar.mapBtn.rx.tap
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind { [weak self] void in
                self?.gotoMapSearch()
            }.disposed(by: disposeBag)
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
        self.queryParams?["search_id"] = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        userInteractionObv = self.view.observe(\.isUserInteractionEnabled, options: [.new]) { [weak self] (view, value) in
            if let _ = value.newValue {
                self?.view.endEditing(true)
            }
        }

        if let associationalWord = self.associationalWord {
            self.navBar.setSearchPlaceHolderText(text: associationalWord)
        }
        if self.associationalWord?.isEmpty ?? true &&
            navBar.searchInput.placeholder == nil {
            navBar.setSearchPlaceHolderText(text: searchBarPlaceholder(self.houseType.value))
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
            isUserClickEnable:true,
            retryAction:{ [weak self] in
                if let hasNone = self?.hasNone{
                    if !hasNone {
                        self?.searchAndConditionFilterVM.sendSearchRequest()
                        self?.resetConditionData()
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
            self?.tableView.finishPullDown(withSuccess: false)
        }

        self.categoryListViewModel?.onSuccess = { [weak self] (isHaveData) in

            self?.tableView.mj_footer.endRefreshing()
            self?.tableView.finishPullDown(withSuccess: true)

            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }
        }

        self.categoryListViewModel?.showTips = self.showTips()

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

                // 关键词搜索
                vc.onSuggestionSelected = { [weak nav, unowned self, unowned vc] (params) in
                    self.isNeedEncode = false
                    self.conditionFilterViewModel?.cleanSortCondition()
                    self.suggestionParams = nil
                    self.hasRecordEnterCategory = false
                    self.resetFilterCondition(routeParamObj: params?.paramObj)
                    self.houseType.accept(vc.houseType.value)
                    self.resetConditionData()
                    //                        }
                    if let queryParams = self.queryParams {
                        self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
                    }
                    nav?.popViewController(animated: true)
                    self.navBar.searchInput.text = nil
                    self.allParams = params?.paramObj.allParams as? [String: Any]
                    if let queryParams = self.queryParams {
                        self.conditionFilterViewModel?.sortPanelView?.setSelectedConditions(conditions: queryParams)
                        self.conditionFilterViewModel?.setSortBtnSelected()
                    }
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


        //        self.ttErrorToastView = integratedMessageBar
        view.addSubview(tableView)

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

        let integratedMessageBar = ArticleListNotifyBarView(
            frame: CGRect(
                x: 0,
                y: 200,
                width: 500, height: tipViewHeight))
        self.integratedMessageBar = integratedMessageBar
        view.insertSubview(integratedMessageBar, aboveSubview: infoMaskView)
        
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


        self.view.bringSubview(toFront: searchFilterPanel)
        self.view.bringSubview(toFront: searchSortBtnBG)

        self.searchSortBtnBG.isHidden = true
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
                let htype = self.houseType.value
                let showMap = (htype == .secondHandHouse || htype == .rentHouse)
                self.navBar.showMapButton(show:showMap)
            }
            .disposed(by: disposeBag)
        if let queryParams = self.queryParams {
            searchView.setSelectedConditions(conditions: queryParams)
            self.conditionFilterViewModel?.setSortBtnSelected()
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
        case .rentHouse:
            return EnvContext.shared.client.configCacheSubject.value?.rentFilterOrder
        default:
            return EnvContext.shared.client.configCacheSubject.value?.filterOrder
        }
    }

    fileprivate func allSortConditionKeys() -> String {
        if let options = filterSortCondition(by: self.houseType.value)?.first?.options?.first?.options {
            if options.count > 1 {
                if let type = options[1].type,
                    let sortType = "\(type)[]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    return sortType
                }
                return options[1].type ?? ""
            }
            return options.first?.type ?? ""
        } else {
            return ""
        }
    }

    fileprivate func fillAssociationalWord(queryParams: [String: Any]?) {
        if let queryParams = queryParams,
            let associationalWord = queryParams["full_text"] {
            print("process: \(associationalWord)")
            print("process: queryParams \(queryParams)")
            self.navBar.setSearchPlaceHolderText(text: getPlaceholderText(
                inputText: associationalWord as? String,
                inputField: self.navBar.searchInput))
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
                self.navBar.setSearchPlaceHolderText(text: searchBarPlaceholder(self.houseType.value))
            } else {
                self.navBar.setSearchPlaceHolderText(text: placeholder)
            }
            self.navBar.searchInput.text = nil
        }
    }

    fileprivate func processDisplayText(queryParams: [String: Any]?) {
        if let queryParams = queryParams,
            let associationalWord = queryParams["display_text"] as? String {
            self.navBar.searchInput.placeholder = associationalWord.removingPercentEncoding
            self.queryParams?["display_text"] = associationalWord.removingPercentEncoding
        }
    }

    fileprivate func showTips() -> (String) -> Void {
        return { [weak self] (message) in
            self?.integratedMessageBar?.showMessage(
                message,
                actionButtonTitle: "",
                delayHide: true,
                duration: 1,
                bgButtonClickAction: { (button) in

            }, actionButtonClick: { (button) in

            }, didHide: { (view) in

            })
            if let tableView = self?.tableView {
                if tableView.contentOffset.y <= 1 {
                    let height = self?.integratedMessageBar?.height ?? 0
                    var inset = tableView.contentInset
                    //current original inset top is 0
                    inset.top = height
                    tableView.contentInset = inset
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        UIView.animate(withDuration: 0.3, animations: {
                            inset.top = 0
                            tableView.contentInset = inset
                        })
                    })
                }
            }
            
        }
    }
    
    func gotoMapSearch(){
        
        guard var openUrl = self.categoryListViewModel?.mapFindHouseOpenUrl  else {
            return
        }
        
        self.navBar.mapBtn.isEnabled = false
        
        self.conditionFilterViewModel?.closeConditionFilterPanel(index: -1)
        
        //点击切换埋点
        let catName = pageTypeString()
        var elementName = (selectTraceParam(self.tracerParams, key: "element_from") as? String) ?? "be_null"
        let originFrom = (selectTraceParam(self.tracerParams, key: "origin_from") as? String) ?? "be_null"
        let originSearchId = self.categoryListViewModel?.originSearchId ?? "be_null"
//        let enterCategory =  (selectTraceParam(self.tracerParams, key: TraceEventName.enter_category) as? String) ?? ""
        let enterFrom = (selectTraceParam(self.tracerParams, key: "enter_from") as? String) ?? catName
        
        
        if elementName == "be_null" && originFrom != "be_null" {
            elementName = originFrom
        }
        
        let params = TracerParams.momoid() <|>
            toTracerParams(enterFrom, key: "enter_from") <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams("map", key: "click_type") <|>
            toTracerParams(catName, key: "category_name") <|>
            toTracerParams(categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
            toTracerParams(elementName, key: "element_from") <|>
            toTracerParams(originFrom, key: "origin_from") <|>
            toTracerParams(originSearchId, key: "origin_search_id")
        
        recordEvent(key: TraceEventName.click_switch_mapfind, params: params)
        var query = ""
        if  !openUrl.contains("enter_category") {
            query = "enter_category=\(catName)"
        }
        if !openUrl.contains("origin_from") {
            query = "\(query)&origin_from=\(originFrom)"
        }
        
        if !openUrl.contains("origin_search_id") {
            query = "\(query)&origin_search_id=\(originSearchId)"
        }
        if !openUrl.contains("enter_from"){
            query = "\(query)&enter_from=\(catName)"
        }
        if !openUrl.contains("element_from"){
            query = "\(query)&element_from=\(elementName)"
        }
        if !openUrl.contains("search_id"){
            query = "\(query)&search_id=\(categoryListViewModel?.originSearchId ?? "be_null")"
        }
        

        if query.count > 0 {
            openUrl = "\(openUrl)&\(query)"
        }
        guard let url = URL(string: openUrl) else {
            self.navBar.mapBtn.isEnabled = true
            return
        }
        var info = [AnyHashable: Any]()
        let hashMap = NSHashTable<NSObject>(options:NSPointerFunctions.Options.weakMemory,capacity:1)
        hashMap.add(self)
        info[OPENURL_CALLBAK] = hashMap
        let userInfo = TTRouteUserInfo(info: info)
        TTRoute.shared()?.openURL(byPushViewController: url, userInfo: userInfo)
        
        self.navBar.mapBtn.isEnabled = true
    }

    override func viewDidLayoutSubviews() {
        self.integratedMessageBar?.frame = CGRect(
            x: 0,
            y: self.tableView.top,
            width: self.tableView.width,
            height: tipViewHeight)
    }
    
    func bindHouseSearchParams() {
        if let houseSearchParams = allParams?["houseSearch"] as? [String: Any] {
            self.categoryListViewModel?.houseSearchRecorder = self.recordHouseSearch(
                pageType: (houseSearchParams["page_type"] as? String) ?? "be_null",
                houseSearchParams: TracerParams.momoid(),
                searchParams: houseSearchParams)
            self.categoryListViewModel?.houseSearch = houseSearchParams
        } else {
            let houseSearchParams = ["search_query": "be_null",
                                     "enter_query": "be_null"]
            self.categoryListViewModel?.houseSearchRecorder = self.recordHouseSearch(
                pageType: self.pageTypeString(),
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

                var params = tracerParams <|> EnvContext.shared.homePageParams <|>
                toTracerParams(self?.categoryListViewModel?.originSearchId ?? "be_null", key: "search_id")
                if let logpb = self?.categoryListViewModel?.logPB
                {
                    params = params <|>
                        toTracerParams(logpb, key: "log_pb")
                }

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
                self?.resetConditionData()
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
            self?.allParams?["houseSearch"] = nil
            self?.bindHouseSearchParams()

            if let houseListOpenUrl = self?.categoryListViewModel?.houseListOpenUrl {
                self?.resetFilterConditionByRequestData(openUrl: houseListOpenUrl)
                guard let url = URL(string: houseListOpenUrl) else {
                    return
                }

                //需要重置非过滤器条件，以及热词placeholder
                let routeObj = TTRoute.shared()?.routeParamObj(with:url)
                self?.allParams = routeObj?.allParams as? [String: Any]
                self?.queryParams = routeObj?.queryParams as? [String : Any]
                var keys = self?.allKeysFromNodes(nodes: self?.conditions ?? [])
                if let sortKey = self?.allSortConditionKeys() {
                    //计算所有排序的key
                    keys?.insert(sortKey)
                }
                if let queryParams = self?.queryParams, let keys = keys {
                    // 这里必须根据画参数的来源决定是否编码，如果是服务器传送来的，都不可以再做编码，TODO 后续改成客户算来源的参数也增加编码
                    self?.queryString = getNoneFilterConditionString(params: queryParams, conditionsKeys: keys, encoding: !(self?.isNeedEncode ?? true))
                    self?.processDisplayText(queryParams: queryParams)

                }
                //这里必须要在重置逻辑之前嗲用
                if FHFilterRedDotManager.shared.shouldOpenAreaPanel() {
                    //这里暂时只能写死了,为了实现学区房红点
                    if let areaConditionPanel = self?.conditionFilterViewModel?.conditionItemViews[0] as? AreaConditionFilterPanel {
                        self?.conditionFilterViewModel?.onOpenConditionPanel(panel: areaConditionPanel, index: 0)
                        //需要在下一个loop开始监控，否则页面c打开时会触发滚动
                        DispatchQueue.main.async {
                            areaConditionPanel.addTableViewScrollMonitor()
                        }
                    }
                }
            }
        }

    }

    @objc func loadData() {
        var refreshParams = self.tracerParams.exclude("card_type") <|>
                toTracerParams("pre_load_more", key: "refresh_type") <|>
                toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(self.categoryListViewModel?.originSearchId ?? "be_null", key: "origin_search_id")
        
        if let logpb = self.categoryListViewModel?.logPB
        {
            refreshParams = refreshParams <|>
                toTracerParams(logpb, key: "log_pb")
        }
            
        recordEvent(key: TraceEventName.category_refresh, params: refreshParams)
        errorVM?.onRequest()
        categoryListViewModel?.pageableLoader?()
    }

    // MARK: 搜索请求
    func bindSearchRequest() {
        searchAndConditionFilterVM.queryCondition
                .debounce(0.1, scheduler: MainScheduler.instance)
                .map { [unowned self] (result) -> String in
                    self.getQueryCondition(filterCondition: result)
                }
                .subscribe(onNext: { [unowned self] query in
                    self.requestData(query: query)
                })
                .disposed(by: disposeBag)
    }

    fileprivate func getQueryCondition(filterCondition: String) -> String {
        var theResult = filterCondition
        //增加设置，如果关闭API部分的转码，需要这里将条件过滤器拼接的条件，进行转码
        if !self.isNeedEncode {
            if let encodeUrl = filterCondition.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                theResult = encodeUrl
            }
        }
        return "house_type=\(self.houseType.value.rawValue)" + theResult + self.queryString
    }

    fileprivate func requestData(query: String) {
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
    }

//    fileprivate func pullAndRefresh() {
//        let filterCondition = searchAndConditionFilterVM.queryCondition.value
//        let query = getQueryCondition(filterCondition: filterCondition)
//        requestData(query: query)
//    }

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
        resetConditionDisposeBag = DisposeBag()
        Observable
            .zip(houseType, EnvContext.shared.client.configCacheSubject)
            .filter { (e) in
                let (_, config) = e
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
                case HouseType.rentHouse:
                    return config?.rentFilter
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

                self.conditions = ns
                var keys = self.allKeysFromNodes(nodes: ns)
                let sortKey = self.allSortConditionKeys()
                //计算所有排序的key
                keys.insert(sortKey)

                var oldConditions = ""

                self.queryParams?.forEach({ (key, value) in
                    if !keys.contains(key) {
                        //
                        oldConditions = oldConditions + convertKeyValueToCondition(key: key, value: value).reduce("", { (result, value) -> String in
                            result + "&\(value)"
                        })
                    }
                })

                let conditions = getNoneFilterConditionString(params: self.queryParams, conditionsKeys: keys)

                zip(items.0, items.1)
                    .enumerated()
                    .forEach({ [unowned self] (e) in
                        let (offset, (item, nodes)) = e
//                        self.conditionFilterViewModel?.conditionItemViews.removeAll()
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(
                            index: offset,
                            reload: reload,
                            item: item,
                            data: nodes)
                    })
                self.queryString = self.queryString + conditions
//                print(self.queryString)
                if let queryParams = self.queryParams {
                    self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
                }
                self.conditionFilterViewModel?.filterConditions = items.0
                self.conditionFilterViewModel?.reloadConditionPanel()
                self.conditionFilterViewModel?.pullConditionsFromPanels()
                self.searchSortBtnBG.isHidden = false
            })
            .disposed(by: resetConditionDisposeBag)
    }


    /// 调整逻辑，每次请求后，从服务器获取listUrl填充Filter过滤器
    func resetFilterConditionByRequestData(openUrl: String) {
        guard let url = URL(string: openUrl) else {
            return
        }
        let routeObj = TTRoute.shared()?.routeParamObj(with:url)
        self.allParams = routeObj?.allParams as? [String: Any]
        if let queryParams = self.allParams {
            self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
        }
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
        return { [weak self] (searchId) in
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams(searchId ?? "be_null", key: "origin_search_id")

            let params = EnvContext.shared.homePageParams <|>
                houseSearchParams <|>
                paramsOfMap(searchParams ?? [:]) <|>
                toTracerParams(searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(self?.houseType.value.traceTypeValue() ?? "be_null", key: "house_type") <|>
                toTracerParams(pageType, key: "page_type")
            recordEvent(key: "house_search", params: params)
            self?.allParams?["houseSearch"] = nil
        }
    }

    // 记录 click_house_search
    fileprivate func recordClickHouseSearch() {
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams(pageTypeString(), key: "page_type") <|>
            toTracerParams("be_null", key: "hot_word")
        recordEvent(key: "click_house_search", params: params)
    }

    fileprivate func pageTypeString() -> String {
        switch self.houseType.value {
        case .neighborhood:
            return "neighborhood_list"
        case .newHouse:
            return "new_list"
        case .rentHouse:
            return "rent_list"
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

    deinit {
        FHFilterRedDotManager.shared.mark()
    }

}

extension CategoryListPageVC : FHMapSearchOpenUrlDelegate
{

    func handleHouseListCallback(_ openUrl: String) {

        let routeObj = TTRoute.shared()?.routeParamObj(with: URL(string: openUrl))
        self.queryParams = routeObj?.queryParams as? [String: Any]
        if let queryParams = self.queryParams {
            self.conditionFilterViewModel?.setSelectedItem(items: queryParams)
            self.conditionFilterViewModel?.pullConditionsFromPanels()
        }

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
    case .rentHouse:
        return "rent_list"
    default:
        return "be_null"
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
