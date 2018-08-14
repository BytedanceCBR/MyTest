//
//  FloorPanCategoryDetailPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/16.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class FloorPanCategoryDetailPageViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var tableView: UITableView?

    let datas: BehaviorRelay<[TableSectionNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool) -> Void)?

    private var cellFactory: UITableViewCellFactory

    private let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?
    
    var bottomBarBinder: FollowUpBottomBarBinder?
    
    init(tableView: UITableView, navVC: UINavigationController?) {
        self.navVC = navVC
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        datas
                .subscribe(onNext: { [unowned self] _ in
                    self.tableView?.reloadData()
                })
                .disposed(by: disposeBag)
    }

    func request(floorPanId: Int64) {
        requestFloorPlanInfo(floorPanId: "\(floorPanId)")
                .subscribe(onNext: { [unowned self] response in
                    if let data = response?.data {
                        self.datas.accept(self.dataParserByData(data: data).parser([]))
                    }
                })
                .disposed(by: disposeBag)
    }

    func dataParserByData(data: FloorPlanInfoData) -> DetailDataParser {
        let dataParser = DetailDataParser.monoid()
            <- parseCycleImageNode(data.images, disposeBag: disposeBag)
            <- parseFloorPlanHouseTypeNameNode(data)
            <- parseFloorPlanPropertyListNode(data)
            <- parseFloorPlanRecommendHeaderNode()
            <- parseFloorPanNode(data.recommend, navVC: navVC, bottomBarBinder: bottomBarBinder ?? { _ in })
        return dataParser
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.value[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas.value[indexPath.section].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas.value[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas.value[indexPath.section].selectors?[indexPath.row]()
    }

    // 解决ios10cell高度不正常问题
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func cleanData() {
        self.datas.accept([])
    }
}
