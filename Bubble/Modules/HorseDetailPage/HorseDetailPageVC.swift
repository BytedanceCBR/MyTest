//
//  HorseDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import Charts
import RxSwift
import RxCocoa

class HorseDetailPageVC: BaseViewController {

    private let houseId: Int
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()

    private let dataSource: DataSource

    init(houseId: Int, houseType: HouseType) {
        self.houseId = houseId
        self.houseType = houseType
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
        cellFactory.register(tableView: tableView)

        requestNewHouseDetail(houseId: 6573911052528910605)
            .debug()
            .subscribe(onNext: { [unowned self] (response) in
                if let data = response?.data {
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

                    let result = dataParser.parser([])
                    self.dataSource.datas = result
                    print(result)
                    self.tableView.reloadData()
                }
                }, onError: { (error) in
                    print(error)
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
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


