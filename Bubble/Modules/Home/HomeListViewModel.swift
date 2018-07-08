//
// Created by linlin on 2018/7/5.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeListViewModel: DetailPageViewModel {

    weak var tableView: UITableView?

    private var cellFactory: UITableViewCellFactory

    fileprivate var dataSource: DataSource

    let disposeBag = DisposeBag()

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        self.dataSource = DataSource(cellFactory: cellFactory)
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        cellFactory.register(tableView: tableView)
    }

    func requestData(houseId: Int64) {
        requestHouseRecommend()
                .map { response -> [TableSectionNode] in
                    if let data = response?.data {
                        let dataParser = DetailDataParser.monoid()
                            <- parseErshouHouseListItemNode(data.house?.items)
                            <- parseOpenAllNode(true) { [unowned self] in
                                self.openCategoryList(houseType: .secondHandHouse, condition: ConditionAggregator.monoid().aggregator)
                            }
                            <- parseNewHouseListItemNode(data.court?.items)
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

    private func openCategoryList(houseType: HouseType, condition: @escaping (String) -> String) {
        let vc = CategoryListPageVC()
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

func parseNewHouseListItemNode(_ data: [CourtItemInnerEntity]?) -> () -> TableSectionNode? {
    return {
        let selectors = data?
                .filter { $0.id != nil }
                .map { Int64($0.id!) }
                .map { openNewHouseDetailPage(houseId: $0!) }
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

func fillNewHouseListitemCell(_ data: CourtItemInnerEntity, cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.displayTitle
        theCell.extendTitle.text = data.displayDescription
        let text = NSMutableAttributedString()

        let attrTexts = data.tags?.map({ (item) -> NSAttributedString in
            createTagAttrString(item.content ?? "")
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

func openNewHouseDetailPage(houseId: Int64) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
                houseId: houseId,
                houseType: .newHouse,
                provider: getNewHouseDetailPageViewModel())
        EnvContext.shared.rootNavController.pushViewController(detailPage, animated: true)
    }
}

func openNeighborhoodDetailPage(neighborhoodId: Int64) -> () -> Void {
    return {
        let detailPage = HorseDetailPageVC(
            houseId: neighborhoodId,
            houseType: .newHouse,
            provider: getNeighborhoodDetailPageViewModel())
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
