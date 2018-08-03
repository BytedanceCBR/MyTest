//
// Created by linlin on 2018/7/7.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NeighborhoodDetailPageViewModel: DetailPageViewModel {

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    private let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var neighborhoodDetailResponse = BehaviorRelay<NeighborhoodDetailResponse?>(value: nil)

    private var totalSalesResponse = BehaviorRelay<NeighborhoodTotalSalesResponse?>(value: nil)

    //相关小区
    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)
    //小区内相关
    private var houseInSameNeighborhood = BehaviorRelay<SameNeighborhoodHouseResponse?>(value: nil)

    private var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    weak var navVC: UINavigationController?

    var cellsDisposeBag: DisposeBag!

    init(tableView: UITableView, navVC: UINavigationController?) {
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)

        neighborhoodDetailResponse
                .skip(1)
                .subscribe { [unowned self] event in
                    let diss = DisposeBag()
                    self.cellsDisposeBag = diss
                    let datas = self.processData(diss)([])
                    self.dataSource.datas = datas
                    tableView.reloadData()
                }
                .disposed(by: disposeBag)

        totalSalesResponse
                .skip(1)
                .subscribe { [unowned self] event in
                    let diss = DisposeBag()
                    self.cellsDisposeBag = diss
                    let datas = self.processData(diss)([])
                    self.dataSource.datas = datas
                    tableView.reloadData()
                }
                .disposed(by: disposeBag)
        relateNeighborhoodData
            .skip(1)
            .subscribe { [unowned self] event in
                let diss = DisposeBag()
                self.cellsDisposeBag = diss
                let result = self.processData(diss)([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
        houseInSameNeighborhood
            .skip(1)
            .subscribe { [unowned self] event in
                let diss = DisposeBag()
                self.cellsDisposeBag = diss
                let result = self.processData(diss)([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
    }

    func requestReletedData() {
        if let neighborhoodId = neighborhoodDetailResponse.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.relateNeighborhoodData.accept(response)
                    })
                    .disposed(by: disposeBag)

            requestHouseInSameNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.houseInSameNeighborhood.accept(response)
                    })
                    .disposed(by: disposeBag)

        }

    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        requestNeighborhoodDetail(neighborhoodId: "\(houseId)")
                .subscribe(onNext: { [unowned self] (response) in
                    if let status = response?.data?.neighbordhoodStatus {
                        self.followStatus.accept(Result.success(status.neighborhoodSubStatus ?? 0 == 1))
                    }
                    self.titleValue.accept(response?.data?.name)
                    self.neighborhoodDetailResponse.accept(response)
                    self.requestReletedData()
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)

        requestNeighborhoodTotalSales(neighborhoodId: "\(houseId)", query: "")
                .subscribe(onNext: { response in
                    self.totalSalesResponse.accept(response)
                }, onError: { error in

                })
                .disposed(by: disposeBag)
    }

    func followThisItem() {
        switch followStatus.value {
        case let .success(status):
            if status {
                cancelFollowIt(
                    houseType: .neighborhood,
                    followAction: .beighborhood,
                    followId: "\(houseId)",
                    disposeBag: disposeBag)()
            } else {
                followIt(
                    houseType: .neighborhood,
                    followAction: .beighborhood,
                    followId: "\(houseId)",
                    disposeBag: disposeBag)()
            }
        case .failure(_): do {}
        }
    }

    fileprivate func processData(_ theDisposeBag: DisposeBag) -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = neighborhoodDetailResponse.value?.data {
            let dataParser = DetailDataParser.monoid()
                <- parseCycleImageNode(data.neighborhoodImage, disposeBag: self.disposeBag)
                <- parseNeighborhoodNameNode(data, disposeBag: theDisposeBag)
                <- parseNeighborhoodStatsInfo(data)
                <- parseHeaderNode("小区概况")
                <- parseNeighborhoodPropertyListNode(data)
                <- parseHeaderNode("周边配套")
                <- parseNeighorhoodNearByNode(data, disposeBag: self.disposeBag)
                <- parseHeaderNode("小区成交历史(\(totalSalesResponse.value?.data?.list?.count ?? 0))") { [unowned self] in
                    self.totalSalesResponse.value?.data?.list?.count ?? 0 > 0
                }
                <- parseTransactionRecordNode(totalSalesResponse.value)
                <- parseOpenAllNode((totalSalesResponse.value?.data?.list?.count ?? 0 > 3)) { [unowned self] in
                    if let id = data.id {
                        self.openTransactionHistoryPage(neighborhoodId: id)
                    }
                }
                <- parseHeaderNode("同小区房源(\(houseInSameNeighborhood.value?.data?.total ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value != nil
                }
                <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data, navVC: self.navVC)
                <- parseOpenAllNode((houseInSameNeighborhood.value?.data?.total ?? 0 > 5)) { [unowned self] in
                    if let id = data.id {
                        openErshouHouseList(neighborhoodId: id, disposeBag: self.disposeBag, navVC: self.navVC)
                    }
                }
                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.items?.count ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items, navVC: navVC)
                <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) { [unowned self] in
                    if let id = data.neighborhoodInfo?.id {
                        openRelatedNeighborhoodList(neighborhoodId: id, disposeBag: self.disposeBag, navVC: self.navVC)
                    }
                }
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }
    
    fileprivate func openTransactionHistoryPage(neighborhoodId: String) {
        let vc = TransactionHistoryVC(neighborhoodId: neighborhoodId)
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(vc, animated: true)
    }

}

func getNeighborhoodDetailPageViewModel() -> (UITableView, UINavigationController?) -> DetailPageViewModel {
    return { (tableView, navVC) in
        NeighborhoodDetailPageViewModel(tableView: tableView, navVC: navVC)
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
