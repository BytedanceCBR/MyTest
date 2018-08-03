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

typealias DetailPageViewModelProvider = (UITableView, UINavigationController?) -> DetailPageViewModel

class HorseDetailPageVC: BaseViewController {

    private let houseId: Int64
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var detailPageViewModel: DetailPageViewModel?

    var pageViewModelProvider: DetailPageViewModelProvider?

    var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        return re
    }()

    private lazy var tableView: UITableView = {
        let result = UITableView()
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

    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = false,
         provider: @escaping DetailPageViewModelProvider) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        self.pageViewModelProvider = provider
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
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
        view.backgroundColor = UIColor.white

        detailPageViewModel = pageViewModelProvider?(tableView, self.navigationController)

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
        detailPageViewModel?.requestData(houseId: houseId)

        view.bringSubview(toFront: navBar)

        let stateControl = HomeHeaderStateControl()
        stateControl.onStateChanged = { [weak self] (state) in
            switch state {
            case .suspend:
                    self?.navBar.setGradientColor()
                    UIApplication.shared.statusBarStyle = .lightContent
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
                    self?.navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-icon"), for: .normal)
            default:
                    self?.navBar.removeGradientColor()
                    UIApplication.shared.statusBarStyle = .default
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
                    self?.navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-alt-simple-line-icons"), for: .normal)
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
                    .bind(onNext: Utils.telecall)
                    .disposed(by: disposeBag)
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
        navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-icon"), for: .normal)
//        self.detailPageViewModel?.titleValue
//                .subscribe(onNext: { [unowned self] title in
//                    self.navBar.title.text = title
//                })
//                .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
//        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
        }
    }

    func showQuickLoginAlert(title: String, subTitle: String) {
        let alert = BubbleAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert)
        quickLoginVM = QuickLoginAlertViewModel(
                title: title,
                subTitle: subTitle,
                alert: alert)
        self.present(alert, animated: true)
    }

    func showFollowupAlert(title: String, subTitle: String) -> Observable<Void> {
        alert = BubbleAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
        let phoneNumber = EnvContext.shared.client.accountConfig.getUserPhone()
        let alertView = createPhoneConfirmAlert(
                title: title,
                subTitle: subTitle,
                phoneNumber: phoneNumber ?? "",
                bubbleAlertController: alert!)
        self.present(alert!, animated: true)
        return alertView.configBtn.rx.tap.map { () }
    }

    func closeAlertView() {
        alert?.dismiss(animated: true)
    }

    deinit {
        print("release HorseDetailPageVC")
    }

}

