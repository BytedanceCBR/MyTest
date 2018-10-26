//
//  File.swift
//  Article
//
//  Created by leo on 2018/10/26.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class SortConditionPanel: BaseConditionPanelView {
    private lazy var tableView: UITableView = {
        let re = UITableView()
        return re
    }()

    private lazy var dataSource: DataSource = {
        let re = DataSource()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.register(PriceListItemCell.self, forCellReuseIdentifier: "item")
        tableView.dataSource = dataSource
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSortConditions(nodes: [Node]) {
        self.dataSource.nodes = nodes
        self.tableView.reloadData()
    }
}

fileprivate class DataSource: NSObject, UITableViewDataSource {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []

    let selectedIndexPaths = BehaviorRelay<Set<IndexPath>>(value: [])

    var didSelect: (([Node]) -> Void)?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? PriceListItemCell {
            theCell.label.text = nodes[indexPath.row].label
            if selectedIndexPaths.value.contains(indexPath) {
                setCellSelected(true, cell: theCell)
            } else {
                setCellSelected(false, cell: theCell)
            }
            theCell.checkboxBtn.isHidden = nodes[indexPath.row].isNoLimit == 1
        }
        return cell ?? UITableViewCell()
    }

    fileprivate func setCellSelected(_ isSelected: Bool, cell: PriceListItemCell) {
        cell.checkboxBtn.isSelected = isSelected
        if isSelected {
            cell.label.textColor = hexStringToUIColor(hex: "#299cff")
        } else {
            cell.label.textColor = hexStringToUIColor(hex: "#45494d")
        }
    }

}
