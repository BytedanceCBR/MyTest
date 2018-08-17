//
// Created by linlin on 2018/7/7.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NeighborhoodDetailPageViewModel: DetailPageViewModel {
    
    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "neighborhood_detail")

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var neighborhoodDetailResponse = BehaviorRelay<NeighborhoodDetailResponse?>(value: nil)

    //相关小区
    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)
    //小区内相关
    private var houseInSameNeighborhood = BehaviorRelay<SameNeighborhoodHouseResponse?>(value: nil)

    private var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    weak var navVC: UINavigationController?

    var cellsDisposeBag: DisposeBag!

    weak var infoMaskView: EmptyMaskView?

    var traceParams = TracerParams.momoid()

    init(tableView: UITableView, infoMaskView: EmptyMaskView, navVC: UINavigationController?) {
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        self.infoMaskView = infoMaskView
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

        infoMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                if self.houseId != -1 {
                    self.requestData(houseId: self.houseId)
                }
            }.disposed(by: disposeBag)
        
        self.bindFollowPage()
        
    }

    func requestReletedData() {
        if let neighborhoodId = neighborhoodDetailResponse.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.relateNeighborhoodData.accept(response)
                    })
                    .disposed(by: disposeBag)
//            requestSearch(offset: 0, query: "neighborhood_id=\(neighborhoodId)&house_type=\(HouseType.secondHandHouse.rawValue)")
            requestHouseInSameNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.houseInSameNeighborhood.accept(response)
                    })
                    .disposed(by: disposeBag)

        }

    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView?.isHidden = false
        } else {
            infoMaskView?.isHidden = true
        }
        requestNeighborhoodDetail(neighborhoodId: "\(houseId)")
                .retryOnConnect(timeout: 50)
                .retry(10)
                .subscribe(onNext: { [unowned self] (response) in
                    if let status = response?.data?.neighbordhoodStatus {
                        self.followStatus.accept(Result.success(status.neighborhoodSubStatus ?? 0 == 1))
                    }
                    self.titleValue.accept(response?.data?.name)
                    self.neighborhoodDetailResponse.accept(response)
                    self.requestReletedData()
                    self.infoMaskView?.isHidden = true
                }, onError: { (error) in
                    EnvContext.shared.toast.showToast("数据加载失败")
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
            let theParams = self.traceParams <|>
                EnvContext.shared.homePageParams <|>
                toTracerParams(data.logPB ?? [:], key: "log_pb") <|>
                beNull(key: "card_type") <|>
                toTracerParams("click", key: "enter_type") <|>
                toTracerParams("neighborhood_detail", key: "enter_from")


            let dataParser = DetailDataParser.monoid()
                <- parseCycleImageNode(data.neighborhoodImage, disposeBag: self.disposeBag)
                <- parseNeighborhoodNameNode(data, disposeBag: theDisposeBag)
                <- parseNeighborhoodStatsInfo(data)
                <- parseHeaderNode("小区概况") {
                    data.baseInfo != nil
                }
                <- parseNeighborhoodPropertyListNode(data)
                <- parseHeaderNode("周边配套") {
                    data.neighborhoodInfo != nil
                }
                <- parseNeighorhoodNearByNode(data, disposeBag: self.disposeBag)
                <- parseHeaderNode("小区成交历史(\(data.totalSalesCount ?? 0))") {
                    data.totalSalesCount ?? 0 > 0
                }
                <- parseTransactionRecordNode(data.totalSales?.list)
                <- parseOpenAllNode((data.totalSalesCount ?? 0 > 3)) { [unowned self] in
                    if let id = data.id {
                        let transactionTrace = theParams <|>
                            toTracerParams("neighborhood_trade_list", key: "category_name") <|>
                            toTracerParams("neighborhood_trade_loadmore", key: "element_from")

                        self.openTransactionHistoryPage(
                            neighborhoodId: id,
                            traceParams: transactionTrace,
                            bottomBarBinder: self.bindBottomView())
                    }
                }
                <- parseHeaderNode("小区房源(\(houseInSameNeighborhood.value?.data?.total ?? 0))") { [unowned self] in
                    self.houseInSameNeighborhood.value?.data?.items.count ?? 0 > 0
                }
                <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data, navVC: self.navVC)
                <- parseOpenAllNode((houseInSameNeighborhood.value?.data?.total ?? 0 > 5)) { [unowned self] in
                    if let id = data.id ,
                        let title = data.name {

                        let params = paramsOfMap([EventKeys.category_name: HouseCategory.same_neighborhood_list.rawValue]) <|>
                            theParams <|>
                            toTracerParams("slide", key: "card_type") <|>
                            toTracerParams(self.houseInSameNeighborhood.value?.data?.logPB ?? [:], key: "log_pb") <|>
                            toTracerParams("same_neighborhood_loadmore", key: "element_from")

                        openErshouHouseList(
//                                title: "\(data.name ?? "")(\(self.houseInSameNeighborhood.value?.data?.total ?? 0)",
                                title: title,
                                neighborhoodId: id,
                                disposeBag: self.disposeBag,
                                navVC: self.navVC,
                                searchSource: .neighborhoodDetail,
                                tracerParams: params,
                                bottomBarBinder: self.bindBottomView())
                    }
                }
                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.total ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items, navVC: navVC)
                <- parseOpenAllNode((relateNeighborhoodData.value?.data?.total ?? 0 > 5)) { [unowned self] in
                    if let id = data.neighborhoodInfo?.id {

                        let params = paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_nearby_list.rawValue]) <|>
                            theParams <|>
                            toTracerParams("slide", key: "card_type") <|>
                            toTracerParams(self.relateNeighborhoodData.value?.data?.logPB ?? [:], key: "log_pb") <|>
                            toTracerParams("neighborhood_nearby_loadmore", key: "element_from")

                        openRelatedNeighborhoodList(
                            neighborhoodId: id,
                            disposeBag: self.disposeBag,
                            tracerParams: params,
                            navVC: self.navVC,
                            bottomBarBinder: self.bindBottomView())
                    }
                }
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }
    
    fileprivate func openTransactionHistoryPage(
        neighborhoodId: String,
        traceParams: TracerParams,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        let vc = TransactionHistoryVC(neighborhoodId: neighborhoodId, bottomBarBinder: bottomBarBinder)
        vc.tracerParams = traceParams
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    self.navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        navVC?.pushViewController(vc, animated: true)
    }

}

func getNeighborhoodDetailPageViewModel() -> (UITableView, EmptyMaskView, UINavigationController?) -> DetailPageViewModel {
    return { (tableView, infoMaskView, navVC) in
        NeighborhoodDetailPageViewModel(tableView: tableView, infoMaskView: infoMaskView, navVC: navVC)
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
