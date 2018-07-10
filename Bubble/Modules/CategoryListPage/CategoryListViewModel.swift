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

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    let disposeBag = DisposeBag()

    weak var tableView: UITableView?

    private var dataSource: CategoryListDataSource

    private var cellFactory: UITableViewCellFactory

    var pageableLoader: (() -> Void)?

    var onDataLoaded: (() -> Void)?

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
        case .secondHandHouse:
            requestErshouHouseList(query: query)
        default:
            requestNeigborhoodList(query: query)
        }
    }
    
    func requestNewHouseList(query: String) {
        let loader = pageRequestCourtSearch(cityId: "133", query: query)
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    if let data = response?.data {
                        return paresNewHouseListRowItemNode(data.items, disposeBag: self.disposeBag)
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: self.reloadData())
                .disposed(by:self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func requestErshouHouseList(query: String) {
        let loader = pageRequestErshouHouseSearch(query: query)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by:self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func requestNeigborhoodList(query: String) {
        let loader = pageRequestNeighborhoodSearch(cityId: "133", query: query)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseNeighborhoodRowItemNode(data.items, disposeBag: self.disposeBag)
                        } else {
                            return []
                        }
                    }
                    .subscribe(onNext: self.reloadData())
                    .disposed(by:self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func reloadData() -> ([TableRowNode]) -> Void {
        return { [unowned self] datas in
            self.dataSource.datas = self.dataSource.datas + datas
            self.tableView?.reloadData()
            self.onDataLoaded?()
        }
    }

    func cleanData() {
        self.dataSource.datas = []
    }

}

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var datas: [TableRowNode] = []

    var cellFactory: UITableViewCellFactory

    var sectionHeaderGenerator: TableViewSectionViewGen?

    init(cellFactory: UITableViewCellFactory) {
        self.cellFactory = cellFactory
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas[indexPath.row].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                identifer: identifier,
                tableView: tableView,
                indexPath: indexPath)
            datas[indexPath.row].itemRender(cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas[indexPath.row].selector()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
