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

    var floorPanId: Int64 = -1
    var logPB: Any?

    weak var tableView: UITableView?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "house_model_detail")

    let datas: BehaviorRelay<[TableSectionNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: ((Bool) -> Void)?

    private var cellFactory: UITableViewCellFactory

    private let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?
    
    var bottomBarBinder: FollowUpBottomBarBinder?

    var tracerParams = TracerParams.momoid()

    var hasShow = false
    
    var isHiddenBottomBar: Bool
    
    init(tableView: UITableView, isHiddenBottomBar: Bool = true,navVC: UINavigationController?, followPage: BehaviorRelay<String>) {
        self.navVC = navVC
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.followPage = followPage
        self.isHiddenBottomBar = isHiddenBottomBar
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.register(MultitemCollectionCell.self, forCellReuseIdentifier: "MultitemCollectionCell-floorPan")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        datas
                .subscribe(onNext: { [unowned self] _ in
                    self.tableView?.reloadData()
                })
                .disposed(by: disposeBag)
        tableView.rx.didScroll
                .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
//                .debug()
                .bind { [weak tableView] void in
                    tableView?.indexPathsForVisibleRows?.forEach { indexPath in
                        if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                            theCell.hasShowOnScreen = true
                        }
                    }
                }.disposed(by: disposeBag)
    }

    func request(floorPanId: Int64) {
//        print("routeParamObj1: \(self.floorPanId)")

        requestFloorPlanInfo(floorPanId: "\(self.floorPanId)")
                .debug("request floowPanID")
                .subscribe(onNext: { [unowned self] response in
                    if let data = response?.data {
                        
                        self.logPB = data.logPB
                        self.datas.accept(self.dataParserByData(data: data).parser([]))
                    }
                })
                .disposed(by: disposeBag)
    }

    func dataParserByData(data: FloorPlanInfoData) -> DetailDataParser {
        
        var pictureParams = EnvContext.shared.homePageParams <|> toTracerParams("house_model_detail", key: "page_type")
        pictureParams = pictureParams <|>
            toTracerParams(self.floorPanId, key: "group_id") <|>
            toTracerParams(selectTraceParam(self.tracerParams, key: "search_id") ?? "be_null", key: "search_id") <|>
            toTracerParams(self.logPB ?? [:], key: "log_pb")

        let traceParamsDic = tracerParams.paramsGetter([:])

        let dataParser = DetailDataParser.monoid()
            <- parseCycleImageNode(data.images, traceParams: pictureParams, disposeBag: disposeBag)
            <- parseFloorPlanHouseTypeNameNode(data)
            <- parseFloorPlanPropertyListNode(data)
            <- parseFloorPlanRecommendHeaderNode(isShow: data.recommend.count>0)
            <- parseFloorPanCollectionNode(data.recommend,isHiddenBottomBar: isHiddenBottomBar,logPb: traceParamsDic["log_pb"],navVC: navVC,followPage: followPage, bottomBarBinder: bottomBarBinder ?? { (_, _, _) in })
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
        datas.value[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3, hasShow != true {
            hasShow = true
            
            let traceParamsDic = tracerParams.paramsGetter([:])
            var traceExtension: TracerParams = TracerParams.momoid()
            if let code = traceParamsDic["rank"] as? Int {
                traceExtension = traceExtension <|>
                    toTracerParams(String(code), key: "rank") <|>
                    toTracerParams(self.logPB ?? "be_null", key: "log_pb")
            }
            
            if let searchid = traceParamsDic["search_id"] as? String {
                traceExtension = traceExtension <|>
                    toTracerParams(searchid, key: "search_id")
            }
            
            if let logPb = traceParamsDic["log_pb"]{
                traceExtension = traceExtension <|>
                    toTracerParams(logPb, key: "log_pb")
            }
            
            
            let params = (EnvContext.shared.homePageParams <|>
                    toTracerParams("house_model_detail", key: "page_type") <|>
                    toTracerParams(self.floorPanId, key: "group_id") <|>
                    toTracerParams("related", key: "element_type")) <|>
                    traceExtension
                    .exclude("operation_style")
                    .exclude("operation_name")

//                toTracerParams(self.logPB ?? [:], key: "log_pb")
            recordEvent(key: "element_show", params: params.exclude("filter").exclude("search"))
        }
    }

    // 解决ios10cell高度不正常问题
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func cleanData() {
        self.datas.accept([])
    }
}
