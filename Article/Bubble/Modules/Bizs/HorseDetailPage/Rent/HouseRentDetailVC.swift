//
//  HouseRentDetailVC.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import UIKit
import SnapKit
import Charts
import RxSwift
import RxCocoa
import Reachability

class HouseRentDetailVC: BaseHouseDetailPage, TTRouteInitializeProtocol {

    fileprivate var pageFrameObv: NSKeyValueObservation?

    private var isFromPush: Bool = false

    private let houseId: Int64
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var detailPageViewModel: HouseRentDetailViewMode?

    var shareParams: TracerParams?
    private let stateControl = HomeHeaderStateControl()

    private let followUpViewModel: FollowUpViewModel

    private var bottomBarViewModel: FHHouseContactBottomBarViewModel?


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

    lazy var shareManager: TTShareManager = {
        let re = TTShareManager()
        re.delegate = self
        return re
    }()

    var traceParams = TracerParams.momoid()

    var stayPageParams: TracerParams? = TracerParams.momoid()

    private var netStateInfoVM : NHErrorViewModel?

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()

    var logPB: [String: Any]?
    var searchId: String?
    var houseRentTracer: HouseRentTracer

    var houseSearchParams: TracerParams? {
        didSet {
            if let houseSearchParams = houseSearchParams {
                houseSearchParamsStay = houseSearchParams <|>
                    traceStayTime()
            }
        }
    }

    var houseSearchParamsStay: TracerParams?

    required init(routeParamObj paramObj: TTRouteParamObj?) {
        let houseId = HouseRentDetailVC.getHouseId(paramObj?.queryParams)
        self.houseId = Int64(houseId) ?? 0
        self.houseType = .rentHouse
        self.houseRentTracer = HouseRentTracer(pageType: "rent_detail",
                                               houseType: "rent",
                                               cardType: "left_pic")
        self.followUpViewModel = FollowUpViewModel()
        super.init(nibName: nil, bundle: nil)
        getTraceParams(routeParamObj: paramObj)
        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }

    private func getTraceParams(routeParamObj paramObj: TTRouteParamObj?) {
        if let userInfo = paramObj?.userInfo {
            self.houseRentTracer.cardType = userInfo.allInfo["card_type"] as? String ?? "be_null"
            self.houseRentTracer.enterFrom = userInfo.allInfo["enter_from"] as? String ?? "be_null"
            self.houseRentTracer.elementFrom = userInfo.allInfo["element_from"] as? String ?? "be_null"
            self.houseRentTracer.rank = userInfo.allInfo["rank"] as? String ?? "be_null"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func getHouseId(_ dict: [AnyHashable: Any]?) -> String {
        if let houseId = dict?["rent_id"] {
            return houseId as? String ?? ""
        }
        return ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavBar()
        bindNavBarStateMonitor()
        setupBottomStatusBar()
        setupTableView()
        setupInfoMaskView()
        detailPageViewModel = HouseRentDetailViewMode(houseId: houseId,
                                                      houseRentTracer: houseRentTracer)
        bindFollowUp()
        detailPageViewModel?.houseRentTracer = self.houseRentTracer
        self.tableView.dataSource = detailPageViewModel
        self.tableView.delegate = detailPageViewModel
        detailPageViewModel?.registerCell(tableView: tableView)
        detailPageViewModel?.tableView = tableView
        bottomBarViewModel = FHHouseContactBottomBarViewModel(bottomBar: bottomBar)

        //触发请求数据
        detailPageViewModel?.requestDetailData()
        view.bringSubview(toFront: navBar)

        bindShareAction()
    }

    fileprivate func bindFollowUp() {
        if let detailPageViewModel = self.detailPageViewModel {
            //绑定关注按钮点击事件
            navBar.rightBtn.rx.tap
                .bind(onNext:  { [weak detailPageViewModel, unowned self] in

//                    var tracerParams = EnvContext.shared.homePageParams
//                    if let params = detailPageViewModel.goDetailTraceParam {
//                        tracerParams = tracerParams <|> params
//                            .exclude("house_type")
//                            .exclude("element_type")
//                            .exclude("maintab_search")
//                            .exclude("search")
//                            .exclude("filter")
//                    }
//                    tracerParams = tracerParams <|>
//                        toTracerParams(pageTypeString(detailPageViewModel.houseType ?? .newHouse), key: "page_type")
                    if let theDetailModel = detailPageViewModel {
                        let followUpOrCancel = theDetailModel.follwUpStatus.value.state() ?? false
                        self.followUpViewModel.followThisItem(isFollowUpOrCancel: followUpOrCancel,
                                                              houseId: self.houseId,
                                                              houseType: .rentHouse,
                                                              followAction: .rentHouse,
                                                              statusBehavior: theDetailModel.follwUpStatus)
                    }
//                    detailPageViewModel?.followThisItem(isNeedRecord: true, traceParam: tracerParams)
                })
                .disposed(by: disposeBag)
            //绑定关注状态回调
            detailPageViewModel.follwUpStatus
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        infoMaskView.isHidden = true
        self.netStateInfoVM?.onRequestViewDidLoad()
        resetMapCellIfNeeded()
        if EnvContext.shared.client.reachability.connection == .none
        {
            navBar.rightBtn.isUserInteractionEnabled = false
            navBar.rightBtn2.isUserInteractionEnabled = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFromPush {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(600)) { [weak self] in
                self?.refreshStatusBar()
            }
        }else {
            refreshStatusBar()
        }
        isFromPush = false
//        self.recordGoDetailSearch()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.houseRentTracer.recordStayPage()
    }

    func resetMapCellIfNeeded() {
        self.tableView.visibleCells.forEach{
            if $0 is NewHouseNearByCell
            {
                if let cell = $0 as? NewHouseNearByCell
                {
                    cell.resetMapData()
                }
            }
        }
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
    }

    func setupBottomStatusBar() {
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
        }

        view.addSubview(bottomStatusBar)
        bottomStatusBar.snp.makeConstraints { maker in
            maker.right.left.equalToSuperview()
            maker.bottom.equalTo(bottomBar.snp.top)
            maker.height.equalTo(0)
        }
        bottomStatusBar.isHidden = true
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.right.left.equalToSuperview()
            maker.bottom.equalTo(bottomStatusBar.snp.top)
        }
    }

    func setupInfoMaskView() {
        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.bottom.left.right.equalTo(view)
        }
    }


    //导航栏透明度调整控制器
    private func bindNavBarStateMonitor() {
        stateControl.onStateChanged = { [weak self] (state) in
            switch state {
            case .suspend:
                self?.navBar.setGradientColor()
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

            } else {
                self?.navBar.alpha = 1
            }
            if offset.y > 0 {
                UIApplication.shared.statusBarStyle = .default
            }else {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        tableView.rx.contentOffset
            .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
            .disposed(by: disposeBag)

    }

    fileprivate func bindShareAction() {
        self.navBar.rightBtn2.rx.tap
            .bind(onNext:  { [unowned self] in
                self.openSharePanel()
            })
            .disposed(by: disposeBag)
    }

    func refreshStatusBar() {
        if self.tableView.contentOffset.y > 0 {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    fileprivate func openSharePanel() {
        var logPB: Any? = nil
        logPB = self.logPB
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

    


}
