//
//  HouseFindVC.swift
//  Article
//
//  Created by leo on 2018/9/17.
//

import Foundation
import RxSwift
import SnapKit
import RxCocoa
import Reachability

struct SectionItem {
    let houseType: HouseType
    let label: String
}

extension Notification.Name {
    static let findHouseHistoryCellReset = Notification.Name("find_house_history_cell_reset")
}

fileprivate func houseTypeSectionByConfig(config: SearchConfigResponseData) -> [SectionItem] {
    var result: [SectionItem] = []
    if let cfg = config.searchTabFilter {
        if cfg.count > 0 {
            result.append(SectionItem(houseType: .secondHandHouse, label: "二手房"))
        }
    }
    if let cfg = config.searchTabCourtFilter {
        if cfg.count > 0 {
            result.append(SectionItem(houseType: .newHouse, label: "新房"))
        }
    }
    if let cfg = config.searchTabRentFilter {
        if cfg.count > 0 {
            result.append(SectionItem(houseType: .rentHouse, label: "租房"))
        }
    }
    if let cfg = config.searchTabNeighborHoodFilter {
        if cfg.count > 0 {
            result.append(SectionItem(houseType: .neighborhood, label: "小区"))
        }
    }
    return result
}

class HouseFindVC: BaseViewController, UIGestureRecognizerDelegate {

    private var stayTabParams = TracerParams.momoid()
    private var theThresholdTracer: ((String, TracerParams) -> Void)?

    private let houseType = BehaviorRelay<HouseType>(value: HouseType.secondHandHouse)

    private var houseFilterDataSource: [HouseType: CollectionDataSource] = [:]

    private var houseFilterCollectionView: [HouseType: UICollectionView] = [:]

    fileprivate var errorVM : NHErrorViewModel?

    fileprivate var pageControl: HouseFindPageControl?

    private lazy var searchBtn: UIButton = {
        let re = UIButton()
        re.setTitleColor(UIColor.white, for: .normal)
        re.setAttributedTitle(
            attributeText("开始找房",
                          color: UIColor.white,
                          font: CommonUIStyle.Font.pingFangRegular(16)),
            for: .normal)
        re.layer.cornerRadius = 26
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        re.layer.shadowOffset = CGSize(width: 0, height: 2)
        re.layer.shadowColor = color(41, 156, 255, 0.4).cgColor
        return re
    }()

    private lazy var segmentedNav: FWSegmentedControl = {
        let re = FWSegmentedControl.segmentedWith(
            scType: SCType.text,
            scWidthStyle: SCWidthStyle.dynamicFixedSuper,
            sectionTitleArray: nil,
            sectionImageArray: nil,
            sectionSelectedImageArray: nil,
            frame: CGRect.zero)
        re.selectionIndicatorHeight = 0

        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(20),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#a1aab3")]

        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangMedium(20),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#081f33")]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes

        return re
    }()

    private lazy var searchBar: HouseFindSearchBar = {
        let re = HouseFindSearchBar(frame: CGRect.zero)
        return re
    }()


