//
//  HorseDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import Charts
import RxSwift
import RxCocoa
import Reachability

typealias DetailPageViewModelProvider = (UITableView, EmptyMaskView, UINavigationController?, String?) -> DetailPageViewModel

class HorseDetailPageVC: BaseViewController, TTRouteInitializeProtocol, TTShareManagerDelegate {
    fileprivate var pageFrameObv: NSKeyValueObservation?

    private let houseId: Int64
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var detailPageViewModel: DetailPageViewModel?

    var pageViewModelProvider: DetailPageViewModelProvider?

    var shareParams: TracerParams?
    let stateControl = HomeHeaderStateControl()
    
    var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
//        re.rightBtn.isHidden = false
        re.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-white"), for: .normal)
        re.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: .selected)
        re.rightBtn.adjustsImageWhenHighlighted = false
        re.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: [.highlighted, .selected]) //按钮isSelected状态时再次点击
        re.rightBtn2.isHidden = false
        re.rightBtn2.setImage(#imageLiteral(resourceName: "ic-navigation-share-white"), for: .normal)

        return re
    }()

    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.rowHeight = UITableViewAutomaticDimension
        result.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        result.separatorStyle = .none
        result.contentInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()

    private lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()
    
    private lazy var bottomStatusBar: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = hexStringToUIColor(hex: "#000000", alpha: 0.7)
        label.text = "该房源已停售"
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = .white
        return label
    }()
    

    let barStyle = BehaviorRelay<Int>(value: UIStatusBarStyle.lightContent.rawValue)

    var isShowBottomBar: Bool

    weak var quickLoginVM: QuickLoginAlertViewModel?

    lazy var shareManager: TTShareManager = {
        let re = TTShareManager()
        re.delegate = self
        return re
    }()

