//
//  PriceListFilterPanel.swift
//  Bubble
//
//  Created by linlin on 2018/6/21.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

func constructPriceListConditionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let panel = PriceListFilterPanel(nodes: nodes)
            container.addSubview(panel)
            panel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            panel.didSelect = { nodes in action(index, nodes) }
        }
    }
}

func parsePriceConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    if let node = nodePath.last, node.label != "不限" {
        return .condition(node.label)
    }
    return .noCondition("总价")
}

class PriceListFilterPanel: UIView {

    var dataSource: PriceListTableViewDataSource

    var didSelect: (([Node]) -> Void)?

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        return result
    }()

    override init(frame: CGRect) {
        let dataSource = PriceListTableViewDataSource()
        self.dataSource = dataSource
        super.init(frame: frame)
        setupUI()
    }

    init(nodes: [Node]) {
        let dataSource = PriceListTableViewDataSource()
        dataSource.nodes = nodes
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        setupUI()
    }

    func setupUI() {
        dataSource.didSelect = { [weak self] nodes in
            self?.didSelect?(nodes)
        }
        addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }
        tableView.register(PriceListItemCell.self, forCellReuseIdentifier: "item")
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class PriceListTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var nodes: [Node] = []

    var selectedIndexPath: IndexPath?

    var didSelect: (([Node]) -> Void)?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? PriceListItemCell {
            theCell.label.text = nodes[indexPath.row].label
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect?([nodes[indexPath.row]])
    }

}

class PriceListItemCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.highlightedTextColor = hexStringToUIColor(hex: "#f85959")
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)

        label.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.right.equalToSuperview().offset(-24)
            maker.height.equalTo(21)
            maker.top.equalToSuperview().offset(12)
            maker.bottom.equalToSuperview().offset(-12)
         }
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
