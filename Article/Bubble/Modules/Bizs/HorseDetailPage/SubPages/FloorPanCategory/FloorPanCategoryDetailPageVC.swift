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

    private var houseId: Int64 = 0

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
        if let houseId = paramObj?.queryParams["court_id"] as? String, let houseIdInt = Int64(houseId) {
            self.houseId = houseIdInt
        }

        self.isHiddenBottomBar = false
        

        super.init(identifier: "\(floorPanId)",
            isHiddenBottomBar: self.isHiddenBottomBar,
            bottomBarBinder: { (_,_) in

            })

        
        var titleStr:String = "电话咨询"
        if let phone = paramObj?.queryParams["telephone"] as? String, phone.count > 0 {
            self.isHiddenBottomBar = false
        } else {
            self.isHiddenBottomBar = true
            titleStr = "询底价"
            
        }
        self.bottomBar.contactBtn.setTitle(titleStr, for: .normal)
        self.bottomBar.contactBtn.setTitle(titleStr, for: .highlighted)
        
        
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

            bottomBar.contactBtn.rx.tap
                .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
                .bind { [unowned self] () in

                    if phone.count > 0 {
                        
                        var contactPhone = FHHouseDetailContact()
                        contactPhone.phone = phone
                        
                        var theImprId: String?
                        var theSearchId: String?

                        if let logPB = self.viewModel?.logPB as? [String: Any], let imprId = logPB["impr_id"] as? String, let searchId = logPB["searchId"] as? String {
                            theSearchId = searchId
                            theImprId = imprId

                        }
                        self.callRealtorPhone(contactPhone: contactPhone, houseId: self.houseId, houseType: self.houseType, searchId: theSearchId ?? "", imprId: theImprId ?? "", disposeBag: self.disposeBag)
                        
                        self.followUpViewModel?.followHouseItem(houseType: self.houseType,
                                                                  followAction: (FollowActionType(rawValue: self.houseType.rawValue) ?? .newHouse),
                                                                  followId: "\(self.houseId)",
                            disposeBag: self.disposeBag,
                            statusBehavior: self.follwUpStatus,
                            isNeedRecord: true)()
                        
                        var traceParams = self.tracerParams <|> EnvContext.shared.homePageParams
                            .exclude("house_type")
                            .exclude("element_type")
                            .exclude("maintab_search")
                            .exclude("search")
                            .exclude("filter")
                        traceParams = traceParams <|>
                            toTracerParams("house_model_detail", key: "page_type") <|>
                            toTracerParams(self.viewModel?.logPB ?? "be_null", key: "log_pb") <|>
                            toTracerParams("be_null", key: "search_id") <|>
                            toTracerParams("\(self.houseId)", key: "group_id")
                        recordEvent(key: "click_call", params: traceParams)
                        
                    }else {
                        self.showSendPhoneAlert(title: "询底价", subTitle: "随时获取房源最新动态", confirmBtnTitle: "获取底价")
                    }
                    
                }.disposed(by: disposeBag)
        }
    }
    
    func showSendPhoneAlert(title: String, subTitle: String, confirmBtnTitle: String) {
        let alert = NIHNoticeAlertView(alertType: .alertTypeSendPhone,title: title, subTitle: subTitle, confirmBtnTitle: confirmBtnTitle)
        alert.sendPhoneView.confirmBtn.rx.tap
            .bind { [unowned self] void in
                if let phoneNum = alert.sendPhoneView.phoneTextField.text, phoneNum.count == 11, phoneNum.prefix(1) == "1"
                {
                    
                    self.sendPhoneNumberRequest(houseId: Int64(self.houseId), phone: phoneNum, from: gethouseTypeSendPhoneFromStr(houseType: self.houseType)){
                        EnvContext.shared.client.sendPhoneNumberCache?.setObject(phoneNum as NSString, forKey: "phonenumber")
                        alert.dismiss()
                    }
                }else
                {
                    alert.sendPhoneView.showErrorText()
                }
                self.followUpViewModel?.followHouseItem(houseType: self.houseType,
                                                        followAction: (FollowActionType(rawValue: self.houseType.rawValue) ?? .newHouse),
                                                        followId: "\(self.houseId)",
                    disposeBag: self.disposeBag,
                    statusBehavior: self.follwUpStatus,
                    isNeedRecord: false)()

            }
            .disposed(by: disposeBag)


        if let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        {
            var tracerParams = EnvContext.shared.homePageParams <|> self.tracerParams
            tracerParams = tracerParams <|>
                toTracerParams(enterFromByHouseType(houseType: houseType), key: "enter_from") <|>
                toTracerParams(self.houseId, key: "group_id") <|>
                toTracerParams(self.viewModel?.logPB ?? "be_null", key: "log_pb")
            
            
            recordEvent(key: TraceEventName.inform_show,
                        params: tracerParams.exclude("element_type"))
            
            alert.showFrom(rootView)
        }
    }
    
    func processError() -> (Error?) -> Void {
        return { error in
            if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("加载失败")
            }
        }
    }
    
    func sendPhoneNumberRequest(houseId: Int64, phone: String, from: String = "detail", success: @escaping () -> Void)
    {
        requestSendPhoneNumber(houseId: houseId, phone: phone, from: from).subscribe(
            onNext: { (response) in
                if let status = response?.status, status == 0 {
                    
                    var toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                    if toastCount >= 3 {
                        
                        EnvContext.shared.toast.showToast("提交成功")
                    }
                    success()
                }
                else {
                    if let message = response?.message
                    {
                        EnvContext.shared.toast.showToast("提交失败," + message)
                    }
                }
            },
            onError: self.processError())
            .disposed(by: self.disposeBag)
    }
    
    // MARK: 电话转接以及拨打相关操作
    func callRealtorPhone(contactPhone: FHHouseDetailContact?,
                          houseId: Int64,
                          houseType: HouseType,
                          searchId: String,
                          imprId: String,
                          disposeBag: DisposeBag) {


        guard let phone = contactPhone?.phone, phone.count > 0 else {
            return
        }

        EnvContext.shared.toast.showToast("电话查询中")
        requestVirtualNumber(realtorId: contactPhone?.realtorId ?? "0", houseId: houseId, houseType: houseType, searchId: searchId, imprId: imprId)
            .subscribe(onNext: { (response) in
                EnvContext.shared.toast.dismissToast()
                if let contactPhone = response?.data, let virtualNumber = contactPhone.virtualNumber {
                    
                    Utils.telecall(phoneNumber: virtualNumber)
                }else {
                    Utils.telecall(phoneNumber: phone)
                }
                
            }, onError: {  (error) in
                EnvContext.shared.toast.dismissToast()
                Utils.telecall(phoneNumber: phone)
            })
            .disposed(by: self.disposeBag)
        
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
        self.errorVM?.onRequest()
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
