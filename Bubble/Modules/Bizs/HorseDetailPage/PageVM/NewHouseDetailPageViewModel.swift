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
                <- parseNewHouseCoreInfoNode(data, floorPanId: "\(courtId)", disposeBag: disposeBag)
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


}

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


func getNewHouseDetailPageViewModel() -> (UITableView) -> DetailPageViewModel {
    return { tableView in
        NewHouseDetailPageViewModel(tableView: tableView)
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
