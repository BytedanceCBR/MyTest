//
// Created by linlin on 2018/7/4.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class NewHouseDetailPageViewModel: NSObject, DetailPageViewModel {

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    private let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    var showQuickLoginAlert: ((String, String) -> Void)?

    var showFollowupAlert: ((String, String) -> Observable<Void>)?

    var closeAlert: (() -> Void)?

    init(tableView: UITableView){
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)

    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        requestNewHouseDetail(houseId: houseId)
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        self.titleValue.accept(response.data?.coreInfo?.name)
                        let result = self.processData(response: response, courtId: houseId)([])
                        self.dataSource.datas = result
                        self.tableView?.reloadData()
                    }

                    if let contact = response?.data?.contact?["phone"] {
                        self.contactPhone.accept(contact)
                    }

                    if let status = response?.data?.userStatus {
                        self.followStatus.accept(.success(status.courtSubStatus == 1))
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
    }

    fileprivate func processData(response: HouseDetailResponse, courtId: Int64) -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = response.data {
            let dataParser = DetailDataParser.monoid()
                <- parseNewHouseCycleImageNode(data)
                <- parseNewHouseNameNode(data)
                <- parseNewHouseCoreInfoNode(
                    data,
                    floorPanId: "\(courtId)",
                    priceChangeHandler: self.handlePriceChangeNotify(closeAlert: closeAlert ?? {}),
                    openCourtNotify: self.handleOpenCourtNotify(closeAlert: closeAlert ?? {}),
                    disposeBag: disposeBag)
                <- parseNewHouseContactNode(data)
                <- parseTimeLineHeaderNode(data)
                <- parseTimelineNode(data)
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) { [weak self] in
                    self?.openFloorPanList(courtId: courtId)
                }
                <- parseFloorPanHeaderNode(data)
                <- parseFloorPanNode(data)
                <- parseOpenAllNode(data.floorPan?.list?.count ?? 0 > 0) { [unowned self] in
                    openFloorPanCategoryPage(floorPanId: "\(courtId)", disposeBag: self.disposeBag)()
                }
                <- parseCommentHeaderNode(data)
                <- parseNewHouseCommentNode(data)
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) { [weak self] in
                    self?.openCommentList(courtId: courtId)
                }
                <- parseHeaderNode("周边位置")
                <- parseNewHouseNearByNode(data)
                <- parseHeaderNode("全网比价",
                                   showLoadMore: true,
                                   process: openGlobalPricingList(courtId: courtId, disposeBag: disposeBag))
                <- parseGlobalPricingNode(data, processor: openGlobalPricingList(courtId: courtId, disposeBag: disposeBag))
                <- parseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    func openCommentList(courtId: Int64) {
        let detailPage = HouseCommentVC(courtId: courtId)
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }

    func openFloorPanList(courtId: Int64) {
        let detailPage = FloorPanListVC(courtId: courtId)
        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }

//MARK: - 订阅
    func handleOpenCourtNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in
            if EnvContext.shared.client.accountConfig.userInfo.value == nil {
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
                let obv: Observable<UserFollowResponse?>? = self.showFollowupAlert?("开盘通知", "订阅开盘通知，楼盘开盘信息会及时发送到您的手机")
                        .flatMap({ [unowned self] () -> Observable<UserFollowResponse?> in
                            EnvContext.shared.toast.showLoadingToast("订阅开盘通知")
                            return self.followItObv(houseType: .newHouse, followAction: .openFloorPan, followId: "\(self.houseId)")
                        })
                obv?.subscribe(onNext: { [unowned self] response in
                    if let status = response?.status, status == 0 {
                        EnvContext.shared.toast.dismissToast()
                        self.closeAlert?()
                        EnvContext.shared.toast.showToast("开盘通知订阅成功")
                    }
                }, onError: { error in

                }).disposed(by: self.disposeBag)
                obv?.map({ (response) -> Bool in
                            return response != nil && response?.status == 0
                        })
                        .bind(to: isFollowup)
                        .disposed(by: self.disposeBag)
            }
        }
    }

    func handlePriceChangeNotify(closeAlert: @escaping () -> Void) -> (BehaviorRelay<Bool>) -> Void {
        return { [unowned self] (isFollowup) in
            if EnvContext.shared.client.accountConfig.userInfo.value == nil {
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
                let obv: Observable<UserFollowResponse?>? = self.showFollowupAlert?("变价通知", "订阅变价通知，楼盘变价信息会及时发送到您的手机")
                    .flatMap({ [unowned self] () ->  Observable<UserFollowResponse?> in
                        EnvContext.shared.toast.showLoadingToast("订阅变价通知")
                        return self.followItObv(houseType: .newHouse, followAction: .newHousePriceChanged, followId: "\(self.houseId)")
                    })


                obv?.subscribe(onNext: { [unowned self] response in
                    if let status = response?.status, status == 0 {
                        EnvContext.shared.toast.dismissToast()
                        self.closeAlert?()
                        EnvContext.shared.toast.showToast("变价通知订阅成功")
                    }
                }, onError: { error in

                }).disposed(by: self.disposeBag)

                obv?
                    .map({ (response) -> Bool in
                        closeAlert()
                        return response != nil && response?.status == 0
                    })
                    .bind(to: isFollowup)
                    .disposed(by: self.disposeBag)
            }
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
        tableView: UITableView) -> NewHouseDetailPageViewModel {
    let re = NewHouseDetailPageViewModel(tableView: tableView)
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

func openRelatedNeighborhoodList(neighborhoodId: String, disposeBag: DisposeBag) {
    let listVC = RelatedNeighborhoodListVC(neighborhoodId: neighborhoodId)
    listVC.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    EnvContext.shared.rootNavController.pushViewController(listVC, animated: true)
}

func openGlobalPricingList(courtId: Int64, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = GlobalPricingVC(courtId: courtId)
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}

func openFloorPanInfoPage(floorPanId: String, newHouseData: NewHouseData, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = FloorPanInfoVC(
            isHiddenBottomBar: false,
            floorPanId: floorPanId,
            newHouseData: newHouseData)

        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}

func openFloorPanCategoryPage(floorPanId: String, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = FloorPanCategoryVC(
                isHiddenBottomBar: false,
                floorPanId: floorPanId)

        detailPage.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    EnvContext.shared.rootNavController.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
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
        if datas[indexPath.section].selectors?.isEmpty ?? true == false {
            datas[indexPath.section].selectors?[indexPath.row]()
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
