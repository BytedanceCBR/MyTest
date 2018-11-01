//
// Created by linlin on 2018/7/4.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class NewHouseDetailPageViewModel: NSObject, DetailPageViewModel, TableViewTracer {

    var houseType: HouseType = .newHouse
    var houseId: Int64 = -1


    var shareInfo: ShareInfo?

    var onDataArrived: (() -> Void)?

    var onNetworkError: ((Error) -> Void)?

    var onEmptyData: (() -> Void)?
    
    var logPB: Any?
    
    var searchId: String?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "new_detail")

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    var relatedCourt = BehaviorRelay<RelatedCourtResponse?>(value: nil)

    var newHouseDetail = BehaviorRelay<HouseDetailResponse?>(value: nil)

    var groupId: String {
        get {
            if let id = newHouseDetail.value?.data?.id {
                return "\(id)"
            } else {
                return "be_null"
            }
        }
    }
    
    var informParams: TracerParams = EnvContext.shared.homePageParams

    weak var tableView: UITableView?

    var dataSource: NewHouseDetailDataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    var contactPhone: BehaviorRelay<FHHouseDetailContact?> = BehaviorRelay<FHHouseDetailContact?>(value: nil)

    var showQuickLoginAlert: ((String, String) -> Void)?

    var showFollowupAlert: ((String, String) -> Observable<Void>)?

    var closeAlert: (() -> Void)?
    
    weak var navVC: UINavigationController?

    var subDisposeBag: DisposeBag?

    weak var infoMaskView: EmptyMaskView?
    
    var traceParams = TracerParams.momoid()

    var showMessageAlert: ((String) -> Void)?

    var dismissMessageAlert: (() -> Void)?

    var recordRowIndex: Set<IndexPath> = []

    init(tableView: UITableView, infoMaskView: EmptyMaskView, navVC: UINavigationController?){
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = NewHouseDetailDataSource(cellFactory: cellFactory)
        self.infoMaskView = infoMaskView
        super.init()
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)
        tableView.register(MultitemCollectionCell.self, forCellReuseIdentifier: "MultitemCollectionCell-related")
        tableView.register(MultitemCollectionCell.self, forCellReuseIdentifier: "MultitemCollectionCell-floorPan")

