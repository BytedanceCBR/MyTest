//
//  ErshouHouseDetailPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YYText
class ErshouHouseDetailPageViewModel: NSObject, DetailPageViewModel {

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var ershouHouseData = BehaviorRelay<ErshouHouseDetailResponse?>(value: nil)

    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)

    private var houseInSameNeighborhood = BehaviorRelay<HouseRecommendResponse?>(value: nil)

    private var relateErshouHouseData = BehaviorRelay<RelatedHouseResponse?>(value: nil)

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)
        super.init()
        ershouHouseData
            .subscribe { [unowned self] event in
                let result = self.processData()([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)

        relateNeighborhoodData
            .subscribe { [unowned self] event in
                let result = self.processData()([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
        houseInSameNeighborhood
            .subscribe { [unowned self] event in
                let result = self.processData()([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
        relateErshouHouseData
            .subscribe { [unowned self] event in
                let result = self.processData()([])
                self.dataSource.datas = result
                self.tableView?.reloadData()
            }
            .disposed(by: disposeBag)
    }

    func requestData(houseId: Int64) {

        requestErshouHouseDetail(houseId: houseId)
                .debug()
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        self.ershouHouseData.accept(response)
                        self.requestReletedData()
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
        requestRelatedHouseSearch(houseId: "\(houseId)")
            .debug("requestRelatedErshouHouse")
            .subscribe(onNext: { [unowned self] response in
                self.relateErshouHouseData.accept(response)
            })
            .disposed(by: disposeBag)

    }


    func requestReletedData() {
        if let neighborhoodId = ershouHouseData.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                .subscribe(onNext: { [unowned self] response in
                    self.relateNeighborhoodData.accept(response)
                })
                .disposed(by: disposeBag)
            
            requestSearch(
                cityId: "133",
                query: "&neighborhood_id=\(neighborhoodId)")
                .subscribe(onNext: { [unowned self] response in
                    self.houseInSameNeighborhood.accept(response)
                })
                .disposed(by: disposeBag)

        }
        
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = ershouHouseData.value?.data {
            let dataParser = DetailDataParser.monoid()
                    <- parseErshouHouseCycleImageNode(data)
                    <- parseErshouHouseNameNode(data)
                    <- parseErshouHouseCoreInfoNode(data)
                    <- parsePropertyListNode(data)
                    <- parseHeaderNode("小区详情", showLoadMore: true)
                    <- parseNeighborhoodInfoNode(data)
                    <- parseHeaderNode("同小区房源") { [unowned self] in
                        self.relateNeighborhoodData.value != nil
                    }
                    <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data)
                    <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) {

                    }
                    <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.items?.count ?? 0))") { [unowned self] in
                        self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                    }
                    <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items)
                    <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) {

                    }
                    <- parseErshouHouseListItemNode(relateErshouHouseData.value?.data?.items)
                    <- parseErshouHouseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
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

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

func getErshouHouseDetailPageViewModel() -> DetailPageViewModelProvider {
    return { tableView in
        ErshouHouseDetailPageViewModel(tableView: tableView)
    }
}

func parseErshouHouseListItemNode(_ data: [HouseItemInnerEntity]?) -> () -> TableSectionNode? {
    return {
        let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openErshouHouseDetailPage(houseId: $0!) }
        if let renders = data?.map(curry(fillErshouHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                label: "二手房源",
                type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func parseErshouHouseListRowItemNode(_ data: [HouseItemInnerEntity]?) -> [TableRowNode] {
    let selectors = data?
        .filter { $0.id != nil }
        .map { Int64($0.id!) }
        .map { openErshouHouseDetailPage(houseId: $0!) }
    if let renders = data?.map(curry(fillErshouHouseListitemCell)), let selectors = selectors {
        return zip(selectors, renders).map({ (e) -> TableRowNode in
            let (selector, render) = e
            return TableRowNode(
                itemRender: render,
                selector: selector,
                type: .node(identifier: SingleImageInfoCell.identifier))
        })
    } else {
        return []
    }
}

func fillErshouHouseListitemCell(_ data: HouseItemInnerEntity, cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.displayTitle
        theCell.extendTitle.text = data.displaySubtitle
        let text = NSMutableAttributedString()

        let attrTexts = data.tags?.map({ (item) -> NSAttributedString in
            createTagAttrString(item.content ?? "")
        })

        attrTexts?.forEach({ (attrText) in
            text.append(attrText)
        })

        theCell.areaLabel.attributedText = text

        theCell.priceLabel.text = data.displayPrice
        theCell.roomSpaceLabel.text = data.displayPricePerSqm
        if let img = data.houseImage?.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func openErshouHouseDetailPage(houseId: Int64) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: houseId,
            houseType: .newHouse,
            provider: getErshouHouseDetailPageViewModel())
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}
