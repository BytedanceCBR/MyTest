//
//  FloorPanCategoryDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class FloorPanCategoryDetailPageVC: BaseSubPageViewController, TTRouteInitializeProtocol {

    private let floorPanId: Int64

    private var houseId: Int = 0

    private var viewModel: FloorPanCategoryDetailPageViewModel?

    private var errorVM : NHErrorViewModel?

    private var followPage: BehaviorRelay<String> = BehaviorRelay(value: "house_model_detail")

    private var followUpViewModel: FollowUpViewModel?

    private var follwUpStatus: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private var isHiddenBottomBar: Bool

    init(isHiddenBottomBar: Bool,
         floorPanId: Int64,
         followPage: BehaviorRelay<String>,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.floorPanId = floorPanId
        self.followPage = followPage
        self.isHiddenBottomBar = isHiddenBottomBar
        super.init(identifier: "\(floorPanId)",
            isHiddenBottomBar: isHiddenBottomBar,
                bottomBarBinder: bottomBarBinder)
    }

    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        self.followUpViewModel = FollowUpViewModel()
        if let floorPanId = paramObj?.queryParams["floor_plan_id"] as? String {
            self.floorPanId = Int64(floorPanId)!
        } else {
            self.floorPanId = 0
        }
        if let houseId = paramObj?.queryParams["court_id"] as? String, let houseIdInt = Int(houseId) {
            self.houseId = houseIdInt
        }
        
        if let _ = paramObj?.queryParams["telephone"] as? String {
            self.isHiddenBottomBar = true
        } else {
            self.isHiddenBottomBar = false
        }
        
        super.init(identifier: "\(floorPanId)",
            isHiddenBottomBar: self.isHiddenBottomBar,
            bottomBarBinder: { (_,_) in

            })

        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)

        self.navBar.rightBtn2.rx.tap
            .bind { [weak self] void in
                if let theFollowUpStatus = self?.follwUpStatus {
                    self?.followUpViewModel?.followThisItem(
                        isFollowUpOrCancel: !(self?.follwUpStatus.value ?? false),
                        houseId: self?.houseId ?? 0,
                        statusBehavior: theFollowUpStatus)
                }
            }.disposed(by: disposeBag)
        bindFollowUp(routeParamObj: paramObj)


    }

    fileprivate func bindFollowUp(routeParamObj paramObj: TTRouteParamObj?) {
        if let subscribeStatus = paramObj?.queryParams["subscribe_status"] as? String {
            if "true" == subscribeStatus {
//                print(subscribeStatus)
                follwUpStatus.accept(true)
            } else {
                follwUpStatus.accept(false)
            }
            follwUpStatus
                .bind(to: navBar.rightBtn2.rx.isSelected)
                .disposed(by: disposeBag)
//            navBar.rightBtn2.isSelected = follwUpStatus.value
        }

        if let phone = paramObj?.queryParams["telephone"] as? String {
            bottomBar.isHidden = false
            bottomBar.contactBtn.rx.tap
                .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
                .bind { () in
                    Utils.telecall(phoneNumber: phone)
                }.disposed(by: disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = FloorPanCategoryDetailPageViewModel(
                tableView: tableView,
                isHiddenBottomBar: isHiddenBottomBar,
                navVC: self.navigationController,
                followPage: self.followPage)
        self.viewModel?.bottomBarBinder = bottomBarBinder
        self.viewModel?.floorPanId = self.floorPanId

        tracerParams = (EnvContext.shared.homePageParams <|> tracerParams <|>
            toTracerParams("house_model_detail", key: "page_type")).exclude("house_type")

        stayTimeParams = tracerParams <|> traceStayTime()

        recordEvent(key: "go_detail", params: self.tracerParams.exclude("house_type"))

        self.viewModel?.tracerParams = tracerParams
        
        view.bringSubview(toFront: infoMaskView)
        infoMaskView.snp.remakeConstraints { maker in
            maker.bottom.right.left.equalTo(view)
            maker.top.equalTo(navBar.snp.bottom)
        }
        self.errorVM = NHErrorViewModel(errorMask:infoMaskView,requestRetryText:"网络异常")
        
        self.errorVM?.onRequestViewDidLoad()
        self.viewModel?.request(floorPanId: self.floorPanId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = self.stayTimeParams {
            recordEvent(key: "stay_page", params: stayTimeParams)
        }
        self.stayTimeParams = nil
        EnvContext.shared.toast.dismissToast()
    }

}


func openFloorPanCategoryDetailPage(
        floorPanId: Int64,
        isHiddenBottomBtn: Bool = true,
        logPbVC: Any?,
        disposeBag: DisposeBag,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        params: TracerParams = TracerParams.momoid()) -> () -> Void {
    return {
        let detailPage = FloorPanCategoryDetailPageVC(
                isHiddenBottomBar: isHiddenBottomBtn,
                floorPanId: floorPanId,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder)
        
        var searchId: String = "be_null"
        if let logPb = logPbVC as? Dictionary<String, Any>
        {
            if let searchIdV = logPb["search_id"] as? String
            {
                searchId = searchIdV
            }
        }
        
        detailPage.tracerParams = params <|>
            toTracerParams(logPbVC as Any, key: "log_pb") <|>
            toTracerParams(searchId, key: "search_id")
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}