//        infoMaskView.tapGesture.rx.event
//            .bind { [unowned self] (_) in
//                if EnvContext.shared.client.reachability.connection == .none {
//                    // 无网络时直接返回空，不请求
//                    EnvContext.shared.toast.showToast("网络异常")
//                    return
//                }
//                if self.houseId != -1 {
//                    self.requestData(houseId: self.houseId)
//                }
//            }.disposed(by: disposeBag)
        tableView.rx.didScroll
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self, weak tableView] void in
                self?.traceDisplayCell(tableView: tableView, datas: self?.dataSource.datas ?? [])
            }.disposed(by: disposeBag)

        self.bindFollowPage()

    }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool) {
        self.houseId = houseId
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView?.isHidden = false
        } else {
            infoMaskView?.isHidden = true
        }
        if showLoading {
            self.showMessageAlert?("正在加载")
        }
        requestNewHouseDetail(houseId: houseId, logPB: logPB)
                .subscribe(onNext: { [unowned self] (response) in

                    if let response = response {
                        self.titleValue.accept(response.data?.coreInfo?.name)

                        self.newHouseDetail.accept(response)
                        self.infoMaskView?.isHidden = true
                        self.onDataArrived?()
                    }

                    self.contactPhone.accept(response?.data?.contact)


                    if let status = response?.data?.userStatus {
                        self.followStatus.accept(.success(status.courtSubStatus == 1))
                    }
                    if showLoading {
                        self.dismissMessageAlert?()
                    }

                    }, onError: { [unowned self] (error) in
                    self.onNetworkError?(error)
                    EnvContext.shared.toast.dismissToast()
                    EnvContext.shared.toast.showToast("网络异常")
                })
                .disposed(by: disposeBag)

        requestRelatedCourtSearch(courtId: "\(houseId)")
                .subscribe(onNext: { [unowned self] response in
                    self.infoMaskView?.isHidden = true
                    self.relatedCourt.accept(response)
                })
                .disposed(by: disposeBag)

        Observable
                .combineLatest(newHouseDetail, relatedCourt)
                .bind { [unowned self] (e) in
                    let (detail, _) = e
                    if let detail = detail {
                        let result = self.processData(response: detail, courtId: houseId)([])
                        self.dataSource.datas = result
                        self.tableView?.reloadData()
                        DispatchQueue.main.async {
                            self.traceDisplayCell(tableView: self.tableView, datas: self.dataSource.datas)
                        }
                    }
                }
                .disposed(by: disposeBag)


    }

    func traceDisplayCell(tableView: UITableView?, datas: [TableSectionNode]) {
        let params = EnvContext.shared.homePageParams <|>
                toTracerParams("new_detail", key: "page_type") <|>
                toTracerParams("\(self.houseId)", key: "group_id")

        tableView?.indexPathsForVisibleRows?.forEach({ [unowned self] (indexPath) in

            if !recordRowIndex.contains(indexPath) {
                self.callTracer(
                    tracer: datas[indexPath.section].tracer,
                    atIndexPath: indexPath,
                    traceParams: params.exclude("search").exclude("filter"))
                recordRowIndex.insert(indexPath)
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                theCell.hasShowOnScreen = true
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionNeighborhoodCell {
                theCell.hasShowOnScreen = true
            }
        })
    }

    fileprivate func processData(response: HouseDetailResponse, courtId: Int64) -> ([TableSectionNode]) -> [TableSectionNode] {
        subDisposeBag = DisposeBag()
        if var data = response.data {
            self.shareInfo = data.shareInfo
            
            let traceParamsDic = traceParams.paramsGetter([:])
            var traceExtension: TracerParams = TracerParams.momoid()
            if let code = traceParamsDic["rank"] as? Int {
                traceExtension = traceExtension <|>
                toTracerParams(String(code), key: "rank") <|>
                toTracerParams(self.searchId ?? "be_null", key: "search_id")
            }
            
            /*
            if let search_id = traceParamsDic["search_id"] {
                traceExtension = traceExtension <|>
                    toTracerParams(search_id, key: "search_id")
            }
            */
            var logPbVC: Any?
            if let logPb = traceParamsDic["log_pb"] {
                traceExtension = traceExtension <|>
                    toTracerParams(logPb, key: "log_pb")
                logPbVC = logPb
            }
            
            
            
            
            self.informParams = self.informParams <|>
            toTracerParams(data.logPB ?? [:], key: "log_pb") <|>
            toTracerParams(self.houseId, key: "group_id")


            let theParams = EnvContext.shared.homePageParams <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")
            
            
            let coreInfoParams = theParams <|>
                    toTracerParams(courtId, key: "group_id") <|>
                    toTracerParams("house_info_detail", key: "page_type") <|>
                    toTracerParams(data.logPB ?? [:], key: "log_pb")

            let paramsMap = followTraceParams.paramsGetter([:])
            var pictureParams = EnvContext.shared.homePageParams <|> toTracerParams(paramsMap["enter_from"] ?? "be_null", key: "page_type")
            pictureParams = pictureParams <|>
                toTracerParams(self.houseId, key: "group_id") <|>
                toTracerParams(self.searchId ?? "be_null", key: "search_id") <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")

            self.logPB = data.logPB

  
            let dataParser = DetailDataParser.monoid()
                <- parseNewHouseCycleImageNode(data,traceParams: pictureParams, disposeBag: disposeBag, navVC: self.navVC)
                <- parseNewHouseNameNode(data)
                <- parseNewHouseCoreInfoNode(
                    data,
                    title: titleValue.value,
                    traceExt: traceExtension,
                    floorPanId: "\(courtId)",
                    priceChangeHandler: self.handlePriceChangeNotify(closeAlert: closeAlert ?? {}),
                    openCourtNotify: self.handleOpenCourtNotify(closeAlert: closeAlert ?? {}),
                    disposeBag: subDisposeBag!,
                    navVC: self.navVC,
                    followPage: self.followPage,
                    bottomBarBinder: self.bindBottomView(params: coreInfoParams <|> toTracerParams("new_detail", key: "page_type")))
                <- parseNewHouseContactNode(data, traceExt: traceExtension <|> self.traceParams, courtId: "\(courtId)")
                <- parseFlineNode(((data.contact?.phone?.count ?? 0) > 0) ? 6 : 0)
                <- parseFloorPanHeaderNode(data)
                <- parseNewHouseFloorPanCollectionNode(
                    data,
                    logPb: logPbVC,
                    traceExtension: traceExtension,
                    navVC: navVC,
                    followPage: self.followPage,
                    bottomBarBinder: self.bindBottomView(
                        params: theParams <|>
                            toTracerParams("house_model_detail", key: "page_type")))
                <- parseOpenAllNode(data.floorPan?.hasMore ?? false, barHeight: 0) { [unowned self] in
                    let floorPanTraceParams = theParams <|>
                        toTracerParams("house_model_list", key: "category_name") <|>
                        toTracerParams("house_model", key: "element_from") <|>
                        toTracerParams("slide", key: "card_type") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "enter_from")

                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams("house_model_list", key: "page_type")
                    openFloorPanCategoryPage(
                        floorPanId: "\(courtId)",
                        logPBVC: logPbVC,
                        isHiddenBottomBtn: (data.contact?.phone?.count ?? 0 < 1),
                        traceParams: floorPanTraceParams,
                        disposeBag: self.disposeBag,
                        navVC: self.navVC,
                        followPage: self.followPage,
                        logPB: data.logPB,
                        bottomBarBinder: self.bindBottomView(params: phoneTracer <|> toTracerParams("new_detail", key: "page_type")))()
                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_model", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("house_model_list", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                }
                <- parseFlineNode((data.floorPan?.list?.count ?? 0 > 0 && data.floorPan?.hasMore ?? false == false) ? 6 : 0)
                //楼盘动态
                <- parseTimeLineHeaderNode(data)
                <- parseTimelineNode(data,
                                     traceExt:traceExtension,
                                     processor: { [unowned self] (_) in
                                        let params = EnvContext.shared.homePageParams <|>
                                            toTracerParams("house_history_detail", key: "element_type") <|>
                                            toTracerParams(courtId, key: "group_id") <|>
                                            toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                            toTracerParams("house_history_detail", key: "page_type") 
                                        self.openFloorPanList(
                                            courtId: courtId,
                                            isHiddenBottomBtn: (data.contact?.phone?.count ?? 0 < 1),
                                            logPB: data.logPB,
                                            bottomBarBinder: self.bindBottomView(params: params <|> toTracerParams("new_detail", key: "page_type")))
                                        
                                        let infoParams = EnvContext.shared.homePageParams <|>
                                            traceExtension <|>
                                            toTracerParams("new_detail", key: "page_type") <|>
                                            toTracerParams(courtId, key: "group_id") <|>
                                            toTracerParams(data.logPB ?? "be_null", key: "log_pb")
                                        
                                        recordEvent(key: TraceEventName.click_house_history, params: infoParams)
                })
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false, barHeight: 0) { [unowned self] in
                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams("house_history_detail", key: "page_type")
                    self.openFloorPanList(
                        courtId: courtId,
                        isHiddenBottomBtn: data.contact?.phone?.count ?? 0 < 1,
                        logPB: data.logPB,
                        bottomBarBinder: self.bindBottomView(params: phoneTracer <|> toTracerParams("new_detail", key: "page_type")))
                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_history", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                    
                    let infoParams = EnvContext.shared.homePageParams <|>
                        traceExtension <|>
                        toTracerParams("new_detail", key: "page_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb")
                    
                    recordEvent(key: TraceEventName.click_house_history, params: infoParams)
                    
                }
                <- parseFlineNode((data.timeLine?.list?.count ?? 0) > 0 && (data.timeLine?.hasMore ?? false) == false ? 6 : 0)
                <- parseCommentHeaderNode(data)
                <- parseNewHouseCommentNode(data,
                                            traceExtension: traceExtension,
                                            processor: { [unowned self] (_) in
                                                let params = EnvContext.shared.homePageParams <|>
                                                    toTracerParams("house_comment", key: "element_type") <|>
                                                    toTracerParams(courtId, key: "group_id") <|>
                                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                                    toTracerParams("house_comment_detail", key: "page_type")
                                                self.openCommentList(
                                                    courtId: courtId,
                                                    isHiddenBottomBtn: data.contact?.phone?.count ?? 0 < 1,
                                                    logPB: data.logPB,
                                                    bottomBarBinder: self.bindBottomView(params: params <|> toTracerParams("new_detail", key: "page_type")))
                                                
                                                let infoParams = EnvContext.shared.homePageParams <|>
                                                    traceExtension <|>
                                                    toTracerParams("new_detail", key: "page_type") <|>
                                                    toTracerParams(courtId, key: "group_id") <|>
                                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb")
                                                
                                                recordEvent(key: TraceEventName.click_house_comment, params: infoParams)
                })
                <- parseOpenAllNode(data.comment?.hasMore ?? false, barHeight: 0) { [unowned self] in
                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("house_comment_detail", key: "page_type")


                    self.openCommentList(
                        courtId: courtId,
                        isHiddenBottomBtn: data.contact?.phone?.count ?? 0 < 1,
                        logPB: data.logPB,
                        bottomBarBinder: self.bindBottomView(params: phoneTracer <|> toTracerParams("new_detail", key: "page_type")))

                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_comment", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                    
                    let infoParams = EnvContext.shared.homePageParams <|>
                        traceExtension <|>
                        toTracerParams("new_detail", key: "page_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb")
                    
                    recordEvent(key: TraceEventName.click_house_comment, params: infoParams)
                }
                <- parseFlineNode(data.comment?.hasMore ?? false == false && data.comment?.list?.count ?? 0 > 0 ? 6 : 0)
                <- parseHeaderNode("周边配套")
                //地图cell
                <- parseNewHouseNearByNode(data, traceExt: traceExtension, houseId: "\(self.houseId)",navVC: navVC, disposeBag: disposeBag)
                <- parseHeaderNode("周边新盘") { [unowned self] in
                    self.relatedCourt.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelateCourtCollectionNode(relatedCourt.value,traceExtension: traceExtension, navVC: navVC)
                <- parseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    func openCommentList(
        courtId: Int64,
        isHiddenBottomBtn: Bool? = true,
        logPB: Any?,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        
        self.followTraceParams = self.followTraceParams <|>
            toTracerParams("house_comment_detail", key: "enter_from")
        
        let detailPage = HouseCommentVC(courtId: courtId, isHiddenBottomBar: isHiddenBottomBtn ?? true, bottomBarBinder: bottomBarBinder)

        detailPage.tracerParams = TracerParams.momoid() <|>
            toTracerParams("new_detail", key: "enter_from") <|>
            toTracerParams(logPB ?? "be_null", key: "log_pb")

        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }

    func openFloorPanList(
        courtId: Int64,
        isHiddenBottomBtn: Bool? = true,
        logPB: Any?,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        
        self.followTraceParams = self.followTraceParams <|>
            toTracerParams("house_history_detail", key: "enter_from")
        
        let detailPage = FloorPanListVC(
            courtId: courtId,
            isHiddenBottomBar: isHiddenBottomBtn ?? true ,
            bottomBarBinder: bottomBarBinder)

        detailPage.tracerParams = followTraceParams <|>
            toTracerParams("new_detail", key: "enter_from") <|>
            toTracerParams(logPB ?? "be_null", key: "log_pb")
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
    
    deinit {
        
//        print("newhouseDetailPageViewModel deinit")
    }

//MARK: - 订阅
    func handleOpenCourtNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in
            
            self.showSendPhoneAlert(title: "开盘通知", subTitle: "订阅开盘通知，楼盘开盘信息会及时发送到您的手机", confirmBtnTitle: "提交")
            
            /*
            let informParams = self.informParams
                <|> toTracerParams(self.searchId ?? "be_null", key: "search_id")
                <|> toTracerParams(self.houseId, key: "group_id")
                <|> toTracerParams("new_detail", key: "page_type")
            
            let followProcess: () -> Void = { [unowned self] in
                
                let followupResponseObv: Observable<UserFollowResponse?> = self.followItObv(houseType: .newHouse, followAction: .openFloorPan, followId: "\(self.houseId)")
                followupResponseObv
                    .subscribe(onNext: { [unowned self] response in
                        EnvContext.shared.toast.dismissToast()
                        if let status = response?.status, status == 0 {
                            self.closeAlert?()
                            DispatchQueue.main.async {
                                if response?.data?.followStatus ?? 0 == 1 {
                                    EnvContext.shared.toast.showToast("订阅成功")
                                } else {
                                    EnvContext.shared.toast.showToast("您已订阅")
                                }
                            }
                        }
                        }, onError: { error in
                            EnvContext.shared.toast.dismissToast()
                            EnvContext.shared.toast.showToast("加载失败")
                    })
                    .disposed(by: self.disposeBag)
                followupResponseObv.map({ (response) -> Bool in
                    return response != nil && response?.status == 0
                })
                    .bind(to: isFollowup)
                    .disposed(by: self.disposeBag)
            }

            if EnvContext.shared.client.accountConfig.userInfo.value == nil {
                self.showQuickLoginAlert?("开盘通知", "订阅开盘通知，楼盘开盘信息会及时发送到您的手机")
                EnvContext.shared.client.accountConfig.userInfo
                        .skip(1)
                        .filter { $0 != nil }
                        .map { _ in () }
                        .bind(onNext: {
                            followProcess()
                        })
                        .disposed(by: self.disposeBag)
                
            } else {

                let obv = self.showFollowupAlert?("开盘通知", "订阅开盘通知，楼盘开盘信息会及时发送到您的手机")
                obv?
                    .bind(onNext: {
                        
                        recordEvent(key: TraceEventName.click_confirm, params: informParams)
                        
                        followProcess()
                        
                    })
                    .disposed(by: self.disposeBag)

            }
            
            */
//
//            recordEvent(key: TraceEventName.inform_show,
//                        params: informParams)

        }
    }

    func handlePriceChangeNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in
            self.showSendPhoneAlert(title: "变价通知", subTitle: "订阅变价通知，楼盘变价信息会及时发送到您的手机", confirmBtnTitle: "提交")
            /*
            let informParams = self.informParams
                <|> toTracerParams(self.searchId ?? "be_null", key: "search_id")
                <|> toTracerParams(self.houseId, key: "group_id")
                <|> toTracerParams("new_detail", key: "page_type")
            
            let followProcess: () -> Void = { [unowned self] in
                
                let followupResponseObv: Observable<UserFollowResponse?> = self.followItObv(houseType: .newHouse, followAction: .newHousePriceChanged, followId: "\(self.houseId)")
                followupResponseObv
                    .subscribe(onNext: { [unowned self] response in
                        self.dismissMessageAlert?()
                        if let status = response?.status, status == 0 {
                            self.closeAlert?()
//                            DispatchQueue.main.async {
//                                if response?.data?.followStatus ?? 0 == 0 {
//                                    EnvContext.shared.toast.showToast("订阅成功")
//                                } else {
//                                    EnvContext.shared.toast.showToast("您已订阅")
//                                }
//                            }
                        }
                        }, onError: { error in
                            EnvContext.shared.toast.dismissToast()
                            EnvContext.shared.toast.showToast("加载失败")
                    })
                    .disposed(by: self.disposeBag)
                followupResponseObv.map({ (response) -> Bool in
                    return response != nil && response?.status == 0
                })
                    .bind(to: isFollowup)
                    .disposed(by: self.disposeBag)
            }

            if EnvContext.shared.client.accountConfig.userInfo.value == nil {

                self.showQuickLoginAlert?("变价通知", "订阅变价通知，楼盘价格变动后将信息及时发送到您的手机")
                EnvContext.shared.client.accountConfig.userInfo
                        .skip(1)
                        .filter { $0 != nil }
                        .map { _ in () }
                        .bind(onNext: {
                            followProcess()
                        })
                        .disposed(by: self.disposeBag)
            } else {

                let obv = self.showFollowupAlert?("变价通知", "订阅变价通知，楼盘价格变动后将信息及时发送到您的手机")
                obv?
                    .bind(onNext: {
                        recordEvent(key: TraceEventName.click_confirm, params: informParams)
                        
                        followProcess()
                        
                    })
                    .disposed(by: self.disposeBag)
            }
            */

//            recordEvent(key: TraceEventName.inform_show,
//                        params: informParams)

        }
    }

    func followThisItem(isNeedRecord: Bool) {
        switch followStatus.value {
        case let .success(status):
            if status {
                cancelFollowIt(
                        houseType: .newHouse,
                        followAction: .newHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag)()
            } else {
                followIt(
                        houseType: .newHouse,
                        followAction: .newHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag,
                        isNeedRecord: isNeedRecord)()

            }
        case .failure(_): do {}
        }
    }

    func followItObv(
            houseType: HouseType,
            followAction: FollowActionType,
            followId: String) -> Observable<UserFollowResponse?> {
        
        return requestFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
    }
}

