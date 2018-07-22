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

    init(tableView: UITableView) {
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
                let entrys = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value?.entryList
                if let data = response?.data {
                    let dataParser = DetailDataParser.monoid()
                        <- parseSpringboardNode(entrys ?? [], disposeBag: self.disposeBag)
                        <- parseErshouHouseListItemNode(data.house?.items, disposeBag: self.disposeBag)
                        <- parseOpenAllNode(true) { [unowned self] in
                            self.openCategoryList(houseType: .secondHandHouse, condition: ConditionAggregator.monoid().aggregator)
                        }
                        <- parseNewHouseListItemNode(data.court?.items, disposeBag: self.disposeBag)
                        <- parseOpenAllNode(true) {
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
        let nav = EnvContext.shared.rootNavController
        nav.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

}

func parseNewHouseListItemNode(_ data: [CourtItemInnerEntity]?, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let selectors = data?
                .filter { $0.id != nil }
                .map { Int64($0.id!) }
            .map { openNewHouseDetailPage(houseId: $0!, disposeBag: disposeBag) }
        if let renders = data?.map(curry(fillNewHouseListitemCell)), let selectors = selectors {
            return TableSectionNode(
                    items: renders,
                    selectors: selectors,
                    label: "新房房源",
                    type: .node(identifier: SingleImageInfoCell.identifier))
        } else {
            return nil
        }
    }
}

func paresNewHouseListRowItemNode(_ data: [CourtItemInnerEntity]?, disposeBag: DisposeBag) -> [TableRowNode] {
    let selectors = data?
            .filter { $0.id != nil }
            .map { Int64($0.id!) }
            .map { openNewHouseDetailPage(houseId: $0!, disposeBag: disposeBag) }
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

        attrTexts?.forEach({ (attrText) in
            text.append(attrText)
        })

        theCell.areaLabel.attributedText = text

        theCell.priceLabel.text = data.displayPricePerSqm
        theCell.roomSpaceLabel.text = ""
        if let img = data.courtImage?.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}

func openNewHouseDetailPage(houseId: Int64, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
                houseId: houseId,
                houseType: .newHouse,
                isShowBottomBar: true,
                provider: getNewHouseDetailPageViewModel())
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}

func openNeighborhoodDetailPage(neighborhoodId: Int64, disposeBag: DisposeBag) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: neighborhoodId,
            houseType: .newHouse,
            provider: getNeighborhoodDetailPageViewModel())
        detailPage.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                EnvContext.shared.rootNavController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
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
            return 51
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas[indexPath.section].selectors?[indexPath.row]()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
