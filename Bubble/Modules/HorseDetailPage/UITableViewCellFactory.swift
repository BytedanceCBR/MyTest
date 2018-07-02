//
// Created by linlin on 2018/6/28.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

class BaseUITableViewCell: UITableViewCell {
    open class var identifier: String {
        return "base"
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

    func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> BaseUITableViewCell {
        return BaseUITableViewCell()
    }

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
}