//    weak var alert: BubbleAlertController?
    
    var isShowFollowNavBtn = false

    var traceParams = TracerParams.momoid()

    var stayPageParams: TracerParams? = TracerParams.momoid()

    private var netStateInfoVM : NHErrorViewModel?

    var sameNeighborhoodFollowUp = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()

    var logPB: [String: Any]?
    var searchId: String?

    var houseSearchParams: TracerParams? {
        didSet {
            if let houseSearchParams = houseSearchParams {
                houseSearchParamsStay = houseSearchParams <|>
                    traceStayTime()
            }
        }
    }

    var houseSearchParamsStay: TracerParams?


    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = true,
         isShowFollowNavBtn: Bool = false,
         provider: @escaping DetailPageViewModelProvider) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        self.pageViewModelProvider = provider

        super.init(nibName: nil, bundle: nil)

        self.netStateInfoVM = NHErrorViewModel(
            errorMask: infoMaskView,
            requestRetryText:"网络异常",
            isUserClickEnable:false)

        if houseType == HouseType.neighborhood && CommonUIStyle.Screen.isIphoneX {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)

        }
        self.automaticallyAdjustsScrollViewInsets = false

        navBar.rightBtn.isHidden = false
        barStyle
                .bind { [unowned self] i in
                    self.ttStatusBarStyle = i
                    self.ttNeedChangeNavBar = true
                }
                .disposed(by: disposeBag)
    }

    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        let (houseId, houseType) = HorseDetailPageVC.getHouseId(paramObj?.queryParams)
        self.houseId = Int64(houseId) ?? 0
        self.houseType = houseType
        self.isShowBottomBar = true
        super.init(nibName: nil, bundle: nil)
        self.pageViewModelProvider = getPageViewModelProvider(by: houseType)

        self.netStateInfoVM = NHErrorViewModel(
            errorMask: infoMaskView,
            requestRetryText: "网络异常",
            isUserClickEnable: false)

        if houseType == HouseType.neighborhood && CommonUIStyle.Screen.isIphoneX {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)

        }
        self.automaticallyAdjustsScrollViewInsets = false

        navBar.rightBtn.isHidden = false
        barStyle
            .bind { [unowned self] i in
                self.ttStatusBarStyle = i
                self.ttNeedChangeNavBar = true
            }
            .disposed(by: disposeBag)

        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        //TODO 增加push打开详情的original_from
    }

    static func getHouseId(_ dict: [AnyHashable: Any]?) -> (String, HouseType) {

        if let houseId = dict?["house_id"] {
            return (houseId as? String ?? "", HouseType.secondHandHouse)
        }

        if let courtId = dict?["court_id"] {
            return (courtId as? String ?? "", HouseType.newHouse)
        }

        if let neighborhoodId = dict?["neighborhood_id"] {
            return (neighborhoodId as? String ?? "", HouseType.neighborhood)
        }
        return ("", HouseType.secondHandHouse)
    }

    func getPageViewModelProvider(by houseType: HouseType) -> DetailPageViewModelProvider {
        switch houseType {
        case .secondHandHouse:
            return getErshouHouseDetailPageViewModel()
        case .newHouse:
            return { [unowned self] (tableView, infoMaskView, navVC, searchId) in
                let re = NewHouseDetailPageViewModel(tableView: tableView, infoMaskView: infoMaskView, navVC: navVC)
                re.searchId = searchId
                re.showQuickLoginAlert = { [weak self] (title, subTitle) in
                    self?.showQuickLoginAlert(title: title, subTitle: subTitle)
                }

                re.showFollowupAlert = { [unowned self] (title, subTitle) -> Observable<Void> in
                    return self.showFollowupAlert(title: title, subTitle: subTitle)
                }

                re.closeAlert = { [weak self] in
                    self?.closeAlertView()
                }
                return re
            }
        case .neighborhood:
            return getNeighborhoodDetailPageViewModel()
        default:
            return getErshouHouseDetailPageViewModel()
        }
    }


    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = true) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        navBar.rightBtn.isHidden = false

        super.init(nibName: nil, bundle: nil)

        self.netStateInfoVM = NHErrorViewModel(errorMask: infoMaskView, requestRetryText:"网络异常")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    fileprivate func bindNetStatusViewModel() {
        self.detailPageViewModel?.onNetworkError = { [weak self] (error) in
            self?.netStateInfoVM?.onRequestError(error: error)
        }
        self.detailPageViewModel?.onEmptyData = {
             [weak self] in
            self?.infoMaskView.label.text = "数据走丢了"
            self?.infoMaskView.icon.image = UIImage(named: "group-9")
            self?.infoMaskView.isHidden = false
        }
        self.detailPageViewModel?.onDataArrived = { [weak self] in
            self?.netStateInfoVM?.onRequestNormalData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.openANRMonitor(with: 0.5)
        view.backgroundColor = UIColor.white
        
        let detailPageParams = self.traceParams.paramsGetter([:])
        var searchId: String?
        if let logpb = detailPageParams["log_pb"] as? [String: Any]{
            searchId = logpb["search_id"] as? String
            var dictTracePara = traceParams.paramsGetter([:])
            if (dictTracePara["search_id"] != nil) && searchId == nil
            {
                searchId = (dictTracePara["search_id"] as! String)
            }
            self.searchId = searchId
            self.traceParams = self.traceParams <|> toTracerParams(searchId ?? "be_null", key: "search_id")
        }

        detailPageViewModel = pageViewModelProvider?(tableView, infoMaskView, self.navigationController, searchId)
        detailPageViewModel?.showMessageAlert = { [weak self] (message) in
            self?.showLoadingAlert(message: message)
        }
        detailPageViewModel?.dismissMessageAlert = { [weak self] in
            self?.dismissLoadingAlert()
        }
        detailPageViewModel?.traceParams = traceParams
        self.bindNetStatusViewModel()
        setupNavBar()

        //绑定二手房跳小区详情页followUp信号
        if let detailPageViewModel = detailPageViewModel as? ErshouHouseDetailPageViewModel {
            detailPageViewModel.sameNeighborhoodFollowUp.accept(self.sameNeighborhoodFollowUp.value)
            detailPageViewModel.sameNeighborhoodFollowUp
                .bind(to: self.sameNeighborhoodFollowUp)
                .disposed(by: disposeBag)
        }

        //绑定小区房源关注状态
        if let detailPageViewModel = detailPageViewModel as? NeighborhoodDetailPageViewModel {
            detailPageViewModel.followStatus
                .bind(to: self.sameNeighborhoodFollowUp)
                .disposed(by: disposeBag)
        }


        if isShowBottomBar {
            view.addSubview(bottomBar)
            bottomBar.snp.makeConstraints { maker in
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalToSuperview()
                }
                maker.left.right.equalToSuperview()
            }
        }
        
        view.addSubview(bottomStatusBar)
        bottomStatusBar.snp.makeConstraints { maker in
            maker.right.left.equalToSuperview()
            if isShowBottomBar {
                maker.bottom.equalTo(bottomBar.snp.top)
            } else {
                
                maker.bottom.equalToSuperview()
            }
            maker.height.equalTo(0)
        }
        bottomStatusBar.isHidden = true
        if  #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never;//UIScrollView也适用
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.right.left.equalToSuperview()
            maker.bottom.equalTo(bottomStatusBar.snp.top)
        }

        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.bottom.left.right.equalTo(view)
        }

        view.bringSubview(toFront: navBar)

        if EnvContext.shared.client.reachability.connection != .none {
            infoMaskView.isHidden = true
            netStateInfoVM?.onRequest()
            detailPageViewModel?.requestData(houseId: houseId, logPB: logPB, showLoading: true)
        }

        
        stateControl.onStateChanged = { [weak self] (state) in
            switch state {
            case .suspend:
                    self?.navBar.setGradientColor()
                    UIApplication.shared.statusBarStyle = .lightContent
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .highlighted)

                    self?.navBar.rightBtn2.setImage(#imageLiteral(resourceName: "ic-navigation-share-white"), for: .normal)
                    if let isSel = self?.navBar.rightBtn.isSelected
                    {
                        if !isSel
                        {
                            self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-white"), for: .normal)
                        }
                }
            default:
                    self?.navBar.removeGradientColor()
                    UIApplication.shared.statusBarStyle = .default
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .highlighted)

                    self?.navBar.rightBtn2.setImage(#imageLiteral(resourceName: "ic-navigation-share-dark"), for: .normal)
                    if let isSel = self?.navBar.rightBtn.isSelected
                    {
                        if !isSel
                        {
                            self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect"), for: .normal)
                        }
                    }
            }
        }
        stateControl.onContentOffsetChanged = { [weak self] (state, offset) in
            if state == .normal {
                let alpha = (1 - (139 - offset.y) / 139) * 2
                self?.navBar.alpha = alpha
                self?.barStyle.accept(UIStatusBarStyle.default.rawValue)
                UIApplication.shared.statusBarStyle = .default
            } else {
                self?.navBar.alpha = 1
                self?.barStyle.accept(UIStatusBarStyle.lightContent.rawValue)
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }

        tableView.rx.contentOffset
            .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
            .disposed(by: disposeBag)


        if let detailPageViewModel = detailPageViewModel {

            detailPageViewModel.followStatus
                .filter { [weak self] (result) -> Bool in
                    if case .success(_) = result {
                        return true
                    } else {
                       return false
                    }
                }
                .map { [weak self] (result) -> Bool in
                    
                    if self?.stateControl.state == .suspend
                    {
                        self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-white"), for: .normal)
                    }else
                    {
                        self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect"), for: .normal)
                    }
                    
                    if case let .success(status) = result {
                        return status
                    } else {

                        return false
                    }
                }
                .bind(to: navBar.rightBtn.rx.isSelected)
                .disposed(by: disposeBag)

            
            detailPageViewModel.contactPhone.skip(1).subscribe(onNext: { [weak self] contactPhone in
                
                var titleStr:String = "电话咨询"
                if let phone = contactPhone?.phone, phone.count > 0 {
                    
                    if self?.houseType == .secondHandHouse {
                        
                        self?.refreshSecondHouseBottomBar(contactPhone: contactPhone)
                    }
                    
                } else {

                    titleStr = "询底价"
                    
                }
                if self?.houseType == .neighborhood {
                    titleStr = "咨询经纪人"
                }
                
                self?.bottomBar.contactBtn.setTitle(titleStr, for: .normal)
                self?.bottomBar.contactBtn.setTitle(titleStr, for: .highlighted)

                
            })
                .disposed(by: disposeBag)
            
            if let ershouVM = detailPageViewModel as? ErshouHouseDetailPageViewModel, self.houseType == .secondHandHouse {
                
                ershouVM.houseStatus.skip(1).subscribe(onNext: { [weak self] houseStatus in

                    if let theHouseStatus = houseStatus, theHouseStatus == 1 {
                        self?.bottomStatusBar.isHidden = false
                        self?.navBar.rightBtn.isHidden = false
                        self?.navBar.rightBtn2.isHidden = false
                        self?.bottomStatusBar.snp.updateConstraints({ (maker) in
                            
                            maker.height.equalTo(30)
                        })

                    }else if let theHouseStatus = houseStatus, theHouseStatus == -1 {
                        self?.bottomStatusBar.isHidden = true
                        self?.navBar.rightBtn.isHidden = true
                        self?.navBar.rightBtn2.isHidden = true
                        self?.bottomStatusBar.snp.updateConstraints({ (maker) in
                            
                            maker.height.equalTo(0)
                        })
                    }else {
                        self?.bottomStatusBar.isHidden = true
                        self?.navBar.rightBtn.isHidden = false
                        self?.navBar.rightBtn2.isHidden = false
                        self?.bottomStatusBar.snp.updateConstraints({ (maker) in
                            
                            maker.height.equalTo(0)
                        })
                    }
                    
                })
                    .disposed(by: disposeBag)
            }
            
            bottomBar.contactBtn.rx.tap
                .withLatestFrom(detailPageViewModel.contactPhone)
                .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
                .bind(onNext: { [unowned self] (contactPhone) in

                    if let phone = contactPhone?.phone, phone.count > 0 {
                        
                        var theImprId: String?
                        var theSearchId: String?

                        if let logPB = self.detailPageViewModel?.logPB as? [String: Any], let imprId = logPB["impr_id"] as? String, let searchId = self.detailPageViewModel?.searchId {
                            theImprId = imprId
                            theSearchId = searchId

                        }
                        self.detailPageViewModel?.callRealtorPhone(contactPhone: contactPhone, houseId: self.houseId, houseType: self.houseType, searchId: theSearchId ?? "", imprId: theImprId ?? "", disposeBag: self.disposeBag)
                        self.followForSendPhone()

                        if self.houseType != .neighborhood {
                            
                            var traceParams = self.traceParams <|> EnvContext.shared.homePageParams
                                .exclude("house_type")
                                .exclude("element_type")
                                .exclude("maintab_search")
                                .exclude("search")
                                .exclude("filter")
                            traceParams = traceParams <|>
                                toTracerParams(self.enterFromByHouseType(houseType: self.houseType), key: "page_type") <|>
                                toTracerParams(self.detailPageViewModel?.searchId ?? "be_null", key: "search_id") <|>
                                toTracerParams("\(self.houseId)", key: "group_id")
                            recordEvent(key: "click_call", params: traceParams)
                        }
                        
                    }else {
                        var titleStr:String = "询底价"
                        if self.houseType == .neighborhood {
                            titleStr = "咨询经纪人"
                        }
                        self.showSendPhoneAlert(title: titleStr, subTitle: "随时获取房源最新动态", confirmBtnTitle: "提交")
                    }

                })
                .disposed(by: disposeBag)
        }
        
        if let detailPageViewModel = detailPageViewModel {
            navBar.rightBtn.rx.tap
                .bind(onNext:  { [weak detailPageViewModel] in
                    detailPageViewModel?.followThisItem(isNeedRecord: true)
                    })
                    .disposed(by: disposeBag)
            detailPageViewModel.followStatus
                .filter { (result) -> Bool in
                    if case .success(_) = result {
                        return true
                    } else {
                        return false
                    }
                }
                .map { [weak self] (result) -> Bool in
                    if case let .success(status) = result {
                        if !status && self?.stateControl.state != .suspend
                        {
                            self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect"), for: .normal)
                        }
                        return status
                    } else {
                        return false
                    }
                }
                .bind(to: navBar.rightBtn.rx.isSelected)
                .disposed(by: disposeBag)
        }



        traceParams = (EnvContext.shared.homePageParams <|> traceParams <|>
            toTracerParams(enterFromByHouseType(houseType: self.houseType), key: "page_type") <|>
            toTracerParams("\(self.houseId)", key: "group_id")).exclude("house_type")
        stayPageParams = traceParams <|> traceStayTime()


        recordEvent(key: "go_detail", params: traceParams
            .exclude("house_type")
            .exclude("element_type")
            .exclude("maintab_search"))
        
        detailPageViewModel?.goDetailTraceParam = traceParams
            .exclude("house_type")
            .exclude("element_type")
            .exclude("maintab_search")
        
        self.netStateInfoVM?.netState
            .bind { [unowned self] hasError in
                self.bottomBar.isHidden = hasError
                //暂时持续根据网络状态确定是否隐藏右上角关注按钮。
                if !self.isShowBottomBar {
                    self.navBar.rightBtn.isHidden = hasError
                }
                self.bottomStatusBar.isHidden = hasError

            }.disposed(by: disposeBag)
        
        self.automaticallyAdjustsScrollViewInsets = false
        bindShareAction()
    }
    // MARK: 设置二手房bottomBar
    func refreshSecondHouseBottomBar(contactPhone: FHHouseDetailContact?) {
        
        self.bottomBar.leftView.isHidden = contactPhone?.showRealtorinfo == 1 ? false : true
        
        let leftWidth = contactPhone?.showRealtorinfo == 1 ? 140 : 0
        self.bottomBar.avatarView.bd_setImage(with: URL(string: contactPhone?.avatarUrl ?? ""), placeholder: UIImage(named: "defaultAvatar"))
        
        if var realtorName = contactPhone?.realtorName, realtorName.count > 0 {
            if realtorName.count > 4 {
                realtorName = realtorName + "..."
            }
            self.bottomBar.nameLabel.text = realtorName
        }else {
            self.bottomBar.nameLabel.text = "经纪人"
        }
        
        if var agencyName = contactPhone?.agencyName, agencyName.count > 0 {
            if agencyName.count > 4 {
                agencyName = agencyName + "..."
            }
            self.bottomBar.agencyLabel.text = agencyName
            self.bottomBar.agencyLabel.isHidden = false
            self.bottomBar.nameLabel.snp.remakeConstraints({ (maker) in
                maker.left.equalTo(self.bottomBar.avatarView.snp.right).offset(10)
                maker.top.equalTo(self.bottomBar.avatarView).offset(2)
                maker.right.equalToSuperview()
            })
            
        }else {
            
            self.bottomBar.nameLabel.snp.remakeConstraints({ (maker) in
                maker.left.equalTo(self.bottomBar.avatarView.snp.right).offset(10)
                maker.centerY.equalTo(self.bottomBar.avatarView)
                maker.right.equalToSuperview()
            })
            self.bottomBar.agencyLabel.isHidden = true
            
        }
        
        self.bottomBar.leftView.snp.updateConstraints({ (maker) in
            
            maker.width.equalTo(leftWidth)
        })
        
    }

    fileprivate func bindShareAction() {
        self.navBar.rightBtn2.rx.tap
            .bind(onNext:  { [unowned self] in
                self.openSharePanel()
            })
            .disposed(by: disposeBag)
    }

    private func setupNavBar() {
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }
        navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
        navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .highlighted)

        reloadPageAfterLogin()
    }

    func reloadPageAfterLogin() {
        if EnvContext.shared.client.accountConfig.userInfo.value == nil {
            EnvContext.shared.client.accountConfig.userInfo
                .subscribe(onNext: { [weak self] (userInfo) in
                    if userInfo != nil {
                        self?.netStateInfoVM?.onRequest()
                        self?.detailPageViewModel?.requestData(houseId: self?.houseId ?? 0, logPB: self?.logPB, showLoading: false)
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    fileprivate func openSharePanel() {
        var logPB = self.detailPageViewModel?.logPB ?? "be_null"
        logPB = self.logPB ?? logPB
        var params = EnvContext.shared.homePageParams <|>
            toTracerParams(enterFromByHouseType(houseType: houseType), key: "page_type") <|>
            toTracerParams(self.logPB ?? logPB, key: "log_pb")

        params = params
            .exclude("filter")
            .exclude("icon_type")
            .exclude("maintab_search")
            .exclude("search")
        recordEvent(key: "click_share", params: params)
        shareParams = params
        if let shareItem = self.detailPageViewModel?.getShareItem() {

            var shareContentItems = [TTActivityContentItemProtocol]()

//            if TTAccountAuthWeChat.isAppInstalled() {
                //判断是否有微信
                shareContentItems.append(createWeChatTimelineShareItem(shareItem: shareItem))
                shareContentItems.append(createWeChatShareItem(shareItem: shareItem))
//            }

            if QQApiInterface.isQQInstalled() && QQApiInterface.isQQSupportApi() {
                //判断是否有qq
                shareContentItems.append(createQQFriendShareItem(shareItem: shareItem))
                shareContentItems.append(createQQZoneContentItem(shareItem: shareItem))
            }

            self.shareManager.displayActivitySheet(withContent: shareContentItems)
        }
    }

    func shareManager(
        _ shareManager: TTShareManager!,
        clickedWith activity: TTActivityProtocol!,
        sharePanel panelController: TTActivityPanelControllerProtocol!) {
        guard let activity = activity else {
            return
        }
        var platform = "be_null"
        if activity.isKind(of: TTWechatTimelineActivity.self)  { // 微信朋友圈
            platform = "weixin_moments"
        } else if activity.isKind(of: TTWechatActivity.self)  { // 微信朋友分享
            platform = "weixin"
        } else if activity.isKind(of: TTQQFriendActivity.self)  { //
            platform = "qq"
        } else if activity.isKind(of: TTQQZoneActivity.self)  {
            platform = "qzone"
        }

        if let shareParams = shareParams {
            recordEvent(key: "share_platform", params: shareParams <|> toTracerParams(platform, key: "platform"))
        }
    }

    func shareManager(
        _ shareManager: TTShareManager!,
        completedWith activity: TTActivityProtocol!,
        sharePanel panelController: TTActivityPanelControllerProtocol!,
        error: Error!,
        desc: String!) {
        // 统计埋点

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.view.setNeedsLayout()
        self.detailPageViewModel?.followPage.accept(self.enterFromByHouseType(houseType: self.houseType))
        infoMaskView.isHidden = true
        self.view.bringSubview(toFront: infoMaskView)
        self.netStateInfoVM?.onRequestViewDidLoad()
        
        self.tableView.visibleCells.forEach{
            if $0 is NewHouseNearByCell
            {
                if let cell = $0 as? NewHouseNearByCell
                {
                    cell.resetMapData()
                }
            }
        }
        
        if EnvContext.shared.client.reachability.connection == .none
        {
            navBar.rightBtn.isUserInteractionEnabled = false
            navBar.rightBtn2.isUserInteractionEnabled = false
        }
        
//        if houseType == .newHouse
//        {
//           self.detailPageViewModel?.onDataArrived
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
            
            guard let state = self?.stateControl.state else {
                return
            }
            if state == .normal {
                let alpha = (1 - (139 - (self?.tableView.contentOffset.y ?? 0)) / 139) * 2
                self?.navBar.alpha = alpha
                self?.barStyle.accept(UIStatusBarStyle.default.rawValue)
                UIApplication.shared.statusBarStyle = .default
                self?.ttStatusBarStyle = UIStatusBarStyle.lightContent.rawValue

            } else {
                self?.navBar.alpha = 1
                self?.barStyle.accept(UIStatusBarStyle.lightContent.rawValue)
                UIApplication.shared.statusBarStyle = .lightContent
                self?.ttStatusBarStyle = UIStatusBarStyle.default.rawValue

            }

        }

        self.recordGoDetailSearch()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.recordStayPageSearch()
    }
    
    func enterFromByHouseType(houseType: HouseType) -> String {
        switch houseType {
        case .newHouse:
            return "new_detail"
        case .secondHandHouse:
            return "old_detail"
        case .neighborhood:
            return "neighborhood_detail"
        default:
            return "be_null"
        }
    }

    fileprivate func houseType(houseType: HouseType) -> String {
        switch houseType {
        case .newHouse:
            return "new"
        case .secondHandHouse:
            return "old"
        case .neighborhood:
            return "neighborhood"
        default:
            return "be_null"
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
        }
        if let stayPageParams = stayPageParams {
            recordEvent(key: "stay_page", params: stayPageParams.exclude("element_type"))
        }
        stayPageParams = nil
    }

    func showQuickLoginAlert(title: String, subTitle: String) {
        
//        let alert = NIHNoticeAlertView()
        
        var subTitleStr: String = subTitle
        let confirmBtnTitle: String = "确认"
        if title == "开盘通知" {
            subTitleStr = "订阅开盘通知，楼盘开盘信息会及时发送到您的手机"
        }else if title == "变价通知" {
            subTitleStr = "订阅变价通知，楼盘变价信息会及时发送到您的手机"
        }
        
        self.showSendPhoneAlert(title: title, subTitle: subTitleStr, confirmBtnTitle: confirmBtnTitle)
    }
    
    func followForSendPhone() {
        self.detailPageViewModel?.followHouseItem(houseType: self.houseType,
                                                  followAction: (FollowActionType(rawValue: self.houseType.rawValue) ?? .newHouse),
                                                  followId: "\(self.houseId)",
            disposeBag: self.disposeBag,
            isNeedRecord: false)()
    }
    
    func showSendPhoneAlert(title: String, subTitle: String, confirmBtnTitle: String) {
        let alert = NIHNoticeAlertView(alertType: .alertTypeSendPhone,title: title, subTitle: subTitle, confirmBtnTitle: confirmBtnTitle)
        alert.sendPhoneView.confirmBtn.rx.tap
            .bind { [unowned self] void in
                if let phoneNum = alert.sendPhoneView.phoneTextField.text, phoneNum.count == 11, phoneNum.prefix(1) == "1"
                {
                    self.detailPageViewModel?.sendPhoneNumberRequest(houseId: self.houseId, phone: phoneNum, from: gethouseTypeSendPhoneFromStr(houseType: self.houseType)){
                        EnvContext.shared.client.sendPhoneNumberCache?.setObject(phoneNum as NSString, forKey: "phonenumber")
                        alert.dismiss()
                        self.sendClickConfirmTrace()
                        self.followForSendPhone()
                    }
                }else
                {
                    alert.sendPhoneView.showErrorText()
                }
                

            }
            .disposed(by: disposeBag)
        

        var tracerParams = EnvContext.shared.homePageParams <|> traceParams
        tracerParams = tracerParams <|>
//            toTracerParams(enterFromByHouseType(houseType: houseType), key: "enter_from") <|>
            toTracerParams(self.houseId, key: "group_id") <|>
            toTracerParams(self.logPB ?? "be_null", key: "log_pb") <|>
            toTracerParams(self.searchId ?? "be_null", key: "search_id")

        
       recordEvent(key: TraceEventName.inform_show,
                        params: tracerParams.exclude("element_type"))
    
        alert.showFrom(self.view)
    }
    
    func sendClickConfirmTrace()
    {
        var tracerParams = EnvContext.shared.homePageParams <|> traceParams
        tracerParams = tracerParams <|>
//            toTracerParams(enterFromByHouseType(houseType: houseType), key: "enter_from") <|>
            toTracerParams(self.houseId, key: "group_id") <|>
            toTracerParams(self.logPB ?? "be_null", key: "log_pb") <|>
            toTracerParams(self.searchId ?? "be_null", key: "search_id")
        
        
        recordEvent(key: TraceEventName.click_confirm,
                    params: tracerParams)
    }
    
    func showFollowupAlert(title: String, subTitle: String) -> Observable<Void> {
        
        let alert = BubbleAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
        let phoneNumber = EnvContext.shared.client.accountConfig.getUserPhone()
        let alertView = createPhoneConfirmAlert(
                title: title,
                subTitle: subTitle,
                phoneNumber: phoneNumber ?? "",
                bubbleAlertController: alert)
        self.present(alert, animated: true, completion: {[weak alert,weak self] in
            
            alert?.view.superview?.isUserInteractionEnabled = true
            alert?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.closeAlertView)))
            
        })

        return alertView.configBtn.rx.tap.map { () }
    }

    @objc func closeAlertView() {
        self.dismiss(animated: true)
    }

    fileprivate func recordGoDetailSearch() {
        if let searchParams = self.houseSearchParams {
            let detailParams = self.traceParams
                .exclude("card_type")
                .exclude("element_from")
                .exclude("enter_from")

            let recordParams = EnvContext.shared.homePageParams <|>
                detailParams <|>
                searchParams <|>
                toTracerParams(self.houseType.traceTypeValue(), key: "house_type")
            recordEvent(key: "go_detail_search",
                        params: recordParams
                            .exclude("element_type")
                            .exclude("page_type"))
        }
    }

    fileprivate func recordStayPageSearch() {
        if let houseSearchParamsStay = self.houseSearchParamsStay {
            let detailParams = self.traceParams
                .exclude("card_type")
                .exclude("element_from")
                .exclude("enter_from")
                .exclude("element_type")
                .exclude("page_type")
            let recordParams = EnvContext.shared.homePageParams <|>
                detailParams <|>
                houseSearchParamsStay <|>
                toTracerParams(self.houseType.traceTypeValue(), key: "house_type")
            recordEvent(key: "stay_page_search",
                        params: recordParams
                            .exclude("time")
                            .exclude("element_type")
                            .exclude("page_type"))
        }
    }

    deinit {
//        print("release HorseDetailPageVC")
 //        self.closeANRMonitor()
    }

}