//MARK: - ViewModel构造函数

func getNewHouseDetailPageViewModel(
        detailPageVC: HorseDetailPageVC,
        infoMaskView: EmptyMaskView,
        navVC: UINavigationController?,
        tableView: UITableView) -> NewHouseDetailPageViewModel {
    let re = NewHouseDetailPageViewModel(tableView: tableView, infoMaskView: infoMaskView, navVC: navVC)
    re.showQuickLoginAlert = { [weak detailPageVC] (title, subTitle) in
        detailPageVC?.showQuickLoginAlert(title: title, subTitle: subTitle)
    }

    re.showFollowupAlert = { [unowned detailPageVC] (title, subTitle) -> Observable<Void> in
        return detailPageVC
            .showFollowupAlert(title: title, subTitle: subTitle)
    }

    re.closeAlert = { [weak detailPageVC] in
        detailPageVC?.closeAlertView()
    }
    return re
}



//MARK: - 页面跳转

func openRelatedNeighborhoodList(
    neighborhoodId: String,
    searchId: String? = nil,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) {
    let listVC = RelatedNeighborhoodListVC(
        neighborhoodId: neighborhoodId,
        searchId: searchId,
        bottomBarBinder: bottomBarBinder)
    listVC.tracerParams = tracerParams
    listVC.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    navVC?.pushViewController(listVC, animated: true)
}

