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
class SortConditionPanel: BaseConditionPanelView, UITableViewDelegate {
    private lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        return re
    }()

    private lazy var dataSource: DataSource = {
        let re = DataSource()
        return re
    }()

    var didSelect: ((Node?) -> Void)?

    init() {
        super.init(frame: CGRect.zero)
        addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView.register(PriceListItemCell.self, forCellReuseIdentifier: "item")
        tableView.dataSource = dataSource
        tableView.delegate = self


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSortConditions(nodes: [Node]) {
        self.dataSource.nodes = nodes
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dataSource.selectedIndexPaths.accept([indexPath])
        tableView.reloadData()
        self.didSelect?(self.dataSource.selectedNode())
    }

    override func setSelectedConditions(conditions: [String : Any]) {
        dataSource.selectedIndexPaths.accept([])
//        self.tableView.reloadData()
        let conditionStrArray = conditions
            .map { (e) -> [String] in
                convertKeyValueToCondition(key: e.key, value: e.value)
            }
            .reduce([]) { (result, nodes) -> [String] in
                result + nodes
        }
        //优先从列表页中寻找选中的价格选项，设置选中状态。
        self.dataSource.nodes
            .enumerated()
            .forEach { [unowned self] (offset, item) in
                let key = getEncodingString("\(item.key)")
                if let filterCondition = item.filterCondition as? String {
                    let comparedCondition = "\(key)=\(getEncodingString(filterCondition))"
                    if conditionStrArray.contains(comparedCondition) {
                        var selectedIndexPaths = self.dataSource.selectedIndexPaths.value
                        selectedIndexPaths.insert(IndexPath(row: offset, section: 0))
                        self.dataSource.selectedIndexPaths.accept(selectedIndexPaths)
                    }
                }
        }
        self.tableView.reloadData()
    }

    fileprivate func getEncodingString(_ string: String) -> String {
        let encodingString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodingString == nil ? string : encodingString!
    }
}

fileprivate class DataSource: NSObject, UITableViewDataSource {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []

    let selectedIndexPaths = BehaviorRelay<Set<IndexPath>>(value: [])

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
            if selectedIndexPaths.value.count == 0, indexPath.row == 0 {
                setCellSelected(true, cell: theCell)
            }
            theCell.checkboxBtn.isHidden = true
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

    func selectedNode() -> Node? {
        if let index = selectedIndexPaths.value.first?.row ,
            nodes.count > index {
            return nodes[index]
        } else {
            return nodes.first
        }
    }

}
