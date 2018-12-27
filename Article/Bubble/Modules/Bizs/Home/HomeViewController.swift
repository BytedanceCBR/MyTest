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
class HomeViewController: BaseViewController, UIViewControllerErrorHandler {

    let tipViewHeight: CGFloat = 32
    
    private var tableView: UITableView!

    private let dataSource: HomeViewTableViewDataSource!

    private let sectionHeader: CGFloat = 38

    let disposeBag = DisposeBag()

    private lazy var infoDisplay: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()
    
    private var errorVM : NHErrorViewModel!

    @objc var reloadFromType: TTReloadType = TTReloadTypeNone

    lazy var homeSpringBoard: HomeSpringBoard = {
        HomeSpringBoard()
    }()

    let barStyle = BehaviorRelay<Int>(value: UIStatusBarStyle.default.rawValue)

    var homeSpringBoardViewModel: HomeSpringBoardViewModel!

    private var detailPageViewModel: HomeListViewModel?

    lazy var tapGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer()
    }()

    private var homePageCommonParams: TracerParams = TracerParams.momoid()
    
    var stayTimeParams: TracerParams = TracerParams.momoid()
    
    var isClickTab: Bool = false
    
    var enterType: String?
    
    var notifyBar: ArticleListNotifyBarView?

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
            beNull(key: "filter") <|>
            beNull(key: "log_pb") <|>
            beNull(key: "maintab_search") <|>
            beNull(key: "card_type") <|>
            beNull(key: "icon_type") <|>
            beNull(key: "search")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedRowHeight = 0
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0
        self.tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.1)) //to do:设置header0.1，防止系统自动设置高度
        self.tableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.1)) //to do:设置header0.1，防止系统自动设置高度

        self.detailPageViewModel = HomeListViewModel(tableView: tableView, navVC: self.navigationController)
        self.detailPageViewModel?.homePageCommonParams = homePageCommonParams
        self.errorVM = NHErrorViewModel(
            errorMask:infoDisplay,
            requestRetryText:"网络不给力，试试刷新页面",
            requestNilDataText:"当前城市暂未开通，敬请期待～",
            requestNilDataImage:"group-9",
            requestErrorText: "数据异常",
            requestErrorImage: "group-8",
            isUserClickEnable: true,
            retryAction: { [weak self] in
                    if EnvContext.shared.client.reachability.connection == .none {
                        EnvContext.shared.toast.showToast("网络不给力,请稍后重试")
                    }else
                    {
                        EnvContext.shared.client.generalBizconfig.fetchConfiguration()
                    }
            })
        
        self.detailPageViewModel?.onError = { [weak self] (error) in
            //天真说:首页很关键，大部分时候都要显示点击重试
            self?.infoDisplay.isHidden = false
            self?.infoDisplay.label.text = "网络不给力，点击屏幕重试"
        }
        
        self.detailPageViewModel?.endTTUpdateCallBack = { [weak self] in
            self?.tt_endUpdataData()
        }
        
        self.detailPageViewModel?.onSuccess = {
            [weak self] (successType) in
            if(successType == .requestSuccessTypeNormal)
            {
                self?.errorVM?.onRequestNormalData()
            }else if (successType == .requestSuccessTypeNoData)
            {
                self?.errorVM?.onRequestNilData()
            }else if (successType == .requestSuccessTypeDataError)
            {
                self?.errorVM?.onRequestError(error: nil)
            }else
            {
                //天真说:首页很关键，大部分时候都要显示点击重试
                self?.infoDisplay.isHidden = false
                self?.infoDisplay.label.text = "网络不给力，点击屏幕重试"
            }
        }
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.backgroundColor = UIColor.clear

        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
