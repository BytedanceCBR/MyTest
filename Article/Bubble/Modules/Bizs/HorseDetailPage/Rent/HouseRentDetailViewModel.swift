//
//  HouseRentDetailViewModel.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation
import RxSwift
import RxCocoa
class HouseRentDetailViewMode: NSObject, UITableViewDataSource, UITableViewDelegate {
    var datas: [TableSectionNode] = []

    var disposeBag = DisposeBag()

    var cellFactory: UITableViewCellFactory


    override init() {
        cellFactory = getHouseDetailCellFactory()
        super.init()
        datas = processData()([])
    }

    func registerCell(tableView: UITableView) {
        cellFactory.register(tableView: tableView)
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {

        var infos:[ErshouHouseBaseInfo] = []
        var info = ErshouHouseBaseInfo(attr: "入住", value: "2018.07.12", isSingle: false)
        infos.append(info)
        info = ErshouHouseBaseInfo(attr: "发布", value: "2018.07.09", isSingle: false)
        infos.append(info)
        info = ErshouHouseBaseInfo(attr: "朝向", value: "南北", isSingle: false)
        infos.append(info)
        info = ErshouHouseBaseInfo(attr: "楼层", value: "高楼层/共23层", isSingle: false)
        infos.append(info)
        info = ErshouHouseBaseInfo(attr: "装修", value: "精装修", isSingle: false)
        infos.append(info)
        info = ErshouHouseBaseInfo(attr: "电梯", value: "有", isSingle: false)
        infos.append(info)

        let dataParser = DetailDataParser.monoid()
            <- parseRentHouseCycleImageNode(nil, disposeBag: disposeBag)
            <- parseRentNameCellNode()
            <- parseRentCoreInfoCellNode()
            <- parseRentPropertyListCellNode(infos)
            <- parseRentNeighborhoodInfoNode()
        return dataParser.parser
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.count > section {
            return datas[section].items.count
        } else {
            return 0
        }
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

}
