//
// Created by linlin on 2018/7/5.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeListViewModel: DetailPageViewModel {
    
    var logPB: Any?

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "be_null")

    var traceParams = TracerParams.momoid()

    var followTraceParams: TracerParams = TracerParams.momoid()

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    private var cellFactory: UITableViewCellFactory

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    weak var navVC: UINavigationController?

    var homePageCommonParams: TracerParams = TracerParams.momoid()

    init(tableView: UITableView, navVC: UINavigationController?) {
        self.navVC = navVC
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        cellFactory.register(tableView: tableView)
    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        requestHouseRecommend()
            .map { [unowned self] response -> [TableSectionNode] in
                let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
                let entrys = config?.entryList.filter { $0.entryId != 5 }
                let homeCommonParams = EnvContext.shared.homePageParams
                if let data = response?.data {
                    let dataParser = DetailDataParser.monoid()
                        <- parseSpringboardNode(entrys ?? [], disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpNode(config?.opData, traceParams: homeCommonParams, disposeBag: self.disposeBag)
                        <- parseErshouHouseListItemNode(data.house?.items, disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpenAllNode(data.house?.items?.count ?? 0 > 0) { [unowned self] in
                            EnvContext.shared.homePageParams = self.homePageCommonParams <|>
                                    toTracerParams("list_loadmore", key: "maintab_entrance") <|>
                                    toTracerParams("maintab_list_loadmore", key: "element_from")

                            let traceParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("old_list", key: "category_name")

                            self.openCategoryList(
                                houseType: .secondHandHouse,
                                traceParams: traceParams,
                                condition: ConditionAggregator.monoid().aggregator)

                            let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("maintab_old_list", key: "element_type") <|>
                                beNull(key: "group_id") <|>
                                    beNull(key: "log_pb") <|>
                                toTracerParams("new_detail", key: "page_type")
                            recordEvent(key: "click_loadmore", params: loadMoreParams)
                        }
                        <- parseNewHouseListItemNode(data.court, disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpenAllNode(data.court?.items?.count ?? 0 > 0, isShowBottomBar: false) {
                            EnvContext.shared.homePageParams =  self.homePageCommonParams <|>
                                toTracerParams("list_loadmore", key: "maintab_entrance") <|>
                                toTracerParams("maintab_list_loadmore", key: "element_from")
                            let traceParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("new_list", key: "category_name")
                            self.openCategoryList(
                                houseType: .newHouse,
                                traceParams: traceParams,
                                condition: ConditionAggregator.monoid().aggregator)
                            let loadMoreParams = EnvContext.shared.homePageParams <|>
                                toTracerParams("maintab_new_list", key: "element_type") <|>
                                beNull(key: "group_id") <|>
                                beNull(key: "log_pb") <|>
                                toTracerParams("new_detail", key: "page_type")
                            recordEvent(key: "click_loadmore", params: loadMoreParams)
                        }
                    return dataParser.parser([])
                } else {
                    return []
                }
            }
            .subscribe(onNext: { [unowned self] response in
                self.dataSource.datas = response
                self.tableView?.reloadData()
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                }, onError: { error in
                    print(error)
            }, onCompleted: {

            })
            .disposed(by: disposeBag)
    }


    func followThisItem() {
        followIt(
            houseType: .newHouse,
            followAction: .newHouse,
            followId: "\(houseId)",
            disposeBag: disposeBag)()
    }

    private func openCategoryList(
        houseType: HouseType,
        traceParams: TracerParams,
        condition: @escaping (String) -> String) {
        let vc = CategoryListPageVC(isOpenConditionFilter: true)
        vc.tracerParams = traceParams
        vc.houseType.accept(houseType)
        vc.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator {
            condition($0)
        }
        vc.navBar.isShowTypeSelector = false
        navVC?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
               self.navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

}

fileprivate func parseOpNode(
    _ data: OpData?,
    traceParams: TracerParams,
    disposeBag: DisposeBag) -> () -> TableSectionNode? {
    let theParams = traceParams <|>
            toTracerParams("operation", key: "maintab_entrance") <|>
            toTracerParams(data?.opStyle ?? "", key: "operation_style") <|>
            beNull(key: "log_pb") <|>
            toTracerParams("maintab", key: "page_type")
    if data?.opStyle == 1 {
        return parseFlatOpNode(data?.items ?? [], traceParams: theParams, disposeBag: disposeBag)
    } else {
        return parseGridOpNode(data?.items ?? [], traceParams: theParams, disposeBag: disposeBag)
    }
}

func parseNewHouseListItemNode(
    _ data: CourtRecommendSection?,
    disposeBag: DisposeBag,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let selectors = data?.items?
                .filter { $0.id != nil }
                .map { Int64($0.id!) }
                .map { openNewHouseDetailPage(
                    houseId: $0!, disposeBag:
                    disposeBag, navVC:
                    navVC)
                }
        let params = TracerParams.momoid() <|>
                toTracerParams("new", key: "house_type") <|>
                toTracerParams("left_pic", key: "card_type")
        let records = data?.items?
                .filter { $0.id != nil }
                .enumerated()
                .map { (e) -> ElementRecord in
                    let (offset, item) = e
                    let theParams = params <|>
                            toTracerParams(offset, key: "rank") <|>
                            toTracerParams(item.id ?? "be_null", key: "group_id")
                    return onceRecord(key: "house_show", params: theParams)
                }

        if let renders = data?.items?.map(curry(fillNewHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                    items: renders,
                    selectors: selectors,
                    tracer: records,
                    label: data?.title ?? "优选楼盘",
                    type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func paresNewHouseListRowItemNode(
    _ data: [CourtItemInnerEntity]?,
        traceParams: TracerParams,
    disposeBag: DisposeBag,
    navVC: UINavigationController?) -> [TableRowNode] {
    let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openNewHouseDetailPage(houseId: $0!, disposeBag: disposeBag, navVC: navVC) }
    let params = TracerParams.momoid() <|>
            toTracerParams("new", key: "house_type") <|>
            toTracerParams("left_pic", key: "card_type")

    let records = data?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = params <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams(item.id ?? "be_null", key: "group_id")
                return onceRecord(key: "house_show", params: theParams)
            }
    if let renders = data?.map(curry(fillNewHouseListitemCell)),
       let selectors = selectors,
       let records = records {
        let items = zip(selectors, records)
        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                    tracer: item.1,
                type: .node(identifier: SingleImageInfoCell.identifier),
                editor: nil)
        }

    }
    return []
}

func fillNewHouseListitemCell(_ data: CourtItemInnerEntity, cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.displayTitle
        theCell.extendTitle.text = data.displayDescription
        let text = NSMutableAttributedString()

        let attrTexts = data.tags?.map({ (item) -> NSAttributedString in
            createTagAttrString(
                item.content,
                textColor: hexStringToUIColor(hex: item.textColor),
                backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
        })

        var height: CGFloat = 0
        attrTexts?.enumerated().forEach({ (e) in
            let (offset, tag) = e

            text.append(tag)

            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 159, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        })

        theCell.areaLabel.attributedText = text

        theCell.priceLabel.text = data.displayPricePerSqm
        theCell.roomSpaceLabel.text = ""
        if let img = data.courtImage?.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func openNewHouseDetailPage(houseId: Int64, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
                houseId: houseId,
                houseType: .newHouse,
                isShowBottomBar: true)
        detailPage.pageViewModelProvider = { [unowned detailPage] (tableView, infoMaskView, navVC) in
            getNewHouseDetailPageViewModel(
                detailPageVC: detailPage,
                infoMaskView: infoMaskView,
                navVC: navVC,
                tableView: tableView)
        }

        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
         navVC?.pushViewController(detailPage, animated: true)
    }
}

func openNeighborhoodDetailPage(neighborhoodId: Int64, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: neighborhoodId,
            houseType: .neighborhood,
            isShowFollowNavBtn: true,
            provider: getNeighborhoodDetailPageViewModel())
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
         navVC?.pushViewController(detailPage, animated: true)
    }
}

