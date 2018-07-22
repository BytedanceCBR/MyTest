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
class ErshouHouseDetailPageViewModel: NSObject, DetailPageViewModel {

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    private var cellFactory: UITableViewCellFactory

    private var ershouHouseData = BehaviorRelay<ErshouHouseDetailResponse?>(value: nil)

    private var relateNeighborhoodData = BehaviorRelay<RelatedNeighborhoodResponse?>(value: nil)

    private var houseInSameNeighborhood = BehaviorRelay<HouseRecommendResponse?>(value: nil)

    private var relateErshouHouseData = BehaviorRelay<RelatedHouseResponse?>(value: nil)

    private var houseId: Int64 = -1

    var contactPhone: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource

        cellFactory.register(tableView: tableView)
        ershouHouseData
            .map { (response) -> String? in
                let phone = response?.data?.contact["phone"] as? String
                return phone
            }
            .bind(to: contactPhone)
            .disposed(by: disposeBag)
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
        self.houseId = houseId
        requestErshouHouseDetail(houseId: houseId)
                .debug()
                .subscribe(onNext: { [unowned self] (response) in
                    if let response = response {
                        self.titleValue.accept(response.data?.title)
                        self.ershouHouseData.accept(response)
                        self.requestReletedData()
                    }

                    if let status = response?.data?.userStatus {
                        self.followStatus.accept(Result.success(status.houseSubStatus == 1))
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
        requestRelatedHouseSearch(houseId: "\(houseId)")
            .subscribe(onNext: { [unowned self] response in
                self.relateErshouHouseData.accept(response)
            })
            .disposed(by: disposeBag)

    }

    func followThisItem() {
        switch followStatus.value {
        case let .success(status):
            if status {
                cancelFollowIt(
                        houseType: .secondHandHouse,
                        followAction: .ershouHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag)()
            } else {
                followIt(
                        houseType: .secondHandHouse,
                        followAction: .ershouHouse,
                        followId: "\(houseId)",
                        disposeBag: disposeBag)()
            }
        case .failure(_): do {}
        }

    }

    func requestReletedData() {
        if let neighborhoodId = ershouHouseData.value?.data?.neighborhoodInfo?.id {
            requestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId)
                .subscribe(onNext: { [unowned self] response in
                    self.relateNeighborhoodData.accept(response)
                })
                .disposed(by: disposeBag)
            
            requestSearch(query: "neighborhood_id=\(neighborhoodId)&house_type=2")
                .subscribe(onNext: { [unowned self] response in
                    self.houseInSameNeighborhood.accept(response)
                })
                .disposed(by: disposeBag)

        }
        
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
        if let data = ershouHouseData.value?.data {

            let openBeighBor = openFloorPanDetailPage(floorPanId: data.neighborhoodInfo?.id)

            let dataParser = DetailDataParser.monoid()
                    <- parseErshouHouseCycleImageNode(data)
                    <- parseErshouHouseNameNode(data)
                    <- parseErshouHouseCoreInfoNode(data)
                    <- parsePropertyListNode(data)
                    <- parseHeaderNode("小区详情", subTitle: "查看小区", showLoadMore: true, process: openBeighBor)
                    <- parseNeighborhoodInfoNode(data)
                    <- parseHeaderNode("同小区房源(\(houseInSameNeighborhood.value?.data?.items?.count ?? 0))") { [unowned self] in
                        self.houseInSameNeighborhood.value?.data?.items?.count ?? 0 > 0
                    }
                    <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data)
                    <- parseOpenAllNode((houseInSameNeighborhood.value?.data?.items?.count ?? 0 > 0)) { [unowned self] in
                        if let id = data.neighborhoodInfo?.id {
                            self.openErshouHouseList(neighborhoodId: id, disposeBag: self.disposeBag)
                        }
            }
                    <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.items?.count ?? 0))") { [unowned self] in
                        self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                    }
                    <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items)
                    <- parseOpenAllNode((relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0)) { [unowned self] in
                        if let id = data.neighborhoodInfo?.id {
                            openRelatedNeighborhoodList(neighborhoodId: id, disposeBag: self.disposeBag)
                        }
                    }
                    <- parseHeaderNode("相关推荐")
                    <- parseErshouHouseListItemNode(relateErshouHouseData.value?.data?.items, disposeBag: disposeBag)
                    <- parseErshouHouseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    fileprivate func openFloorPanDetailPage(floorPanId: String?) -> () -> Void {
        return { [unowned self] in
            if let floorPanId = floorPanId, let id = Int64(floorPanId) {
                openNeighborhoodDetailPage(neighborhoodId: Int64(id), disposeBag: self.disposeBag)()
            }
        }
    }

    private func openErshouHouseList(neighborhoodId: String, disposeBag: DisposeBag) {
        let listVC = ErshouHouseListVC(neighborhoodId: neighborhoodId)
        listVC.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(listVC, animated: true)
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
        if datas[indexPath.section].selectors?.isEmpty ?? true == false {
            datas[indexPath.section].selectors?[indexPath.row]()
        }
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

func parseErshouHouseListItemNode(_ data: [HouseItemInnerEntity]?, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag) }
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

