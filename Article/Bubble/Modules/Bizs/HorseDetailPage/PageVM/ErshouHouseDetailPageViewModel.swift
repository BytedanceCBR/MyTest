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
    
    weak var navVC: UINavigationController?

    init(tableView: UITableView, navVC: UINavigationController?) {
        self.navVC = navVC
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
            
            requestSearch(offset: 0, query: "neighborhood_id=\(neighborhoodId)&house_id=\(houseId)&house_type=\(HouseType.secondHandHouse.rawValue)")
//            requestHouseInSameNeighborhoodSearch(neighborhoodId: neighborhoodId, houseId: "\(houseId)")
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
                <- parseErshouHouseCycleImageNode(data, disposeBag: disposeBag)
                <- parseErshouHouseNameNode(data)
                <- parseErshouHouseCoreInfoNode(data)
                <- parsePropertyListNode(data)
                <- parseHeaderNode("小区详情", subTitle: "查看小区", showLoadMore: true, process: openBeighBor)
                <- parseNeighborhoodInfoNode(data, navVC: self.navVC)
                <- parseHeaderNode("同小区房源(\(houseInSameNeighborhood.value?.data?.total ?? 0))") { [unowned self] in
                    self.houseInSameNeighborhood.value?.data?.items?.count ?? 0 > 0
                }
                <- parseSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data, navVC: navVC)
                <- parseOpenAllNode((houseInSameNeighborhood.value?.data?.total ?? 0 > 5)) { [unowned self] in
                    if let id = data.neighborhoodInfo?.id {
                        openErshouHouseList(
                            title: nil,
                            neighborhoodId: id,
                            houseId: data.id,
                            disposeBag: self.disposeBag,
                            navVC: self.navVC,
                            searchSource: .oldDetail,
                            bottomBarBinder: self.bindBottomView())
                    }
                }
                <- parseHeaderNode("周边小区(\(relateNeighborhoodData.value?.data?.total ?? 0))") { [unowned self] in
                    self.relateNeighborhoodData.value?.data?.items?.count ?? 0 > 0
                }
                <- parseRelatedNeighborhoodNode(relateNeighborhoodData.value?.data?.items, navVC: self.navVC)
                <- parseOpenAllNode((relateNeighborhoodData.value?.data?.total ?? 0 > 5)) { [unowned self] in
                    if let id = data.neighborhoodInfo?.id {
                        openRelatedNeighborhoodList(neighborhoodId: id, disposeBag: self.disposeBag, navVC: self.navVC, bottomBarBinder: self.bindBottomView())
                    }
                }
                <- parseHeaderNode("相关推荐")
                <- parseErshouHouseListItemNode(relateErshouHouseData.value?.data?.items, disposeBag: disposeBag, navVC: self.navVC)
                <- parseErshouHouseDisclaimerNode(data)
            return dataParser.parser
        } else {
            return DetailDataParser.monoid().parser
        }
    }

    fileprivate func openFloorPanDetailPage(floorPanId: String?) -> () -> Void {
        return { [unowned self] in
            if let floorPanId = floorPanId, let id = Int64(floorPanId) {
                openNeighborhoodDetailPage(neighborhoodId: Int64(id), disposeBag: self.disposeBag, navVC: self.navVC)()
            }
        }
    }


}

func openErshouHouseList(
        title: String?,
        neighborhoodId: String,
        houseId: String? = nil,
        disposeBag: DisposeBag,
        navVC: UINavigationController?,
        searchSource: SearchSourceKey,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) {
    let listVC = ErshouHouseListVC(
        title: title,
        neighborhoodId: neighborhoodId,
        houseId: houseId,
        searchSource: searchSource,
        bottomBarBinder: bottomBarBinder)
    listVC.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    navVC?.pushViewController(listVC, animated: true)
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
    return { (tableView, navVC) in
        ErshouHouseDetailPageViewModel(tableView: tableView, navVC: navVC)
    }
}

func parseErshouHouseListItemNode(_ data: [HouseItemInnerEntity]?, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag, navVC: navVC) }
        if let renders = data?.map(curry(fillErshouHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                label: "精选好房",
                type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func parseErshouHouseListItemNode(_ data: HouseRecommendSection?, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let selectors = data?.items?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag, navVC: navVC) }
        if let renders = data?.items?.map(curry(fillErshouHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                label: data?.title ?? "精选好房",
                type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func parseErshouHouseListRowItemNode(_ data: [HouseItemInnerEntity]?, disposeBag: DisposeBag, navVC: UINavigationController?) -> [TableRowNode] {
    let selectors = data?
        .filter { $0.id != nil }
        .map { Int64($0.id!) }
        .map { openErshouHouseDetailPage(houseId: $0!, disposeBag: disposeBag, navVC: navVC) }
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

        theCell.priceLabel.text = data.displayPrice
        theCell.roomSpaceLabel.text = data.displayPricePerSqm
        if let img = data.houseImage?.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func parseFollowUpListRowItemNode(_ data: UserFollowData, disposeBag: DisposeBag, navVC: UINavigationController?) -> [TableRowNode] {
    let adapters = data.items
        .filter { $0.followId != nil }
        .map { item -> (TableCellSelectedProcess, (BaseUITableViewCell) -> Void, (UITableViewCellEditingStyle) -> Observable<TableRowEditResult>) in
            let selector = openDetailPage(houseType: HouseType(rawValue: item.houseType!), followUpId: Int64(item.followId!) ?? 0, disposeBag: disposeBag, navVC: navVC)
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

fileprivate func openDetailPage(houseType: HouseType?, followUpId: Int64, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    guard let houseType = houseType else {
        return openErshouHouseDetailPage(houseId: followUpId, disposeBag: disposeBag, navVC: navVC)
    }
    switch houseType {
    case .newHouse:
        return openNewHouseDetailPage(houseId: followUpId, disposeBag: disposeBag, navVC: navVC)
    case .secondHandHouse:
        return openErshouHouseDetailPage(houseId: followUpId, disposeBag: disposeBag, navVC: navVC)
    case .neighborhood:
        return openNeighborhoodDetailPage(neighborhoodId: followUpId, disposeBag: disposeBag, navVC: navVC)
    default:
        return openErshouHouseDetailPage(houseId: followUpId, disposeBag: disposeBag, navVC: navVC)
    }
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
        theCell.priceLabel.text = data.pricePerSqm

        if let img = data.images.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func openErshouHouseDetailPage(houseId: Int64, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: houseId,
            houseType: .newHouse,
            isShowBottomBar: true,
            provider: getErshouHouseDetailPageViewModel())
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { [weak navVC] void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(detailPage, animated: true)
    }
}
