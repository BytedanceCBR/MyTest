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

    let cellFactory: UITableViewCellFactory

    let disposeBag = DisposeBag()
    
    var openVC: ((UIViewController) -> Void)?
    
    weak var navVC: UINavigationController?

    fileprivate var favoriteDisposeBag = DisposeBag()

    fileprivate var userFavoriteCounts: [UserFollowListResponse?] = []


    init(tableView: UITableView, navVC: UINavigationController?) {
        self.tableView = tableView
        self.navVC = navVC
        self.cellFactory = getMineCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.backgroundColor = UIColor.white

        cellFactory.register(tableView: tableView)
        super.init()

        EnvContext.shared.client.accountConfig.userInfo
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] _ in
                self.reload()
            })
            .disposed(by: disposeBag)
    }

    func reload() {
        let datas = processData()([])
        dataSource.datas = datas
        tableView?.reloadData()
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        let userInfo = EnvContext.shared.client.accountConfig.userInfo.value
        
        let dataParser = DetailDataParser.monoid()
            <- parseUserInfoNode(
                userInfo,
                openEditProfile: { [weak self] (vc) in self?.openVC?(vc) },
                disposeBag: disposeBag)
            <- parseFavoriteNode(
                disposeBag: disposeBag,
                userFavoriteCounts: userFavoriteCounts,
                navVC: navVC)
            <- parseOptionNode(
                icon: #imageLiteral(resourceName: "star-simple-line-icons"),
                label: "我的收藏",
                isShowBottomLine: true) { (_) in
                    if let vc = TTFavoriteHistoryViewController(routeParamObj: TTRouteParamObjWithDict(["stay_id": "favorite"])) {
                        self.openVC?(vc)
                    }
            }
            <- parseOptionNode(
                icon: #imageLiteral(resourceName: "bubbles-simple-line-icons"),
                label: "用户反馈",
                isShowBottomLine: true) { (_) in
                    let vc = SSFeedbackViewController()
                    self.openVC?(vc)

                    let map = ["event_type":"house_app2c", "click_type":"feedback", "page_type":"minetab"]
                    recordEvent(key: TraceEventName.click_minetab, params: map)
                    
                    recordEvent(key: TraceEventName.go_detail, params: ["page_type":"feedback", "enter_from": "minetab"])
                    
            }
            <- parseOptionNode(
                icon: #imageLiteral(resourceName: "setting-simple-line-icons"),
                label: "系统设置",
                isShowBottomLine: true) { (_) in
                    let vc = SettingViewController(routeParamObj: TTRouteParamObjWithDict(["enter_type": "more"]))
                    self.openVC?(vc)
                    
                    let map = ["event_type":"house_app2c", "click_type":"setting", "page_type":"minetab"]
                    recordEvent(key: TraceEventName.click_minetab, params: map)
                    
                    recordEvent(key: TraceEventName.go_detail, params: ["page_type":"setting", "enter_from": "minetab"])
                    
            }

        return dataParser.parser
    }

    func requestFavoriteCount() {
        let obvs = [HouseType.secondHandHouse,
                    HouseType.newHouse,
                    HouseType.neighborhood]
            .map { (type) -> Observable<UserFollowListResponse?> in
                requestFollowUpList(houseType: type)
        }
        let favoriteResult = Observable.zip(obvs)
        favoriteDisposeBag = DisposeBag()
        favoriteResult
            .subscribe(onNext: { [unowned self] (responses) in

                self.userFavoriteCounts = responses
                self.reload()
            }, onError: { (error) in

            })
            .disposed(by: favoriteDisposeBag)

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
        datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
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
            .addCellClass(cellType: MineOptionCell.self)
}