    lazy var seperateLineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        re.isHidden = true
        return re
    }()

    private lazy var infoDisplay: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()

    let tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        re.cancelsTouchesInView = false
        return re
    }()

    let containerView: UIScrollView = {
        let re = UIScrollView()
        re.isPagingEnabled = true
        re.bounces = false
        re.showsHorizontalScrollIndicator = false
        return re
    }()

    let disposeBag = DisposeBag()
    fileprivate var contentOffsetDisposeBag : DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(segmentedNav)

        errorVM = NHErrorViewModel(errorMask: infoDisplay) { [weak self] in
            self?.requestHistory()
        }

        containerView.addGestureRecognizer(tapGesture)

        setupViews()

        segmentedNav.indexChangeBlock = { [unowned self] index in
            if let config = EnvContext.shared.client.configCacheSubject.value {
                let items = houseTypeSectionByConfig(config: config)

                if items.count > index {
                    self.houseType.accept(items[index].houseType)
                }

                let offset = self.pageControl?.pageOffsetXByIndex(index) ?? 0
                self.containerView.contentOffset = CGPoint(x: offset, y: 0)

                NotificationCenter.default.post(name: .findHouseHistoryCellReset, object: nil)
                self.adjustVerticalPositionToTop()

            }
        }

        houseType.skip(1).bind { [weak self] _ in
            self?.requestHistory()
        }.disposed(by: disposeBag)

        self.bindSearchAction()

        if EnvContext.shared.client.configCacheSubject.value != nil {
            errorVM?.onRequestNormalData()
        } else {
            if EnvContext.shared.client.reachability.connection == .none {
                errorVM?.onRequestViewDidLoad()
            } else {
                errorVM?.onRequestNilData()
            }
        }

        pageControl = HouseFindPageControl(segmentControl: segmentedNav,
                                           pageView: containerView)
        pageControl?.didPageIndexChanged = { [unowned self] index in
            self.view.endEditing(true)
            if let config = EnvContext.shared.client.configCacheSubject.value {
                let items = houseTypeSectionByConfig(config: config)

                if items.count > index {
                    self.houseType.accept(items[index].houseType)
                }
                self.handleScroll(houseType: self.houseType.value)
                NotificationCenter.default.post(name: .findHouseHistoryCellReset, object: nil)
            }
        }
        bindSearchConfigObv()

        self.bindJumpSearchVC()

        self.view.addSubview(infoDisplay)
        infoDisplay.snp.makeConstraints { (maker) in
            maker.top.bottom.left.right.equalToSuperview()
        }

    }

    fileprivate func dealWithSearchConfigIsEmpty() {

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EnvContext.shared.homePageParams = TracerParams.momoid() <|>
            beNull(key: "origin_search_id") <|>
            beNull(key: "origin_from")

    }

    fileprivate func setupViews() {
        segmentedNav.snp.makeConstraints { maker in
            maker.top.equalTo(40 + (CommonUIStyle.Screen.isIphoneX ? 6 : 0))
            maker.left.equalTo(70 * CommonUIStyle.Screen.widthScale)
            maker.right.equalTo(-70 * CommonUIStyle.Screen.widthScale)
            maker.height.equalTo(28)
            maker.centerX.equalToSuperview()
        }

        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { maker in
            maker.top.equalTo(segmentedNav.snp.bottom).offset(16)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(44)
        }



        self.view.addSubview(seperateLineView)
        seperateLineView.snp.makeConstraints { maker in
            maker.top.equalTo(searchBar.snp.bottom).offset(10)
            maker.height.equalTo(0.5)
            maker.left.right.equalToSuperview()
        }

        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(seperateLineView.snp.bottom)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
            }
        }

        self.view.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview().offset(-20 - CommonUIStyle.TabBar.height)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(200)
            maker.height.equalTo(50)
        }
        self.bindScrollViewObv()
    }

    fileprivate func bindScrollViewObv() {
        tapGesture.rx.event
            .bind { (gesture) in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }

    fileprivate func bindSearchConfigObv() {
        EnvContext.shared.client.configCacheSubject
            .subscribe(onNext: { [weak self] _ in
                self?.setupSectionLabelByConfig()
                self?.createPageViews()
                if let houseType = self?.houseType.value {
                    self?.handleScroll(houseType: houseType)
                }
            })
            .disposed(by: disposeBag)
    }


    func setupSectionLabelByConfig() {
        if let config = EnvContext.shared.client.configCacheSubject.value {
            let sections = houseTypeSectionByConfig(config: config)
            sections.forEach({ (item) in
                let _ = self.dataSourceByHouseType(houseType: item.houseType)
            })
            if let first = sections.first {
                self.houseType.accept(first.houseType)
                self.errorVM?.onRequestNormalData()
            }

            self.cleanAllDatasourceHistoryCache()
            self.preLoadHistoryData(items: sections)
            self.segmentedNav.sectionTitleArray = sections.map { $0.label }
            if self.segmentedNav.segmentWidthsArray?.count ?? 0 > 0 {
                self.segmentedNav.setSelectedSegmentIndex(index: 0, animated: false)
            }
        } else {
            self.segmentedNav.sectionTitleArray = []
        }
    }

    fileprivate func createPageViews() {
        containerView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if let config = EnvContext.shared.client.configCacheSubject.value {
            let items = houseTypeSectionByConfig(config: config)
            let pages = items.map { (item) -> UICollectionView in
                let ds = dataSourceByHouseType(houseType: item.houseType)
                let flowLayout = UICollectionViewFlowLayout()
                flowLayout.itemSize = CGSize(width: 74, height: 28)
                flowLayout.minimumLineSpacing = 12
                flowLayout.minimumInteritemSpacing = 9
                flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
                flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
                let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
                result.backgroundColor = UIColor.clear

                result.contentInset = UIEdgeInsets(top: -6, left: 0, bottom: 80, right: 0)
                result.dataSource = ds
                result.delegate = ds
                result.keyboardDismissMode = .onDrag
                houseFilterCollectionView[item.houseType] = result
                return result
            }

            items.forEach { (item) in
                let ds = dataSourceByHouseType(houseType: item.houseType)
                let priceNode = searchConfigByHouseType(
                    configData: config,
                    houseType: item.houseType).first(where: { $0.tabStyle ?? -1 == 2 })

                ds.priceNodeItem = priceNode
                let nodes = searchConfigByHouseType(
                    configData: config,
                    houseType: item.houseType)
                    .filter { $0.tabStyle ?? -1 != 2 }
                    .map { (option) -> [Node] in
                        if let options = option.options {
                            return transferSearchConfigOptionToNode(
                                options: options,
                                rate: option.rate,
                                isSupportMulti: option.supportMulti)
                        } else {
                            return []
                        }
                }
                if ds.nodes.count == 0 {
                    ds.nodes = nodes.reduce([], { (result, nodes) -> [Node] in
                        result + nodes
                    })
                }
            }

            pages.forEach { (view) in
                self.containerView.addSubview(view)
            }
            pages.snp.makeConstraints { (make) in
                make.top.bottom.width.height.equalToSuperview()
            }
            pages.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
            pages.forEach { (collectionView) in
                self.registerCollectionViewComponent(collectionView: collectionView)
                collectionView.reloadData()
            }
        }

    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    fileprivate func bindJumpSearchVC() {
        searchBar.tapGesture.rx.event
            .subscribe(onNext: { [unowned self] (_) in
                let vc = SuggestionListVC(isFromHome: .enterSuggestionTypeFindTab)

                EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                    toTracerParams("findtab_search", key: "origin_from")

                vc.houseType.accept(self.houseType.value)
                let tracerParams = TracerParams.momoid() <|>
                    toTracerParams("click", key: "enter_type") <|>
                    toTracerParams("maintab_search", key: "element_from") <|>
                    toTracerParams("maintab", key: "enter_from") <|>
                    toTracerParams("be_null", key: "log_pb")

                vc.tracerParams = tracerParams


                let nav = self.navigationController
                nav?.pushViewController(vc, animated: true)
                // 绑定返回逻辑

                vc.navBar.backBtn.rx.tap
                    .subscribe(onNext: { [weak nav] void in
                        EnvContext.shared.toast.dismissToast()
                        nav?.popViewController(animated: true)
                    })
                    .disposed(by: self.disposeBag)

                //绑定suggestion选择处理逻辑
                vc.onSuggestSelect = { [weak self, unowned vc] (query, condition, associationalWord, theHouseSearchParams) in
                    EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                        toTracerParams("findtab_search", key: "origin_from")
                    let paramsWithCategoryType = tracerParams <|>
                        toTracerParams(categoryEnterNameByHouseType(houseType: vc.houseType.value), key: "category_name") <|>
                            toTracerParams("click", key: "enter_type") <|>
                            toTracerParams("findtab_search", key: "element_from") <|>
                            toTracerParams("findtab", key: "enter_from")
                    let houseSearchParams = theHouseSearchParams <|>
                        toTracerParams(self?.pageTypeString() ?? "be_null", key: "page_type")
                    self?.openCategoryList(
                        houseType: vc.houseType.value,
                        condition: condition ?? "",
                        query: query,
                        associationalWord: (associationalWord?.isEmpty ?? true) ? nil : associationalWord,
                        houseSearchParams: houseSearchParams.paramsGetter([:]),
                        tracerParams: paramsWithCategoryType)
                }

                // click_house_search
                self.recordClickHouseSearch()
            })
            .disposed(by: disposeBag)
    }

    private func openCategoryList(
        houseType: HouseType,
        condition: String,
        query: String,
        associationalWord: String? = nil,
        houseSearchParams: [String: Any]? = nil,
        tracerParams: TracerParams) {
        let vc = CategoryListPageVC(
            isOpenConditionFilter: true,
            associationalWord: associationalWord)
        vc.tracerParams = tracerParams
        vc.houseType.accept(houseType)
        vc.suggestionParams = condition
        vc.queryString = query
        vc.navBar.isShowTypeSelector = false
        vc.navBar.searchInput.placeholder = searchBarPlaceholder(houseType)
        if let houseSearchParams = houseSearchParams {
            vc.allParams = ["houseSearch": houseSearchParams]
        }

        let nav = self.navigationController
        nav?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.toast.dismissToast()
                nav?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }


    fileprivate func preLoadHistoryData(items: [SectionItem]) {
        items.forEach { [weak self] (item) in
            self?.requestHistory(houseType: "\(item.houseType.rawValue)")
        }
    }

    fileprivate func bindSearchAction() {
        searchBtn.rx.tap
                .throttle(2, latest: false, scheduler: MainScheduler.instance)
                .bind { [unowned self] void in
                    let dataSource = self.dataSourceByHouseType(houseType: self.houseType.value)
                    let nodes = dataSource.selectedNode()
                    let querys = nodes.map { $0.externalConfig }.joined(separator: "&")

                    var jumpUrl = "fschema://house_list?house_type=\(self.houseType.value.rawValue)"
                    if querys.count > 0 {
                        jumpUrl = jumpUrl + "&\(querys)"
                    }
                    if let priceCondition = dataSource.priceCondition() {
                        jumpUrl = jumpUrl + "&\(priceCondition)"
                    }
                    //设置 vorigin_from
                    EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                        toTracerParams("findtab_find", key: "origin_from")
                    let tracerParams = TracerParams.momoid() <|>
                        EnvContext.shared.homePageParams <|>
                        toTracerParams("findtab", key: "enter_from") <|>
                        toTracerParams("findtab_find", key: "element_from") <|>
                        toTracerParams("click", key: "enter_type")
                    let houseSearchParams = ["page_type": self.pageTypeString(),
                                             "query_type": "filter",
                                             "enter_query": "be_null",
                                             "search_query": "be_null"]
                    
                    
                    let parmasMap = tracerParams.paramsGetter([:])
                    let userInfo = TTRouteUserInfo(info: ["tracer": parmasMap,
                                                          "houseSearch": houseSearchParams])
                    
                    TTRoute.shared().openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
                }.disposed(by: disposeBag)
    }

    fileprivate func cleanAllDatasourceHistoryCache() {
        self.houseFilterDataSource.forEach { (e) in
            let (_, value) = e
            value.history.accept(nil)
        }
    }


    fileprivate func handleScroll(houseType: HouseType) {
        self.contentOffsetDisposeBag = DisposeBag()
        if let collectionView = self.houseFilterCollectionView[houseType] {
            collectionView.rx.contentOffset.bind { [unowned self, unowned collectionView] (point) in
                self.seperateLineView.isHidden = (point.y - 0.5 <= -collectionView.contentInset.top)
            }.disposed(by: contentOffsetDisposeBag!)
        }
//        self.houseFilterCollectionView[houseType]?.rx.contentOffset
//            .subscribe(onNext : { [unowned self] (point) in
//                self.seperateLineView.isHidden = (point.y - 0.5 <= -self.collectionView.contentInset.top)
//            }
//        )
//        .disposed(by: contentOffsetDisposeBag!)

    }

    fileprivate func registerCollectionViewComponent(collectionView: UICollectionView) {
        collectionView.register(HouseFindHistoryCollectionCell.self, forCellWithReuseIdentifier: "history")
        collectionView.register(
                BubbleCollectionCell.self,
                forCellWithReuseIdentifier: "item")
        collectionView.register(PriceInputCell.self, forCellWithReuseIdentifier: "price-\(HouseType.neighborhood)")
        collectionView.register(PriceInputCell.self, forCellWithReuseIdentifier: "price-\(HouseType.secondHandHouse)")
        collectionView.register(PriceInputCell.self, forCellWithReuseIdentifier: "price-\(HouseType.newHouse)")
        collectionView.register(PriceInputCell.self, forCellWithReuseIdentifier: "price-\(HouseType.rentHouse)")

        collectionView.register(
                BubbleCollectionSectionHeader.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "header")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestHistory()

        self.theThresholdTracer = thresholdTracer()
        self.stayTabParams = TracerParams.momoid() <|>
            toTracerParams("find", key: "tab_name") <|>
            toTracerParams("click_tab", key: "enter_type") <|>
            toTracerParams("0", key: "with_tips") <|>
            traceStayTime()
        adjustVerticalPositionToTop()
        NotificationCenter.default.post(name: .findHouseHistoryCellReset, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.theThresholdTracer?(TraceEventName.stay_tab, self.stayTabParams)
    }

    fileprivate func adjustVerticalPositionToTop() {
        self.houseFilterCollectionView[houseType.value]?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 100, height: 100), animated: false)
    }

    fileprivate func requestHistory(houseType: String? = nil) {
        let htypeIntValue = houseType != nil ? Int(houseType!) : self.houseType.value.rawValue
        let htype = HouseType(rawValue: htypeIntValue ?? self.houseType.value.rawValue) ?? self.houseType.value
        requestSearchHistory(houseType: (houseType == nil ? "\(self.houseType.value.rawValue)" : houseType!))
            .subscribe(onNext: {[unowned self] (payload) in
                let dataSource = self.dataSourceByHouseType(houseType: htype)
                dataSource.history.accept(payload)
                self.houseFilterCollectionView[htype]?.reloadData()
            }, onError: { (error) in
//                print(error)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func requestDeleteHistory() {
        let houseType = self.houseType.value
        let houseTypeStr = "\(houseType.rawValue)"
        if EnvContext.shared.client.reachability.connection == .none {
            EnvContext.shared.toast.showToast("网络异常")
        } else {
            requestDeleteSearchHistory(houseType: houseTypeStr)
                .subscribe(onNext: { [unowned self] (payload) in
                    let dataSource = self.dataSourceByHouseType(houseType: houseType)
                    dataSource.history.accept(nil)
                    self.houseFilterCollectionView[houseType]?.reloadData()
                    //                EnvContext.shared.toast.showToast("历史记录删除成功")
                    }, onError: { (error) in
//                        print(error)
                        EnvContext.shared.toast.showToast("历史记录删除失败")
                })
                .disposed(by: disposeBag)
        }
    }

    fileprivate func dataSourceByHouseType(houseType: HouseType) -> CollectionDataSource {
        if let dataSource = houseFilterDataSource[houseType] {
            return dataSource
        } else {
            let dataSource = CollectionDataSource(houseType: houseType)
            houseFilterDataSource[houseType] = dataSource
            return dataSource
        }
    }

    // 记录 click_house_search
    fileprivate func recordClickHouseSearch() {
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams("findtab_search", key: "origin_from") <|>
            beNull(key: "origin_search_id")
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams(pageTypeString(), key: "page_type") <|>
        toTracerParams("be_null", key: "hot_word")
        recordEvent(key: "click_house_search", params: params)
    }

    fileprivate func pageTypeString() -> String {
        switch self.houseType.value {
        case .neighborhood:
            return "findtab_neighborhood"
        case .newHouse:
            return "findtab_new"
        default:
            return "findtab_old"
        }
    }
}

fileprivate func searchConfigByHouseType(
        configData: SearchConfigResponseData,
        houseType: HouseType) -> [SearchConfigFilterItem] {
    switch houseType {
    case .newHouse:
        return configData.searchTabCourtFilter ?? []
    case .neighborhood:
        return configData.searchTabNeighborHoodFilter ?? []
    case .rentHouse:
        return configData.searchTabRentFilter ?? []
    default:
        return configData.searchTabFilter ?? []
    }
}

fileprivate class CollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var hasHistory: Bool {
        get {
            return history.value?.data?.data?.count ?? 0 != 0
        }
    }

    fileprivate let history = BehaviorRelay<SearchHistoryResponse?>(value: nil)

    var priceNodeItem: SearchConfigFilterItem? = nil

    var items: [ItemState] = []

    var priceInputCell: PriceInputCell?

    let houseType: HouseType

    let disposeBag = DisposeBag()

    var deleteDisposeBag = DisposeBag()

    var deleteHistory: (() -> Void)?

    var nodes: [Node] = [] {
        didSet {
            items = nodes.map(transferNodeToItem)
        }
    }

    fileprivate var selectedIndexPaths: Set<IndexPath> = []
    
    init(houseType: HouseType) {
        self.houseType = houseType
        super.init()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if hasHistory {
            return nodes.count + 2
        }
        return nodes.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasHistory && section < 2 {
            return 1
        } else if section == 0 {
            return 1
        } else {
            return nodes[nodeSectionOffset(by: section)].children.count
        }
    }

    func nodeSectionOffset(by section: Int) -> Int {
        let sectionIndex = section - (hasHistory ? 2 : 1)
        return sectionIndex
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseidentiferOf(indexPath), for: indexPath)
        if let theCell = cell as? BubbleCollectionCell {
            let section = nodeSectionOffset(by: indexPath.section)
            let item = self.items[section].children[indexPath.row]
            theCell.label.text = item.node.label
            theCell.isSelected = item.isSelected
        } else if let theCell = cell as? HouseFindHistoryCollectionCell {
            theCell.historyItem.accept(history.value?.data?.data ?? [])
        } else if let theCell = cell as? PriceInputCell {
            self.priceInputCell = theCell
        }
        return cell
    }

    private func reuseidentiferOf(_ indexPath: IndexPath) -> String {
        if hasHistory {
            if indexPath.section == 0 {
                return "history"
            } else if indexPath.section == 1 {
                return "price-\(houseType)"
            } else {
                return "item"
            }
        } else {
            if indexPath.section == 0 {
                return "price-\(houseType)"
            } else {
                return "item"
            }
        }
    }

    func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        if let theHeaderView = headerView as? BubbleCollectionSectionHeader {
            if hasHistory {
                if indexPath.section == 0 {
                    theHeaderView.label.text = "搜索历史"
                    theHeaderView.deleteBtn.isHidden = false
                    deleteDisposeBag = DisposeBag()
                    theHeaderView.deleteBtn.rx.tap
                        .throttle(2, latest: false, scheduler: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] () in
                            self?.deleteHistory?()
                        }).disposed(by: deleteDisposeBag)
                } else if indexPath.section == 1 {
                    theHeaderView.label.text = self.priceNodeItem?.text
                } else {
                    let section = nodeSectionOffset(by: indexPath.section)
                    let item = self.items[section].node
                    theHeaderView.label.text = item.label
                }
            } else {
                if indexPath.section == 0 {
                    theHeaderView.label.text = self.priceNodeItem?.text
                } else {
                    let section = nodeSectionOffset(by: indexPath.section)
                    let item = self.items[section].node
                    theHeaderView.label.text = item.label
                }
            }
        }
        return headerView
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if hasHistory && indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        } else if (hasHistory && indexPath.section == 1) || indexPath.section == 0  { //有历史数据时的第二行，或者无历史数据的第一行
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 36)
        }
        return CGSize(width: 74, height: 30)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if hasHistory && indexPath.section < 2 {
            return
        } else if indexPath.section == 0 {
            return
        }

        let section = nodeSectionOffset(by: indexPath.section)
        if items[section].node.isSupportMulti != true {
            //单选操作

            items[section].children.enumerated().forEach { (offset, it) in
                if indexPath.row != offset {
                    it.isSelected = false
                } else {
                    it.isSelected = !it.isSelected
                }
            }
        } else {
            let item = items[section].children[indexPath.row]
            item.isSelected = !item.isSelected
        }


        collectionView.reloadData()
    }

    func selectedNode() -> [Node] {
        return items.reduce([], { (result, item) -> [Node] in
            var result = result
            result = result + item.children.filter { $0.isSelected }.map { $0.node }
            return result
        })
    }

    //手动输入价格的条件拼接和处理，需要确保用户输入的
    func priceCondition() -> String? {
        if let priceItem = self.priceNodeItem?.options?.first,
            let priceInputCell = self.priceInputCell {

            let rate: Int = self.priceNodeItem?.rate ?? 1
            let e = (Int(priceInputCell.leftPriceInput.text ?? "0"), Int(priceInputCell.rightPriceInput.text ?? "0"))
            switch e {
            case let (left, nil) where left != nil:
                return "\(priceItem.type ?? "price")[]=[\(left! * rate)]"
            case let (nil, right) where right != nil:
                return "\(priceItem.type ?? "price")[]=[0,\(right! * rate)]"
            case (nil, nil):
                return nil
            case let (left, right) where left! > right!:
                return "\(priceItem.type ?? "price")[]=[\(right! * rate),\(left! * rate)]"
            case let (left, right) where left! <= right!:
                return "\(priceItem.type ?? "price")[]=[\(left! * rate),\(right! * rate)]"

            default:
                print("default")
            }
            return "\(priceItem.type ?? "price")[]=[]"
        }
        return nil
    }

}

