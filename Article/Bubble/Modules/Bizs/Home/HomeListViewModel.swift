//
// Created by linlin on 2018/7/5.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeListViewModel: DetailPageViewModel {

    var followStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay<Result<Bool>>(value: Result.success(false))

    var titleValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    weak var tableView: UITableView?

    private var cellFactory: UITableViewCellFactory

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    var houseId: Int64 = -1

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
    }

    func requestData(houseId: Int64) {
        self.houseId = houseId
        requestHouseRecommend()
            .map { [unowned self] response -> [TableSectionNode] in
                let config = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value
                let entrys = config?.entryList.filter { $0.entryId != 5 }
                if let data = response?.data {
                    let dataParser = DetailDataParser.monoid()
                        <- parseSpringboardNode(entrys ?? [], disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpNode(config?.opData, disposeBag: self.disposeBag)
                        <- parseErshouHouseListItemNode(data.house?.items, disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpenAllNode(data.house?.items?.count ?? 0 > 0) { [unowned self] in
                            self.openCategoryList(houseType: .secondHandHouse, condition: ConditionAggregator.monoid().aggregator)
                        }
                        <- parseNewHouseListItemNode(data.court, disposeBag: self.disposeBag, navVC: self.navVC)
                        <- parseOpenAllNode(data.court?.items?.count ?? 0 > 0, isShowBottomBar: false) {
                            self.openCategoryList(houseType: .newHouse, condition: ConditionAggregator.monoid().aggregator)
                    }
                    return dataParser.parser([])
                } else {
                    return []
                }
            }
            .subscribe(onNext: { [unowned self] response in
                self.dataSource.datas = response
                self.tableView?.reloadData()
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

    private func openCategoryList(houseType: HouseType, condition: @escaping (String) -> String) {
        let vc = CategoryListPageVC(isOpenConditionFilter: true)
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

fileprivate func parseOpNode(_ data: OpData?, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    if data?.opStyle == 1 {
        return parseFlatOpNode(data?.items ?? [], disposeBag: disposeBag)
    } else {
        return parseGridOpNode(data?.items ?? [], disposeBag: disposeBag)
    }
}

func parseNewHouseListItemNode(_ data: CourtRecommendSection?, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let selectors = data?.items?
                .filter { $0.id != nil }
                .map { Int64($0.id!) }
                .map { openNewHouseDetailPage(
                    houseId: $0!, disposeBag:
                    disposeBag, navVC:
                    navVC)
                }
        
        if let renders = data?.items?.map(curry(fillNewHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                    items: renders,
                    selectors: selectors,
                    label: data?.title ?? "优选楼盘",
                    type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func paresNewHouseListRowItemNode(_ data: [CourtItemInnerEntity]?, disposeBag: DisposeBag, navVC: UINavigationController?) -> [TableRowNode] {
    let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openNewHouseDetailPage(houseId: $0!, disposeBag: disposeBag, navVC: navVC) }
    if let renders = data?.map(curry(fillNewHouseListitemCell)), let selectors = selectors {

        return zip(renders, selectors).map { (e) -> TableRowNode in
            let (render, selector) = e
            return TableRowNode(
                itemRender: render,
                selector: selector,
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
            houseType: .newHouse,
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
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
