//
// Created by linlin on 2018/6/28.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
class BaseUITableViewCell: UITableViewCell {

    var isHead = false
    var isTail = false

    open class var identifier: String {
        return "base"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        isHead = false
        isTail = false
    }

}

extension BaseUITableViewCell {
    func addBottomLine() {
        contentView.lu.addBottomBorder(
                color: hexStringToUIColor(hex: "#e8e8e8"),
                leading: 15,
                trailing: -15)
    }
}

class UITableViewCellFactory {

    var cellClasses: [BaseUITableViewCell.Type] = []

    init() {

    }

    init(cellClasses: [BaseUITableViewCell.Type]) {
        self.cellClasses = cellClasses
    }

    func addCellClass(cellType: BaseUITableViewCell.Type) -> UITableViewCellFactory {
        cellClasses.append(cellType)
        return self
    }

    func register(tableView: UITableView) {
        cellClasses.forEach { cellType in
            tableView.register(cellType, forCellReuseIdentifier: cellType.identifier)
        }
    }

//    func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> BaseUITableViewCell {
//        return BaseUITableViewCell()
//    }

    func dequeueReusableCell<T: BaseUITableViewCell>(identifer: String, tableView: UITableView, indexPath: IndexPath) -> T {
        let cell: T = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath) as! T
        return cell
    }

}

func getHouseDetailCellFactory() -> UITableViewCellFactory {
    return UITableViewCellFactory()
            .addCellClass(cellType: CycleImageCell.self)
            .addCellClass(cellType: NewHouseNameCell.self)
            .addCellClass(cellType: NewHouseInfoCell.self)
            .addCellClass(cellType: ContactCell.self)
            .addCellClass(cellType: TimelineCell.self)
            .addCellClass(cellType: OpenAllCell.self)
            .addCellClass(cellType: MultiItemCell.self)
            .addCellClass(cellType: NewHouseCommentCell.self)
            .addCellClass(cellType: NewHouseNearByCell.self)
            .addCellClass(cellType: GlobalPricingCell.self)
            .addCellClass(cellType: DisclaimerCell.self)
            .addCellClass(cellType: HeaderCell.self)
            .addCellClass(cellType: ErshouHouseCoreInfoCell.self)
            .addCellClass(cellType: PropertyListCell.self)
            .addCellClass(cellType: NeighborhoodInfoCell.self)
            .addCellClass(cellType: SingleImageInfoCell.self)
            .addCellClass(cellType: NeighborhoodNameCell.self)
            .addCellClass(cellType: NeighborhoodPriceCell.self)
            .addCellClass(cellType: NeighborhoodItemCell.self)
            .addCellClass(cellType: TransactionRecordCell.self)
            .addCellClass(cellType: GlobalPricingListCell.self)
            .addCellClass(cellType: FloorPanInfoPropertyCell.self)
            .addCellClass(cellType: PermitListCell.self)
            .addCellClass(cellType: FloorPanHouseTypeCell.self)
            .addCellClass(cellType: FloorPlanHouseTypeNameCell.self)
            .addCellClass(cellType: FloorPlanRecommendHeaderCell.self)
            .addCellClass(cellType: FavoriteCell.self)
            .addCellClass(cellType: SpringBroadCell.self)
            .addCellClass(cellType: GridOpBoardCell.self)
            .addCellClass(cellType: FlatGridCell.self)
            .addCellClass(cellType: ErshouHousePriceChartCell.self)
            .addCellClass(cellType: InformationCell.self)


}

func getHomePageCellFactory() -> UITableViewCellFactory {
    return UITableViewCellFactory()
            .addCellClass(cellType: SingleImageInfoCell.self)
            .addCellClass(cellType: NeighborhoodItemCell.self)
}
