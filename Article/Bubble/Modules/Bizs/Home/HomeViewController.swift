//
//  HomeViewController.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Reachability
class HomeViewController: BaseViewController, UITableViewDelegate {

    private var tableView: UITableView!

    private var navBar: BubbleNavigationBar!

    private let dataSource: HomeViewTableViewDataSource!

    private let sectionHeader: CGFloat = 38

    let disposeBag = DisposeBag()

    private lazy var infoDisplay: EmptyMaskView = {
        let re = EmptyMaskView()
        return re
    }()

    lazy var headerViewPanel: UIView = {
        UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.frame.width,
                height: 211))
    }()

    lazy var suspendSearchBar: HomePageSearchPanel = {
        let result = HomePageSearchPanel(frame: CGRect.zero)
        result.layer.shadowRadius = 4
        result.layer.shadowColor = hexStringToUIColor(hex: "#000000").cgColor
        result.layer.shadowOffset = CGSize(width: 0, height: 4)
        result.layer.shadowOpacity = 0.06
        return result
    }()

    lazy var homeSpringBoard: HomeSpringBoard = {
        HomeSpringBoard()
    }()

    let barStyle = BehaviorRelay<Int>(value: UIStatusBarStyle.lightContent.rawValue)

    var homeSpringBoardViewModel: HomeSpringBoardViewModel!

    private var detailPageViewModel: HomeListViewModel?

    private var cycleImagePageableViewModel: PageableViewModel?

    private var stateControl: HomeHeaderStateControl?

    lazy var tapGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer()
    }()

    private var homePageCommonParams: TracerParams = TracerParams.momoid()

    private var stayTabParams = TracerParams.momoid()
    private var theThresholdTracer: ((String, TracerParams) -> Void)?

    init() {
        self.dataSource = HomeViewTableViewDataSource()
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        barStyle
                .bind { [unowned self] i in
                    self.ttStatusBarStyle = i
                    self.ttNeedChangeNavBar = true
                }
                .disposed(by: disposeBag)

        homePageCommonParams = EnvContext.shared.homePageParams <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams("maintab", key: "enter_from") <|>
            toTracerParams("maintab_icon", key: "element_from") <|>
            toTracerParams("icon", key: "maintab_entrance") <|>
            beNull(key: "filter") <|>
            beNull(key: "log_pb") <|>
            beNull(key: "maintab_search") <|>
            beNull(key: "operation_name") <|>
            beNull(key: "card_type") <|>
            beNull(key: "icon_type") <|>
            beNull(key: "search")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.tableView = UITableView()
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false
        self.detailPageViewModel = HomeListViewModel(tableView: tableView, navVC: self.navigationController)
        self.detailPageViewModel?.homePageCommonParams = homePageCommonParams
        self.setupPageableViewModel()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clear
        setupErrorDisplay()

        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(4)
            } else {
                maker.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
            }
        }
        registerCell(tableView)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        let reloadObv = Observable.combineLatest(
                EnvContext.shared.client.configCacheSubject,
                EnvContext.shared.client.generalBizconfig.currentSelectCityId)
        reloadObv
                .filter { $0.1 != nil }
                .map { _ in 0 }
                .bind(onNext: detailPageViewModel!.requestData)
                .disposed(by: disposeBag)
        setupNormalNavBar()

        let stateControl = HomeHeaderStateControl()
        self.stateControl = stateControl
        stateControl.onStateChanged = { (state) in
            switch state {
            case .suspend:
                UIView.animate(withDuration: 0.3, animations: {
                    self.navBar.isHidden = true
                    self.suspendSearchBar.isHidden = false
                    self.barStyle.accept(UIStatusBarStyle.lightContent.rawValue)
                    UIApplication.shared.statusBarStyle = .lightContent
                })
            default:
                UIView.animate(withDuration: 0.3, animations: {
                    self.navBar.isHidden = false
                    self.suspendSearchBar.isHidden = true
                    self.barStyle.accept(UIStatusBarStyle.default.rawValue)
                    UIApplication.shared.statusBarStyle = .default
                })
            }
        }

        tableView.rx.contentOffset
                .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
                .disposed(by: disposeBag)
        bindSearchEvent()

        let generalBizConfig = EnvContext.shared.client.generalBizconfig
        generalBizConfig.currentSelectCityId
                .map(generalBizConfig.cityNameById())
                .subscribe(onNext: { [unowned self] (city) in
                    if let city = city {
                        self.suspendSearchBar.countryLabel.text = city
                        self.navBar.suspendSearchBar.countryLabel.text = city
                    } else {
                        let defaultStr = "选择城市"
                        self.suspendSearchBar.countryLabel.text = defaultStr
                        self.navBar.suspendSearchBar.countryLabel.text = defaultStr
                    }
                })
                .disposed(by: disposeBag)
        bindNetReachability()
    }

    private func setupErrorDisplay() {
        view.addSubview(infoDisplay)
        infoDisplay.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
        }
    }
    
    private func setupPageableViewModel() {
        let pageableViewModel = PageableViewModel(cacheViewCount: 5) {
            return BDImageViewProvider { [weak self] i in
                let selectedImage = self?.bannerImgSelector(index: i) ?? ""
                return selectedImage
            }
        }
        //添加点击手势
        pageableViewModel.pageView.addGestureRecognizer(tapGesture)

        pageableViewModel.pageView.isUserInteractionEnabled = true
        headerViewPanel.addSubview(pageableViewModel.pageView)
        pageableViewModel.pageView.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
            maker.height.equalTo(211)
         }
        cycleImagePageableViewModel = pageableViewModel
        pageableViewModel.reloadData(currentPageOnly: false)
        EnvContext.shared.client.generalBizconfig.generalCacheSubject
                .subscribe(onNext: { [weak pageableViewModel] data in
                    if let banners = data?.banners, banners.count > 1 {

                    } else {
                        pageableViewModel?.pageView.isScrollEnabled = false
                    }
                    pageableViewModel?.reloadData(currentPageOnly: false)
                })
                .disposed(by: disposeBag)
        tapGesture.rx.event
                .withLatestFrom(pageableViewModel.currentPage.asObservable())
                .bind(onNext: { (offset) in
                    let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
                    if let banners = config?.banners {
                        let count  = banners.count
                        if count > 0 {
                            let index = offset % count
                            let item = banners[index]
                            if let url = item.url {
                                TTRoute.shared().openURL(byPushViewController: URL(string: "\(url)&hide_more=1"))
                            }
                        }
                    }
                })
                .disposed(by: disposeBag)
    }

    func bannerImgSelector(index: Int) -> String {
        let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
        let count  = config?.banners?.count ?? 0
        if let banners = config?.banners {
            if count > 0 {
                return banners[index % count].image?.url ?? ""
            }
        }
        return ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView = headerViewPanel
        setupHeaderSlidePanel(tableView: tableView)
    }

    private func setupNormalNavBar() {
        navBar = BubbleNavigationBar()
        navBar.isHidden = true
        self.view.addSubview(navBar)
        navBar.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
            } else {
                maker.height.equalTo(65)
            }
            maker.top.left.right.equalToSuperview()
        }
    }

    private func setupHeaderSlidePanel(tableView: UITableView) {
        headerViewPanel.addSubview(suspendSearchBar)
        suspendSearchBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(48)
            } else {
                maker.top.equalTo(25)
            }

            maker.centerX.equalToSuperview()

            maker.height.equalTo(40)
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
        }
    }

    private func registerCell(_ tableView: UITableView) {
        let cellTypeMap: [String: UITableViewCell.Type] = ["item": SingleImageInfoCell.self]
        cellTypeMap.forEach { (e) in
            let (identifier, cls) = e
            tableView.register(cls, forCellReuseIdentifier: identifier)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        EnvContext.shared.homePageParams = TracerParams.momoid() <|>
            beNull(key: "filter") <|>
            beNull(key: "maintab_search") <|>
            beNull(key: "operation_name") <|>
            beNull(key: "icon_type") <|>
            beNull(key: "element_from") <|>
            beNull(key: "maintab_entrance") <|>
            beNull(key: "enter_from") <|>
            beNull(key: "search")
        self.homePageCommonParams = self.homePageCommonParams <|>
            EnvContext.shared.homePageParams

        self.theThresholdTracer = thresholdTracer()
        self.stayTabParams = TracerParams.momoid() <|>
                toTracerParams("main", key: "tab_name") <|>
                toTracerParams("click_tab", key: "enter_type") <|>
                toTracerParams("0", key: "with_tips") <|>
                traceStayTime()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.theThresholdTracer?(TraceEventName.stay_tab, self.stayTabParams)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.navigationController?.topViewController == self {
            self.tabBarController?.tabBar.isHidden = false
            if let navVC = self.navigationController as? TTNavigationController {
                navVC.removeTabBarSnapshot(forSuperView: self.view)
            }
        }
    }

    private func bindSearchEvent() {
        suspendSearchBar.changeCountryBtn.rx.tap
                .subscribe(onNext: openCountryList)
                .disposed(by: disposeBag)
        suspendSearchBar.searchBtn.rx.tap
                .subscribe(onNext: openSearchPanel)
                .disposed(by: disposeBag)
        navBar.suspendSearchBar.changeCountryBtn.rx.tap
                .subscribe(onNext: openCountryList)
                .disposed(by: disposeBag)
        navBar.suspendSearchBar.searchBtn.rx.tap
                .subscribe(onNext: openSearchPanel)
                .disposed(by: disposeBag)
    }
    
    private func bindNetReachability() {
        let generalBizConfig = EnvContext.shared.client.generalBizconfig
        Observable
            .combineLatest(Reachability.rx.isReachable, generalBizConfig.generalCacheSubject)
            .map { (e) -> Bool in
                let (reach, generalconfig) = e
                return reach == false && generalconfig == nil
            }
            .bind(onNext: displayNetworkError())
            .disposed(by: disposeBag)
        
    }

    private func displayNetworkError() -> (Bool) -> Void {
        return { [weak self] (isDisplay) in
            self?.cycleImagePageableViewModel?.pageView.isHidden = isDisplay
            self?.infoDisplay.isHidden = !isDisplay
            self?.infoDisplay.label.text = "网络不给力，点击屏幕重试"
            self?.stateControl?.disable = isDisplay
            UIApplication.shared.statusBarStyle = .default
            self?.barStyle.accept(UIStatusBarStyle.default.rawValue)
        }
    }
}


