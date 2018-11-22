//
//  HouseRentDetailViewModel.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation
import RxSwift
import RxCocoa
class HouseRentDetailViewMode: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewTracer {
    var datas: [TableSectionNode] = []

    var disposeBag = DisposeBag()

    var cellFactory: UITableViewCellFactory

    private var relateErshouHouseData = BehaviorRelay<RelatedHouseResponse?>(value: nil)

    private var houseInSameNeighborhood = BehaviorRelay<SameNeighborhoodHouseResponse?>(value: nil)

    var navVC: UINavigationController?

    weak var tableView: UITableView?

    var houseRentTracer: HouseRentTracer

    private var elementShowIndexPathCache: [IndexPath] = []
    private var sectionShowCache: [Int] = []

    init(houseRentTracer: HouseRentTracer) {
        cellFactory = getHouseDetailCellFactory()
        self.houseRentTracer = houseRentTracer
        super.init()
        datas = processData()([])
        Observable
            .combineLatest(houseInSameNeighborhood, relateErshouHouseData)
//            .combineLatest(relateErshouHouseData)
            .subscribe(onNext: { [weak self] (_) in
                if let result = self?.processData()([]) {

                    self?.datas = result
                    self?.tableView?.reloadData()
                    DispatchQueue.main.async {
                        if let tableView = self?.tableView, let datas = self?.datas {
                            self?.traceDisplayCell(tableView: tableView, datas: datas)
                            self?.bindTableScrollingTrace()
                        }
                    }

                }
            }).disposed(by: disposeBag)
    }

    func bindTableScrollingTrace() {
        self.tableView?.rx.didScroll
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self, weak tableView] void in
                self?.traceDisplayCell(tableView: tableView, datas: self?.datas ?? [])
            }.disposed(by: disposeBag)
    }

    func traceDisplayCell(tableView: UITableView?, datas: [TableSectionNode]) {
        let indexPaths = tableView?.indexPathsForVisibleRows
        let params = EnvContext.shared.homePageParams
        indexPaths?.forEach({ (indexPath) in
            if !elementShowIndexPathCache.contains(indexPath) {
                self.callTracer(
                    tracer: datas[indexPath.section].tracer,
                    atIndexPath: indexPath,
                    traceParams: params)
                elementShowIndexPathCache.append(indexPath)
            }

            if !sectionShowCache.contains(indexPath.section),
                let tracer = datas[indexPath.section].sectionTracer {
                tracer(params)
                sectionShowCache.append(indexPath.section)
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                theCell.hasShowOnScreen = true
            } else if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionNeighborhoodCell {
                theCell.hasShowOnScreen = true
            }

        })


    }

    func registerCell(tableView: UITableView) {
        cellFactory.register(tableView: tableView)
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
//        self.houseRentTracer?.logPb
        self.houseRentTracer.recordGoDetail()


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
            <- parseRentCoreInfoCellNode(tracer: houseRentTracer)
            <- parseRentPropertyListCellNode(infos)
            //房屋配置
            <- parseRentHouseFacility()
            //房屋概况
            <- parseRentHouseSummarySection()
            // 小区测评
            <- parseRentNeighborhoodInfo()
            // 同小区房源
            <- parseRentSearchInNeighborhoodNodeCollection()
            // 周边房源
            <- parseRentErshouHouseListItemNode()
            <- parseRentDisclaimerCellNode()
        return dataParser.parser
    }

    func parseRentHouseSummarySection() -> () -> [TableSectionNode]? {
        let header = combineParser(left: parseFlineNode(), right: parseRentSummaryHeaderCellNode("房屋概况"))
        return parseNodeWrapper(preNode: header, wrapedNode: parseRentSummaryCellNode(tracer: houseRentTracer))
    }

    func parseRentHouseFacility() -> () -> [TableSectionNode]? {
        let header = combineParser(left: parseFlineNode(), right: parseHeaderNode("房屋配置", adjustBottomSpace: 0))
        return parseNodeWrapper(preNode: header, wrapedNode: parseRentFacilityCellNode(tracer: houseRentTracer))
    }

    func parseRentNeighborhoodInfo() -> () -> [TableSectionNode]? {
        let header = combineParser(left: parseFlineNode(), right: parseHeaderNode("小区 远洋沁山水", showLoadMore: true, adjustBottomSpace: 0))
        return parseNodeWrapper(preNode: header, wrapedNode: parseRentNeighborhoodInfoNode(tracer: houseRentTracer))
    }

    func parseRentSearchInNeighborhoodNodeCollection() -> () -> [TableSectionNode]? {
        let params = TracerParams.momoid()
        return parseNodeWrapper(preNode: parseHeaderNode("同小区房源"),
                                wrapedNode: parseRentSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data,
                                                                              tracer: houseRentTracer,
                                                                              traceExtension: params,
                                                                              navVC: navVC,
                                                                              tracerParams: params))
    }

    func parseRentErshouHouseListItemNode() -> () -> [TableSectionNode]? {
        let relatedErshouItems = relateErshouHouseData.value?.data?.items?.map({ (item) -> HouseItemInnerEntity in
//            var newItem = item
            return item
        })
        let params = TracerParams.momoid()
        let header = combineParser(left: parseFlineNode(), right: parseHeaderNode("周边房源", adjustBottomSpace: 0))
        let result = parseRentReleatedHouseListItemNode(
            relatedErshouItems,
            traceExtension: params,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: self.navVC)
        return parseNodeWrapper(preNode: header, wrapedNode: result)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections \(datas.count)")
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.count > section {
            print("section - \(section) numberOfRowsInSection \(datas[section].items.count)")
            return datas[section].items.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 13 {
            print("")
        }
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
        if datas[indexPath.section].selectors?.isEmpty ?? true == false {
            datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
        }
    }

    func requestReletedData() {
//        if let neighborhoodId = "1" {


        requestRelatedHouseSearch(houseId: "6580954921640673544")
            .subscribe(onNext: { [unowned self] response in
                self.relateErshouHouseData.accept(response)
            })
            .disposed(by: disposeBag)



        //            requestSearch(offset: 0, query: "neighborhood_id=\(neighborhoodId)&house_id=\(houseId)&house_type=\(HouseType.secondHandHouse.rawValue)")
        requestHouseInSameNeighborhoodSearch(neighborhoodId: "6581418262955819268", houseId: "6580954921640673544")
            .subscribe(onNext: { [unowned self] response in
                self.houseInSameNeighborhood.accept(response)
            })
            .disposed(by: disposeBag)

//        }

        let task = HouseRentAPI.requestHouseRentRelated()
    }

}

