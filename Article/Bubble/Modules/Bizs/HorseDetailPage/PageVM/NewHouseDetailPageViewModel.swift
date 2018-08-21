//
// Created by linlin on 2018/7/4.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class NewHouseDetailPageViewModel: NSObject, DetailPageViewModel, TableViewTracer {

    var onDataArrived: (() -> Void)?

    var onNetworkError: ((Error) -> Void)?

    var onEmptyData: (() -> Void)?
    
    var logPB: Any?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "new_detail")

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    var relatedCourt = BehaviorRelay<RelatedCourtResponse?>(value: nil)

    var newHouseDetail = BehaviorRelay<HouseDetailResponse?>(value: nil)
    
    var informParams: TracerParams = EnvContext.shared.homePageParams

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    var showQuickLoginAlert: ((String, String) -> Void)?

    var showFollowupAlert: ((String, String) -> Observable<Void>)?

    var closeAlert: (() -> Void)?
    
    weak var navVC: UINavigationController?

    var subDisposeBag: DisposeBag?

    weak var infoMaskView: EmptyMaskView?

    var traceParams = TracerParams.momoid()

    init(tableView: UITableView, infoMaskView: EmptyMaskView, navVC: UINavigationController?){
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        self.infoMaskView = infoMaskView
        super.init()
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)

        infoMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                if self.houseId != -1 {
                    self.requestData(houseId: self.houseId)
                }
            }.disposed(by: disposeBag)
        tableView.rx.didScroll
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .bind { [unowned self, weak tableView] void in
                self.traceDisplayCell(tableView: tableView, datas: self.dataSource.datas)
            }.disposed(by: disposeBag)

        self.bindFollowPage()

    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView?.isHidden = false
        } else {
            infoMaskView?.isHidden = true
        }
        requestNewHouseDetail(houseId: houseId)
                .retryOnConnect(timeout: 50)
                .retry(10)
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        self.titleValue.accept(response.data?.coreInfo?.name)

                        self.newHouseDetail.accept(response)
                        self.infoMaskView?.isHidden = true
                        self.onDataArrived?()
                    }

                    if let contact = response?.data?.contact?["phone"] {
                        self.contactPhone.accept(contact)
                    }

                    if let status = response?.data?.userStatus {
                        self.followStatus.accept(.success(status.courtSubStatus == 1))
                    }
                }, onError: { [unowned self] (error) in
                    print(error)
                    self.onNetworkError?(error)
                })
                .disposed(by: disposeBag)

        requestRelatedCourtSearch(courtId: "\(houseId)")
                .retryOnConnect(timeout: 50)
                .retry(10)
                .subscribe(onNext: { [unowned self] response in
                    self.infoMaskView?.isHidden = true
                    self.relatedCourt.accept(response)
                })
                .disposed(by: disposeBag)

        Observable
                .zip(newHouseDetail, relatedCourt)
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
            self.callTracer(
                tracer: datas[indexPath.section].tracer,
                atIndexPath: indexPath,
                traceParams: params)
        })
    }

    fileprivate func processData(response: HouseDetailResponse, courtId: Int64) -> ([TableSectionNode]) -> [TableSectionNode] {
        subDisposeBag = DisposeBag()
        if let data = response.data {
            self.informParams = self.informParams <|>
            toTracerParams(data.logPB ?? [:], key: "log_pb") <|>
            toTracerParams(self.houseId, key: "group_id")
            
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams("new_detail", key: "enter_from") <|>
                toTracerParams("click", key: "enter_type") <|>
                toTracerParams("list", key: "maintab_entrance")
            let theParams = EnvContext.shared.homePageParams <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")
            let coreInfoParams = theParams <|>
                    toTracerParams("house_info_detail", key: "page_type") <|>
                    toTracerParams(data.logPB ?? [:], key: "log_pb")

            let paramsMap = followTraceParams.paramsGetter([:])
            var pictureParams = EnvContext.shared.homePageParams <|> toTracerParams(paramsMap["enter_from"] ?? "be_null", key: "page_type")
            pictureParams = pictureParams <|>
                toTracerParams(self.houseId, key: "group_id") <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb")

            self.logPB = data.logPB

            let dataParser = DetailDataParser.monoid()
                <- parseNewHouseCycleImageNode(data,traceParams: pictureParams, disposeBag: disposeBag, navVC: self.navVC)
                <- parseNewHouseNameNode(data)
                <- parseNewHouseCoreInfoNode(
                    data,
                    floorPanId: "\(courtId)",
                    priceChangeHandler: self.handlePriceChangeNotify(closeAlert: closeAlert ?? {}),
                    openCourtNotify: self.handleOpenCourtNotify(closeAlert: closeAlert ?? {}),
                    disposeBag: subDisposeBag!,
                    navVC: self.navVC,
                    followPage: self.followPage,
                    bottomBarBinder: self.bindBottomView(params: coreInfoParams))
                <- parseNewHouseContactNode(data, courtId: "\(courtId)")
                <- parseTimeLineHeaderNode(data)
                <- parseTimelineNode(data,
                                     processor: { [unowned self] in
                                        let params = EnvContext.shared.homePageParams <|>
                                            toTracerParams("house_history_detail", key: "element_type") <|>
                                            toTracerParams(courtId, key: "group_id") <|>
                                            toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                            toTracerParams("new_detail", key: "page_type")
                                        self.openFloorPanList(
                                            courtId: courtId,
                                            bottomBarBinder: self.bindBottomView(params: params))
                })
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) { [unowned self] in
                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("house_history_detail", key: "page_type")
                    self.openFloorPanList(
                        courtId: courtId,
                        bottomBarBinder: self.bindBottomView(params: phoneTracer))
                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_history", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                }
                <- parseFloorPanHeaderNode(data)
                <- parseFloorPanNode(
                    data,
                    navVC: navVC,
                    followPage: self.followPage,
                    bottomBarBinder: self.bindBottomView(params: theParams <|> toTracerParams("house_model_list", key: "page_type")))
                <- parseOpenAllNode(data.floorPan?.list?.count ?? 0 >= 5) { [unowned self] in
                    let floorPanTraceParams = theParams <|>
                        toTracerParams("house_model_list", key: "category_name") <|>
                        toTracerParams("house_model_loadmore", key: "element_from") <|>
                        toTracerParams("slide", key: "card_type")

                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("house_model_list", key: "page_type")
                    openFloorPanCategoryPage(
                        floorPanId: "\(courtId)",
                        traceParams: floorPanTraceParams,
                        disposeBag: self.disposeBag,
                        navVC: self.navVC,
                        followPage: self.followPage,
                        bottomBarBinder: self.bindBottomView(params: phoneTracer))()
                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_model", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                }
                <- parseCommentHeaderNode(data)
                <- parseNewHouseCommentNode(data,
                                            processor: { [unowned self] in
                                                let params = EnvContext.shared.homePageParams <|>
                                                    toTracerParams("house_comment", key: "element_type") <|>
                                                    toTracerParams(courtId, key: "group_id") <|>
                                                    toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                                    toTracerParams("new_detail", key: "page_type")
                                                self.openCommentList(courtId: courtId, bottomBarBinder: self.bindBottomView(params: params))
                })
                <- parseOpenAllNode(data.comment?.hasMore ?? false) { [unowned self] in
                    let phoneTracer = TracerParams.momoid() <|>
                        toTracerParams("call_bottom", key: "element_type") <|>
                            toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("house_comment_detail", key: "page_type")


                    self.openCommentList(courtId: courtId, bottomBarBinder: self.bindBottomView(params: phoneTracer))
                    let params = EnvContext.shared.homePageParams <|>
                        toTracerParams("house_comment", key: "element_type") <|>
                        toTracerParams(courtId, key: "group_id") <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams("new_detail", key: "page_type")
                    recordEvent(key: "click_loadmore", params: params)
                }
                <- parseHeaderNode("周边位置")
                <- parseNewHouseNearByNode(data, houseId: "\(self.houseId)", disposeBag: disposeBag)
                <- parseHeaderNode("全网比价",
                                   showLoadMore: data.globalPricing?.hasMore ?? false,
                                   process:{ [unowned self] in
                                       let phoneTracer = TracerParams.momoid() <|>
                                               toTracerParams("call_bottom", key: "element_type") <|>
                                               toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                               toTracerParams("price_compare_detail", key: "page_type")
                                    openGlobalPricingList(
                                        courtId: courtId,
                                        data: data,
                                        disposeBag: self.disposeBag,
                                        navVC: self.navVC,
                                        followPage: self.followPage,
                                        bottomBarBinder: self.bindBottomView(params: phoneTracer))()
                })
                <- parseGlobalPricingNode(
                    data,
                    processor:{ [unowned self] in
                        let phoneTracer = TracerParams.momoid() <|>
                                toTracerParams("call_bottom", key: "element_type") <|>
                                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                                toTracerParams("price_compare_detail", key: "page_type")

                        openGlobalPricingList(
                            courtId: courtId,
                            data: data,
                            disposeBag: self.disposeBag,
                            navVC: self.navVC,
                            followPage: self.followPage,
                            bottomBarBinder: self.bindBottomView(params: phoneTracer))()
                })
                <- parseInfoNode("楼盘价格，由开发商统一报价，由于各平台更新速度不一致，导致价格有所差异，最终价格应以开发商报价为准；")
                <- parseHeaderNode("猜你喜欢")
                <- parseRelateCourtNode(relatedCourt.value, navVC: navVC)
                <- parseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    func openCommentList(courtId: Int64, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        
        self.followTraceParams = self.followTraceParams <|>
            toTracerParams("house_comment_detail", key: "enter_from")
        
        let detailPage = HouseCommentVC(courtId: courtId, bottomBarBinder: bottomBarBinder)
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }

    func openFloorPanList(courtId: Int64, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        
        self.followTraceParams = self.followTraceParams <|>
            toTracerParams("house_history_detail", key: "enter_from")
        
        let detailPage = FloorPanListVC(courtId: courtId, bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = followTraceParams
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }

//MARK: - 订阅
    func handleOpenCourtNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in

            var informParams = self.informParams <|>
                toTracerParams("openning_notice", key: "element_type")

            if EnvContext.shared.client.accountConfig.userInfo.value == nil {
                informParams = informParams <|> toTracerParams(0, key: "is_login")

                self.showQuickLoginAlert?("开盘通知", "订阅开盘通知，楼盘开盘信息会及时发送到您的手机")
                EnvContext.shared.client.accountConfig.userInfo
                        .skip(1)
                        .filter { $0 != nil }
                        .map { _ in () }
                        .bind(onNext: self.followIt(
                                houseType: .newHouse,
                                followAction: .openFloorPan,
                                followId: "\(self.houseId)",
                                disposeBag: self.disposeBag))
                        .disposed(by: self.disposeBag)
                
            } else {
                informParams = informParams <|> toTracerParams(1, key: "is_login")

                let obv = self.showFollowupAlert?("开盘通知", "订阅开盘通知，楼盘开盘信息会及时发送到您的手机")
                obv?
                    .bind(onNext: { (_) in
                        recordEvent(key: TraceEventName.click_confirm, params: informParams)
                    })
                    .disposed(by: self.disposeBag)
                
                let followupResponseObv: Observable<UserFollowResponse?>? = obv?
                            .flatMap({ [unowned self] ()  -> Observable<UserFollowResponse?> in
                            EnvContext.shared.toast.showLoadingToast("订阅开盘通知")
                            return self.followItObv(houseType: .newHouse, followAction: .openFloorPan, followId: "\(self.houseId)")
                        })
                followupResponseObv?.subscribe(onNext: { [unowned self] response in
                    if let status = response?.status, status == 0 {
                        EnvContext.shared.toast.dismissToast()
                        self.closeAlert?()
                        EnvContext.shared.toast.showToast("订阅成功")
                    }
                }, onError: { error in

                }).disposed(by: self.disposeBag)
                followupResponseObv?.map({ (response) -> Bool in
                            return response != nil && response?.status == 0
                        })
                        .bind(to: isFollowup)
                        .disposed(by: self.disposeBag)
                

            }
            
            recordEvent(key: TraceEventName.inform_show, params: informParams)

        }
    }

    func handlePriceChangeNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in
            
            var informParams = self.informParams <|>
                toTracerParams("price_notice", key: "element_type")
     
            if EnvContext.shared.client.accountConfig.userInfo.value == nil {
                informParams = informParams <|> toTracerParams(0, key: "is_login")

                self.showQuickLoginAlert?("变价通知", "订阅变价通知，楼盘变价信息会及时发送到您的手机")
                EnvContext.shared.client.accountConfig.userInfo
                        .skip(1)
                        .filter { $0 != nil }
                        .map { _ in () }
                        .bind(onNext: self.followIt(
                                houseType: .newHouse,
                                followAction: .newHousePriceChanged,
                                followId: "\(self.houseId)",
                                disposeBag: self.disposeBag))
                        .disposed(by: self.disposeBag)
            } else {
                informParams = informParams <|> toTracerParams(1, key: "is_login")

                let obv = self.showFollowupAlert?("变价通知", "订阅变价通知，楼盘变价信息会及时发送到您的手机")
                obv?
                    .debug()
                    .bind(onNext: { (_) in
                        recordEvent(key: TraceEventName.click_confirm, params: informParams)
                    })
                    .disposed(by: self.disposeBag)
                
                let followupResponseObv: Observable<UserFollowResponse?>? = obv?
                    .flatMap({ [unowned self] () ->  Observable<UserFollowResponse?> in
                        EnvContext.shared.toast.showLoadingToast("订阅变价通知")
                        return self.followItObv(houseType: .newHouse, followAction: .newHousePriceChanged, followId: "\(self.houseId)")
                    })


                followupResponseObv?
                    .subscribe(onNext: { [unowned self] response in
                        if let status = response?.status, status == 0 {
                            EnvContext.shared.toast.dismissToast()
                            self.closeAlert?()
                            EnvContext.shared.toast.showToast("订阅成功")
                        }
                        }, onError: { error in
                            
                    })
                    .disposed(by: self.disposeBag)

                followupResponseObv?
                    .map({ (response) -> Bool in
                        closeAlert()
                        return response != nil && response?.status == 0
                    })
                    .bind(to: isFollowup)
                    .disposed(by: self.disposeBag)
            }
            
            recordEvent(key: TraceEventName.inform_show, params: informParams)

        }
    }

    func followThisItem() {
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
                        disposeBag: disposeBag)()
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
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) {
    let listVC = RelatedNeighborhoodListVC(neighborhoodId: neighborhoodId, bottomBarBinder: bottomBarBinder)
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
                toTracerParams("new_detail", key: "page_type")
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
            isHiddenBottomBar: false,
            floorPanId: floorPanId,
            newHouseData: newHouseData,
                bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = TracerParams.momoid() <|> toTracerParams(newHouseData.logPB ?? "be_nul", key: "log_pb")
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
        
        followPage.accept("house_info_detail")

    }
}

func openFloorPanCategoryPage(
    floorPanId: String,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    navVC: UINavigationController?,
    followPage: BehaviorRelay<String>,
    bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> Void {
    return {

        let detailPage = FloorPanCategoryVC(
                isHiddenBottomBar: false,
                floorPanId: floorPanId,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder)
        detailPage.tracerParams = traceParams
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

fileprivate class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

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
                
                datas[indexPath.section].selectors?[indexPath.row]()
            }
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