//            maker.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
            maker.bottom.equalToSuperview()

        }
        registerCell(tableView)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
                
        self.automaticallyAdjustsScrollViewInsets = false

        bindNetReachability()
        setupErrorDisplay()
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationWillEnterForeground)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .delay(5, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                TTLaunchTracer.shareInstance().writeEvent()
            })
        
        
        let notifyBar = ArticleListNotifyBarView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 500, height: tipViewHeight))
        self.notifyBar = notifyBar
        view.insertSubview(notifyBar, aboveSubview: tableView)
        self.detailPageViewModel?.showTips = showTips()
        
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = .white
        
        if EnvContext.shared.client.generalBizconfig.searchConfigCache?.containsObject(forKey: "config") ?? false {
            self.tt_endUpdataData()
            self.tableView.isHidden = false
        }else
        {
            self.tt_startUpdate()
            self.tableView.isHidden = true
        }
    }
    
    
    

    @objc  func setListTopInset(_ topInset: CGFloat, BottomInset: CGFloat) {
        
        self.ttContentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
    }
    
    // TODO: add by zjing
    @objc func prepareForReuse() {
        
//    self.isClickCellLeaveList = NO;
//    [self.listVideoModel reset];
//    self.listVideoModel = [[TTVFeedListViewModel alloc] init];
//    self.listVideoModel.isVideoTabCategory = self.isVideoTabCategory;
//    self.toBeUpdatedListItemMapTable = [NSMapTable weakToStrongObjectsMapTable];
//    //    [self willAppear];
//    [self creatrePreloadManager];
//    [self resetScrollView];
//    [self reloadListView];
    }
    @objc func pullAndRefresh() {

        detailPageViewModel?.reloadFromType = reloadFromType
        tableView.triggerPullDown()
    }
    
    @objc func scrollToTopEnable(_ enable: Bool) {
        
        tableView.scrollsToTop = enable
    }

    @objc func scrollToTopAnimated(_ animated: Bool) {
        tableView.setContentOffset(CGPoint.zero, animated: animated)
    }
    
    @objc func clearListContent() {
        
    }
    
    @objc func willAppear() {
        enterType = TTCategoryStayTrackManager.share().enterType
        self.detailPageViewModel?.isCurrentShowHome = true

        if FHHomeConfigManager.sharedInstance().isNeedTriggerPullDownUpdateFowFindHouse {
            self.tableView?.triggerPullDown()
            FHHomeConfigManager.sharedInstance().isNeedTriggerPullDownUpdateFowFindHouse = false
        }
    }
    
    @objc func didAppear() {
        
        stayTimeParams = TracerParams.momoid() <|> traceStayTime()
        reloadHomeTabBarItem(detailPageViewModel?.isShowTop ?? false)

    }
    
    @objc func willDisappear() {
        self.detailPageViewModel?.isCurrentShowHome = false
    }
    
    @objc func didDisappear() {

        let theEnterType = FHHomeConfigManager.sharedInstance().enterType
        self.detailPageViewModel?.uploadTracker(isWithStayTime:true, stayTime: stayTimeParams,enterType: theEnterType as NSString?, currentHouseType: self.detailPageViewModel?.stayHouseTraceType ?? .neighborhood)
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            reloadHomeTabBarItem(detailPageViewModel?.isShowTop ?? false)
        }else {
            reloadHomeTabBarItem(false)
        }
    }

    
    private func setupErrorDisplay() {
        if !view.subviews.contains(infoDisplay)
        {
            infoDisplay.isHidden = true
            view.addSubview(infoDisplay)
            infoDisplay.snp.makeConstraints { maker in
                maker.top.left.right.equalToSuperview()
                if CommonUIStyle.Screen.isIphoneX
                {
                    maker.bottom.equalToSuperview().offset(0)
                }else
                {
                    maker.bottom.equalToSuperview().offset(-CommonUIStyle.TabBar.height)
                }
            }
        }
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

    private func registerCell(_ tableView: UITableView) {
        let cellTypeMap: [String: UITableViewCell.Type] = ["item": SingleImageInfoCell.self,"FHPlaceholderCell":FHPlaceholderCell.self,"SpringBroadCell":SpringBroadCell.self]
        cellTypeMap.forEach { (e) in
            let (identifier, cls) = e
            tableView.register(cls, forCellReuseIdentifier: identifier)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

        self.homePageCommonParams = self.homePageCommonParams <|>
            EnvContext.shared.homePageParams

        self.theThresholdTracer = thresholdTracer()
        self.stayTabParams = TracerParams.momoid() <|>
                toTracerParams("main", key: "tab_name") <|>
                toTracerParams(isClickTab ? "click_tab" : "default", key: "enter_type") <|>
                toTracerParams("0", key: "with_tips") <|>
                traceStayTime()
        self.view.bringSubview(toFront: infoDisplay)
        self.errorVM.onRequestViewDidLoad()

        EnvContext.shared.client.loadSearchCondition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.theThresholdTracer?(TraceEventName.stay_tab, self.stayTabParams)
        isClickTab = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.navigationController?.topViewController == self {
            //  暂时注释掉，也不是很好的解决办法
//            if let navVC = self.navigationController as? TTNavigationController {
//                navVC.removeTabBarSnapshot(forSuperView: self.view)
//            }
        }
        
        let originFrom = self.detailPageViewModel?.originFrom
        EnvContext.shared.homePageParams = TracerParams.momoid() <|>
            toTracerParams(originFrom ?? "be_null", key: "origin_from") <|>
            toTracerParams(self.detailPageViewModel?.originSearchId ?? "be_null", key: "origin_search_id")
        TTLaunchTracer.shareInstance().writeEvent()

        
        // add by zjing hard code 为了解决push到视频然后回首页状态栏被隐藏的问题
        UIApplication.shared.statusBarStyle = .default
        self.barStyle.accept(UIStatusBarStyle.default.rawValue)
        UIApplication.shared.isStatusBarHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(550)) {
            UIApplication.shared.isStatusBarHidden = false
        }
        
        self.detailPageViewModel?.homeViewControllerWillAppear()
    }
    
    func tt_hasValidateData() -> Bool {
        let isHasValidateData = EnvContext.shared.client.generalBizconfig.searchConfigCache?.containsObject(forKey: "config") ?? false
        return isHasValidateData
    }

    override var prefersStatusBarHidden: Bool {
        
        return false
    }
    
    private func bindNetReachability() {
        let generalBizConfig = EnvContext.shared.client.generalBizconfig
        Observable
            .combineLatest(Reachability.rx.isReachable, generalBizConfig.generalCacheSubject)
            .map { (e) -> Bool in
                let (reach, generalconfig) = e
                return reach == false || generalconfig == nil
            }
            .bind(onNext: displayNetworkError())
            .disposed(by: disposeBag)
        
    }

    private func displayNetworkError() -> (Bool) -> Void {
        return { [weak self] (isDisplay) in
            // add by zjing 会偷摸修改状态栏颜色，有问题找我，代码就这么被我注释掉了！！！
//            UIApplication.shared.statusBarStyle = .default
//            self?.barStyle.accept(UIStatusBarStyle.default.rawValue)
        }
    }
    
    fileprivate func showTips() -> (String) -> Void {
        return { [weak self] (message) in
            self?.notifyBar?.showMessage(
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
                    let height = self?.notifyBar?.height ?? 0
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.tableView.top = height
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        UIView.animate(withDuration: 0.3, animations: {
                            self?.tableView.top = 0
                        })
                        
                    })
                }
            }
            
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
                .subscribe(onNext: { [unowned self] i in
//                    EnvContext.shared.client.generalBizconfig.currentSelectCityId.accept(i)
//                    EnvContext.shared.client.generalBizconfig.setCurrentSelectCityId(cityId: i)
                    self.navigationController?.popViewController(animated: true)
                    EnvContext.shared.client.currentCitySwitcher
                        .switchCity(cityId: i)
//                        .filter({ () -> Bool in
//                            s == CitySwitcherState.onFinishedRequestFilterConfig || s == CitySwitcherState.onError
//                        })
                        .subscribe(onNext: { (state) in
                            switch state {
                            case .onFinishedRequestFilterConfig:
//                                self.navigationController?.popViewController(animated: true)
                                return
                            case .onError:
//                                self.navigationController?.popViewController(animated: true)
                                return
                            default:
                                return
                            }
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)
        self.navigationController?.pushViewController(vc, animated: true)
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
    case .rentHouse:
        return "请输入小区/商圈/地铁"
    default:
        return ""
    }
}

