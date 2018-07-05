//
// Created by linlin on 2018/7/4.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class NewHouseDetailPageViewModel: NSObject, DetailPageViewModel {

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    private let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    init(tableView: UITableView){
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)

    }

    func requestData(houseId: Int64) {
        requestNewHouseDetail(houseId: houseId)
                .debug()
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        let result = self.processData(response: response)([])
                        self.dataSource.datas = result
                        self.tableView?.reloadData()
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
    }

    fileprivate func processData(response: HouseDetailResponse) -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = response.data {
            let dataParser = DetailDataParser.monoid()
                <- parseNewHouseCycleImageNode(data)
                <- parseNewHouseNameNode(data)
                <- parseNewHouseCoreInfoNode(data)
                <- parseNewHouseContactNode(data)
                <- parseTimeLineHeaderNode(data)
                <- parseTimelineNode(data)
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) {

                }
                <- parseFloorPanHeaderNode(data)
                <- parseFloorPanNode(data)
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) {

                }
                <- parseCommentHeaderNode(data)
                <- parseNewHouseCommentNode(data)
                <- parseOpenAllNode(data.timeLine?.hasMore ?? false) {

                }
                <- parseHeaderNode("周边位置")
                <- parseNewHouseNearByNode(data)
                <- parseHeaderNode("全网比价", showLoadMore: true)
                <- parseGlobalPricingNode(data)
                <- parseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }


}

func getNewHouseDetailPageViewModel() -> (UITableView) -> DetailPageViewModel {
    return { tableView in
        NewHouseDetailPageViewModel(tableView: tableView)
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