func openGlobalPricingList(
    courtId: Int64,
    data: NewHouseData,
    disposeBag: DisposeBag,
    navVC: UINavigationController?,
    followPage: BehaviorRelay<String>,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> Void {
    return {
        let params = EnvContext.shared.homePageParams <|>
                toTracerParams("price_compare", key: "element_type") <|>
                toTracerParams(courtId, key: "group_id") <|>
                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams("new_detail", key: "enter_from") <|>
                toTracerParams("price_compare_detail", key: "page_type")
        recordEvent(key: "click_loadmore", params: params)
        let detailPage = GlobalPricingVC(courtId: courtId, bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = TracerParams.momoid() <|> toTracerParams(data.logPB ?? "be_nul", key: "log_pb")
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
        
        followPage.accept("price_compare_detail")
    }
}

func openFloorPanInfoPage(
    floorPanId: String,
    newHouseData: NewHouseData,
    disposeBag: DisposeBag,
    navVC: UINavigationController?,
    followPage: BehaviorRelay<String>,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> Void {
    return {
        
        let detailPage = FloorPanInfoVC(
            isHiddenBottomBar: newHouseData.contact?.phone?.count ?? 0 < 1,
            floorPanId: floorPanId,
            newHouseData: newHouseData,
            bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = TracerParams.momoid() <|> toTracerParams(newHouseData.logPB ?? "be_nul", key: "log_pb")
        
        navVC?.pushViewController(detailPage, animated: true)
        
        followPage.accept("house_info_detail")

    }
}

func openFloorPanCategoryPage(
    floorPanId: String,
    logPBVC: Any?,
    isHiddenBottomBtn: Bool = true,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    navVC: UINavigationController?,
    followPage: BehaviorRelay<String>,
    logPB: Any?,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> Void {
    return {

        let detailPage = FloorPanCategoryVC(
                isHiddenBottomBar: isHiddenBottomBtn,
                floorPanId: floorPanId,
                followPage: followPage,
                logPB: logPB,
                bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = traceParams <|>
            toTracerParams(logPBVC ?? "be_null", key: "log_pb")
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
        
        followPage.accept("house_model_list")

    }
}

//MARK: - DataSource

class NewHouseDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var datas: [TableSectionNode] = []

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?

    init(cellFactory: UITableViewCellFactory) {
        self.cellFactory = cellFactory
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas[indexPath.section].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datas[indexPath.section].selectors?.isEmpty ?? true == false{
            
            if indexPath.row < datas[indexPath.section].selectors!.count {
                
                datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
            }
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
