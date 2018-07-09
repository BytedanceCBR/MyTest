//
// Created by linlin on 2018/7/7.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NeighborhoodDetailPageViewModel: DetailPageViewModel {

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
    private var houseInSameNeighborhood = BehaviorRelay<HouseRecommendResponse?>(value: nil)


    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)

        neighborhoodDetailResponse
                .subscribe { [unowned self] event in
                    let datas = self.processData()([])
                    self.dataSource.datas = datas
                    tableView.reloadData()
                }
                .disposed(by: disposeBag)

        totalSalesResponse
                .subscribe { [unowned self] event in
                    let datas = self.processData()([])
                    self.dataSource.datas = datas
                    tableView.reloadData()
                }
                .disposed(by: disposeBag)
        relateNeighborhoodData
            .subscribe { [unowned self] event in
                let result = self.processData()([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
        houseInSameNeighborhood
            .subscribe { [unowned self] event in
                let result = self.processData()([])
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

            requestSearch(
                    cityId: "133",
                    query: "&neighborhood_id=\(neighborhoodId)")
                    .subscribe(onNext: { [unowned self] response in
                        self.houseInSameNeighborhood.accept(response)
                    })
                    .disposed(by: disposeBag)

        }

    }

    func requestData(houseId: Int64) {
        requestNeighborhoodDetail(neighborhoodId: "\(houseId)")
                .subscribe(onNext: { [unowned self] (response) in
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

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = neighborhoodDetailResponse.value?.data {
            let dataParser = DetailDataParser.monoid()
                <- parseCycleImageNode(data.neighborhoodImage)
                <- parseNeighborhoodNameNode(data)
                <- parseNeighborhoodPriceNode(data)
                <- parseNeighborhoodStatsInfo(data)
                <- parseHeaderNode("小区概况")
                <- parseNeighborhoodPropertyListNode(data)
                <- parseHeaderNode("周边配套")
                <- parseNeighorhoodNearByNode(data)
                <- parseTransactionRecordNode(totalSalesResponse.value)
                <- parseHeaderNode("同小区房源") { [unowned self] in
                    self.relateNeighborhoodData.value != nil
                }
                <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data)
                <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) {

                }
                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.items?.count ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items)
                <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) {

            }
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

}

func getNeighborhoodDetailPageViewModel() -> (UITableView) -> DetailPageViewModel {
    return { tableView in
        NeighborhoodDetailPageViewModel(tableView: tableView)
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
        print(indexPath)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