fileprivate class PriceInputCell: UICollectionViewCell, UITextFieldDelegate {

    lazy var leftPriceInputBg: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        return re
    }()

    lazy var leftPriceInput: UITextField = {
        let re = UITextField()
        re.placeholder = "最低价"
        re.keyboardType = .numberPad
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")


        return re
    }()

    lazy var rightPriceInputBg: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        return re
    }()

    lazy var rightPriceInput: UITextField = {
        let re = UITextField()
        re.placeholder = "最高价"
        re.keyboardType = .numberPad
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")

        return re
    }()

    lazy var lineView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.backgroundColor = hexStringToUIColor(hex: "#d1d4d6")
        re.layer.cornerRadius = 0.5
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        leftPriceInput.delegate = self
        rightPriceInput.delegate = self

        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.equalTo(11)
            maker.height.equalTo(1)
        }

        contentView.addSubview(leftPriceInputBg)
        leftPriceInputBg.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.right.equalTo(lineView.snp.left).offset(-6)
        }

        leftPriceInputBg.addSubview(leftPriceInput)
        leftPriceInput.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.top.bottom.equalToSuperview()
         }

        contentView.addSubview(rightPriceInputBg)
        rightPriceInputBg.snp.makeConstraints { maker in
            maker.right.top.bottom.equalToSuperview()
            maker.left.equalTo(lineView.snp.right).offset(6)
         }

        rightPriceInputBg.addSubview(rightPriceInput)
        rightPriceInput.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.top.bottom.equalToSuperview()
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String) -> Bool {

        if (range.length == 1 && string.count == 0) {
            return true
        } else if (textField.text?.count ?? 0 >= 9) {
            return false
        } else if Int(string) == nil {
            return false
        } else if  (textField.text?.count ?? 0 + string.count >= 9) {
            return false
        }
        return true
    }
}

fileprivate class ItemState {
    var isSelected: Bool
    let node: Node
    var children: [ItemState]

    init(
        isSelected: Bool,
        node: Node,
        children: [ItemState]) {
        self.isSelected = isSelected
        self.node = node
        self.children = children
    }
}

fileprivate func transferNodeToItem(node: Node) -> ItemState {
    let children = node.children.map(transferNodeToItem)
    return ItemState(isSelected: false, node: node, children: children)
}