extension HomeViewController {
    private func openCountryList() {
        let vc = CountryListVC()
        vc.onClose = { _ in
            self.navigationController?.popViewController(animated: true)
        }
        vc.onItemSelect
                .subscribe(onNext: { i in
                    EnvContext.shared.client.generalBizconfig.currentSelectCityId.accept(i)
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: self.disposeBag)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func openSearchPanel() {
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams("search", key: "element_from") <|>
                toTracerParams("search", key: "maintab_entrance") <|>
                beNull(key: "operation_name") <|>
                beNull(key: "maintab_search") <|>
                beNull(key: "icon_type")
        let vc = SuggestionListVC()
        let nav = self.navigationController
        nav?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { [weak nav] void in
                    nav?.popViewController(animated: true)
                })
                .disposed(by: self.disposeBag)
        vc.onSuggestSelect = { [weak self, unowned vc] (query, condition, associationalWord) in
            self?.openCategoryList(
                houseType: vc.houseType.value,
                condition: condition ?? "",
                    query: query,
                associationalWord: associationalWord)
        }
    }


    private func openCategoryList(
        houseType: HouseType,
        condition: String,
            query: String,
        associationalWord: String? = nil) {
        let vc = CategoryListPageVC(
            isOpenConditionFilter: true,
            associationalWord: associationalWord)
        vc.houseType.accept(houseType)
        vc.suggestionParams = condition
        vc.queryString = query
        vc.navBar.isShowTypeSelector = false
        vc.navBar.searchInput.placeholder = searchBarPlaceholder(houseType)
        let nav = self.navigationController
        nav?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    nav?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
    }
}

func searchBarPlaceholder(_ houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "请输入楼盘名/地址"
    case .neighborhood:
        return "请输入小区/商圈/地铁"
    case .secondHandHouse:
        return "请输入小区/商圈/地铁"
    default:
        return ""
    }
}

class BubbleNavigationBar: UIView {

    lazy var suspendSearchBar: HomePageSearchPanel = {
        let result = HomePageSearchPanel(frame: CGRect.zero, isHighlighted: true)
        result.isHighlighted = true
        return result
    }()

    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#d8d8d8")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(suspendSearchBar)
        suspendSearchBar.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }

        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(0.5)
         }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
