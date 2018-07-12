//
// Created by linlin on 2018/7/8.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MinePageViewModel: NSObject, UITableViewDelegate {

    fileprivate let dataSource: DataSource

    weak var tableView: UITableView?

    var userInfo: UserInfo?

    let cellFactory: UITableViewCellFactory

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getMineCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        cellFactory.register(tableView: tableView)
        super.init()
    }

    func reload() {
        let datas = processData()([])
        dataSource.datas = datas
        tableView?.reloadData()
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        let dataParser = DetailDataParser.monoid()
                <- parseUserInfoNode(userInfo)
                <- parseHeaderNode("房源关注")
                <- parseFavoriteNode()
                <- parseTextRowCell()
        return dataParser.parser
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
        datas[indexPath.section].selectors?[indexPath.row]()
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}


func getMineCellFactory() -> UITableViewCellFactory {
    return UITableViewCellFactory()
            .addCellClass(cellType: UserInfoCell.self)
            .addCellClass(cellType: FavoriteCell.self)
            .addCellClass(cellType: HeaderCell.self)
            .addCellClass(cellType: TextRowCell.self)
}
