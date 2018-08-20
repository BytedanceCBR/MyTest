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

typealias DetailPageViewModelProvider = (UITableView, EmptyMaskView, UINavigationController?) -> DetailPageViewModel

class HorseDetailPageVC: BaseViewController {
    fileprivate var pageFrameObv: NSKeyValueObservation?

    private let houseId: Int64
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var detailPageViewModel: DetailPageViewModel?

    var pageViewModelProvider: DetailPageViewModelProvider?

    var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
//        re.rightBtn.isHidden = false
        re.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-white"), for: .normal)
        re.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: .selected)
        return re
    }()

    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.rowHeight = UITableViewAutomaticDimension

        result.separatorStyle = .none
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()

    private lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()

    let barStyle = BehaviorRelay<Int>(value: UIStatusBarStyle.lightContent.rawValue)

    var isShowBottomBar: Bool

    var quickLoginVM: QuickLoginAlertViewModel?

    var hud: MBProgressHUD?

    var alert: BubbleAlertController?
    
    var isShowFollowNavBtn = false

    var traceParams = TracerParams.momoid()

    var stayPageParams: TracerParams? = TracerParams.momoid()

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        if EnvContext.shared.client.reachability.connection == .none {
            re.label.text = "网络不给力，点击屏幕重试"
            re.isHidden = false
        } else {
//            re.label.text = "没有找到相关的信息，换个条件试试吧~"
            re.isHidden = true
        }
        return re
    }()

    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = false,
         isShowFollowNavBtn: Bool = false,
         provider: @escaping DetailPageViewModelProvider) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        self.pageViewModelProvider = provider
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.isShowFollowNavBtn = isShowFollowNavBtn
        navBar.rightBtn.isHidden = !isShowFollowNavBtn
        barStyle
                .bind { [unowned self] i in
                    self.ttStatusBarStyle = i
                    self.ttNeedChangeNavBar = true
                }
                .disposed(by: disposeBag)

    }


    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = false) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageFrameObv = bottomBar.observe(\.frame, options: [.new, .old]) { (view, value) in
            print("\(view) - \(value)")
        }
        view.backgroundColor = UIColor.white
        
        detailPageViewModel = pageViewModelProvider?(tableView, infoMaskView, self.navigationController)
        detailPageViewModel?.traceParams = traceParams
        setupNavBar()

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

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            if isShowBottomBar {
                maker.top.right.left.equalToSuperview()
                maker.bottom.equalTo(bottomBar.snp.top)
            } else {
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalToSuperview()
                }
                maker.top.left.right.equalToSuperview()
            }
        }

        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }

        // 绑定网络状态监控
        Reachability.rx.isReachable
                .bind { [unowned self] reachable in
                    if !reachable {
                        self.infoMaskView.label.text = "网络不给力，点击屏幕重试"
                    }
                }
                .disposed(by: disposeBag)

        detailPageViewModel?.requestData(houseId: houseId)

        // 绑定点击重试
        infoMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                self.detailPageViewModel?.requestData(houseId: self.houseId)
            }
            .disposed(by: disposeBag)

        view.bringSubview(toFront: navBar)

        let stateControl = HomeHeaderStateControl()
        stateControl.onStateChanged = { [weak self] (state) in
            switch state {
            case .suspend:
                    self?.navBar.setGradientColor()
                    UIApplication.shared.statusBarStyle = .lightContent
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
                    self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect-white"), for: .normal)
            default:
                    self?.navBar.removeGradientColor()
                    UIApplication.shared.statusBarStyle = .default
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
                    self?.navBar.rightBtn.setImage(#imageLiteral(resourceName: "tab-collect"), for: .normal)
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
            bottomBar.favouriteBtn.rx.tap
                    .bind(onNext: detailPageViewModel.followThisItem)
                    .disposed(by: disposeBag)
            detailPageViewModel.followStatus
                .filter { (result) -> Bool in
                    if case .success(_) = result {
                        return true
                    } else {
                        return false
                    }
                }
                .map { (result) -> Bool in
                    if case let .success(status) = result {
                        return status
                    } else {
                        return false
                    }
                }
                .bind(to: bottomBar.favouriteBtn.rx.isSelected)
                .disposed(by: disposeBag)

            bottomBar.contactBtn.rx.tap
                    .withLatestFrom(detailPageViewModel.contactPhone)
                    .bind(onNext: { [unowned self] (phone) in
                        let params = EnvContext.shared.homePageParams <|>
                                toTracerParams(self.enterFromByHouseType(houseType: self.houseType), key: "page_type") <|>
                                toTracerParams(self.detailPageViewModel?.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams("\(self.houseId)", key: "group_id") <|>
                                toTracerParams("call_bottom", key: "element_type")
                        recordEvent(key: "click_call", params: params)
                        Utils.telecall(phoneNumber: phone)
                    })
                    .disposed(by: disposeBag)
        }
        
        if isShowFollowNavBtn, let detailPageViewModel = detailPageViewModel {
            navBar.rightBtn.rx.tap
                .bind(onNext: detailPageViewModel.followThisItem)
                .disposed(by: disposeBag)
            detailPageViewModel.followStatus
                .filter { (result) -> Bool in
                    if case .success(_) = result {
                        return true
                    } else {
                        return false
                    }
                }
                .map { (result) -> Bool in
                    if case let .success(status) = result {
                        return status
                    } else {
                        return false
                    }
                }
                .bind(to: navBar.rightBtn.rx.isSelected)
                .disposed(by: disposeBag)
        }

        stayPageParams = traceParams <|> traceStayTime()

        recordEvent(key: "go_detail", params: traceParams)

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
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.setNeedsLayout()
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        self.detailPageViewModel?.followPage.accept(self.enterFromByHouseType(houseType: self.houseType))
        
    }
    
    fileprivate func enterFromByHouseType(houseType: HouseType) -> String {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
        }
        if let stayPageParams = stayPageParams {
            recordEvent(key: "stay_page", params: stayPageParams)
        }
        stayPageParams = nil
    }

    func showQuickLoginAlert(title: String, subTitle: String) {
        let alert = BubbleAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert)
        
        var enter_type: String?
        if title == "开盘通知" {
            enter_type = "openning_notice"
        }else if title == "变价通知" {
            enter_type = "price_notice"
        }
        
        if let enterType = enter_type {
            
            var tracerParams = TracerParams.momoid()
            tracerParams = tracerParams <|>
                toTracerParams("new_detail", key: "enter_from") <|>
                toTracerParams(enterType, key: "enter_type")
            alert.tracerParams = tracerParams
            
        }
        quickLoginVM = QuickLoginAlertViewModel(
                title: title,
                subTitle: subTitle,
                alert: alert)
        self.present(alert, animated: true, completion: {[weak self] in
            
            self?.alert?.view.superview?.isUserInteractionEnabled = true
            self?.alert?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.closeAlertView)))

        })
        
        self.alert = alert
        
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
        self.present(alert, animated: true, completion: {[weak self] in
            
            self?.alert?.view.superview?.isUserInteractionEnabled = true
            self?.alert?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.closeAlertView)))
            
        })
        self.alert = alert

        return alertView.configBtn.rx.tap.map { () }
    }

    @objc func closeAlertView() {
        alert?.dismiss(animated: true)
    }

    deinit {
        print("release HorseDetailPageVC")
    }

}

