//
//  ErshouHouseDetailPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ErshouHouseDetailPageViewModel: NSObject, DetailPageViewModel {

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var ershouHouseData = BehaviorRelay<ErshouHouseDetailResponse?>(value: nil)

    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)

    private var relateErshouHouseData = BehaviorRelay<HouseRecommendResponse?>(value: nil)

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)
        super.init()
        ershouHouseData
                .subscribe { [unowned self] event in
                    let result = self.processData()([])
                    self.dataSource.datas = result
                    self.tableView?.reloadData()
                }
                .disposed(by: disposeBag)

        relateNeighborhoodData
                .subscribe { [unowned self] event in
                    let result = self.processData()([])
                    self.dataSource.datas = result
                    self.tableView?.reloadData()
                }
                .disposed(by: disposeBag)

        relateErshouHouseData
                .subscribe { [unowned self] event in
                    let result = self.processData()([])
                    self.dataSource.datas = result
                    self.tableView?.reloadData()
                }
                .disposed(by: disposeBag)
    }

    func requestData(houseId: Int64) {
        requestErshouHouseDetail(houseId: houseId)
                .debug()
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        self.ershouHouseData.accept(response)
                        self.requestReletedData()
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)

    }


    func requestReletedData() {
        if let neighborhoodId = ershouHouseData.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                    .subscribe(onNext: { [unowned self] response in
                        self.relateNeighborhoodData.accept(response)
                    })
                    .disposed(by: disposeBag)

            requestSearch(
                cityId: "133",
                query: "neighborhood_id=\(neighborhoodId)")
                .subscribe(onNext: { [unowned self] response in
                    self.relateErshouHouseData.accept(response)
                })
                .disposed(by: disposeBag)
        }

    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = ershouHouseData.value?.data {
            let dataParser = DetailDataParser.monoid()
                    <- parseErshouHouseCycleImageNode(data)
                    <- parseErshouHouseNameNode(data)
                    <- parseErshouHouseCoreInfoNode(data)
                    <- parsePropertyListNode(data)
                    <- parseHeaderNode("小区详情", showLoadMore: true)
                    <- parseNeighborhoodInfoNode(data)
                    <- parseHeaderNode("同小区房源") { [unowned self] in
                        self.relateNeighborhoodData.value != nil
                    }
                    <- parseSearchInNeighborhoodNode(relateErshouHouseData.value?.data)
                    <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
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
}

func getErshouHouseDetailPageViewModel() -> DetailPageViewModelProvider {
    return { tableView in
        ErshouHouseDetailPageViewModel(tableView: tableView)
    }
}