fileprivate class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource, TableViewTracer {

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

        //控件展现打点
        var params = EnvContext.shared.homePageParams
        if let type = homeListTypeBySection(indexPath.section), indexPath.row == 0 {
            params = params <|>
                    toTracerParams(type, key: "element_type") <|>
                    toTracerParams("maintab", key: "page_type") <|>
                    toTracerParams("maintab", key: "maintab_entrance") <|>
                    beNull(key: "group_id")
            recordEvent(key: TraceEventName.element_show, params: params)
        }

        switch datas[indexPath.section].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            if indexPath.row == 0 {
                cell.isHead = true
            } else if datas[indexPath.section].items.count == (indexPath.row + 1) {
                cell.isTail = true
            }
            datas[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CategorySectionView()
        view.categoryLabel.text = datas[section].label
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if datas[section].selectors?.count ?? 0 == 0 {
            return 0
        } else {
            return 38
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas[indexPath.section].selectors?[indexPath.row]()
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams("maintab", key: "page_type") <|>
                toTracerParams("maintab_list", key: "element_type") <|>
                beNull(key: "log_pb") <|>
                toTracerParams("list", key: "maintab_entrance")
    }

    fileprivate func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let houseShowParams = houseParams()

        callTracer(
                tracer: datas[indexPath.section].tracer,
                atIndexPath: indexPath,
                traceParams: houseShowParams)
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    fileprivate func houseParams() -> TracerParams {
        return EnvContext.shared.homePageParams <|>
            toTracerParams("maintab", key: "page_type") <|>
            toTracerParams("maintab_list", key: "element_type") <|>
            beNull(key: "log_pb") <|>
            toTracerParams("list", key: "maintab_entrance")
    }

}

fileprivate func homeListTypeBySection(_ section: Int) -> String? {
    switch section {
        case 2:
            return "maintab_old_list"
        case 4:
            return "maintab_new_list"
        default:
            return nil
    }
}