func parseErshouHouseListRowItemNode(_ data: [HouseItemInnerEntity]?, disposeBag: DisposeBag) -> [TableRowNode] {
    let selectors = data?
        .filter { $0.id != nil }
        .map { Int64($0.id!) }
        .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag) }
    if let renders = data?.map(curry(fillErshouHouseListitemCell)), let selectors = selectors {
        return zip(selectors, renders).map({ (e) -> TableRowNode in
            let (selector, render) = e
            return TableRowNode(
                itemRender: render,
                selector: selector,
                type: .node(identifier: SingleImageInfoCell.identifier),
                editor: nil)
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
            createTagAttrString(
                item.content,
                textColor: hexStringToUIColor(hex: item.textColor),
                backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
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

func parseFollowUpListRowItemNode(_ data: UserFollowData, disposeBag: DisposeBag) -> [TableRowNode] {
    let adapters = data.items
        .filter { $0.followId != nil }
        .map { item -> (TableCellSelectedProcess, (BaseUITableViewCell) -> Void, (UITableViewCellEditingStyle) -> Observable<TableRowEditResult>) in
            let selector = openErshouHouseDetailPage(houseId: Int64(item.followId!)!, disposeBag: disposeBag)
            let render = curry(fillFollowUpListItemCell)(item)
            let editor = { (style: UITableViewCellEditingStyle) -> Observable<TableRowEditResult> in
                if let ht = HouseType(rawValue: item.houseType ?? -1), let followId = item.followId {
                    return cancelFollowUp(houseType: ht, followId: followId)
                } else {
                    return .empty()
                }
            }
            return (selector, render, editor)
        }

    return adapters.map({ e -> TableRowNode in
        let (selector, render, editor) = e
        return TableRowNode(
            itemRender: render,
            selector: selector,
            type: .node(identifier: SingleImageInfoCell.identifier),
            editor: editor)
    })

}

func cancelFollowUp(houseType: HouseType, followId: String) -> Observable<TableRowEditResult> {
    if let actionType = FollowActionType(rawValue: houseType.rawValue) {
        return requestCancelFollow(
                houseType: houseType,
                followId: followId,
                actionType: actionType)
                .map { response -> TableRowEditResult in
                    if response?.status ?? -1 != 0 {
                        return TableRowEditResult.success(response?.message ?? "取消成功")
                    } else {
                        if let status = response?.status, let message = response?.message {
                            return TableRowEditResult.error(BizError.bizError(status, message))
                        } else {
                            return TableRowEditResult.error(BizError.unknownError)
                        }
                    }
                }
    } else {
        return .empty()
    }
}

func fillFollowUpListItemCell(_ data: UserFollowData.Item, cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.title
        theCell.extendTitle.text = data.description

        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.map({ (item) -> NSAttributedString in
            createTagAttrString(
                    item.content,
                    textColor: hexStringToUIColor(hex: item.textColor),
                    backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
        })

        attrTexts?.forEach({ (attrText) in
            text.append(attrText)
        })

        theCell.areaLabel.attributedText = text
        theCell.priceLabel.text = data.pricePerSqm

        if let img = data.images.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func openErshouHouseDetailPage(houseId: Int64, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: houseId,
            houseType: .newHouse,
            isShowBottomBar: true,
            provider: getErshouHouseDetailPageViewModel())
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}
