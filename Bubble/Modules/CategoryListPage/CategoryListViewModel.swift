//
//  CategoryListViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class CategoryListViewModel: DetailPageViewModel {

    let disposeBag = DisposeBag()

    weak var tableView: UITableView?

    private var dataSource: CategoryListDataSource

    private var cellFactory: UITableViewCellFactory

    init(tableView: UITableView){
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = CategoryListDataSource(cellFactory: cellFactory)
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        cellFactory.register(tableView: tableView)
    }

    func requestData(houseId: Int64) {

    }

    func requestData(houseType: HouseType, query: String) {
        switch houseType {
        case .newHouse:
            requestNewHouseList(query: query)
        default:
            requestErshouHouseList(query: query)
        }
    }
    
    func requestNewHouseList(query: String) {
        requestCourtSearch(cityId: "133", query: query)
                .map { response -> [TableSectionNode] in
                    if let data = response?.data {
                        let dataParser = DetailDataParser.monoid()
                                <- parseNewHouseListItemNode(data.items)
                        return dataParser.parser([])
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: reloadData())
                .disposed(by: disposeBag)
    }

    func requestErshouHouseList(query: String) {
        requestSearch(query: query)
                .map { response -> [TableSectionNode] in
                    if let data = response?.data {
                        let dataParser = DetailDataParser.monoid()
                                <- parseErshouHouseListItemNode(data.items)
                        return dataParser.parser([])
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: reloadData())
                .disposed(by: disposeBag)
    }

    func reloadData() -> ([TableSectionNode]) -> Void {
        return { [unowned self] datas in
            self.dataSource.datas = datas
            self.tableView?.reloadData()
        }
    }

}

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

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

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = CategorySectionView()
//        view.categoryLabel.text = datas[section].label
//        return view
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas[indexPath.section].selectors?[indexPath.row]()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
