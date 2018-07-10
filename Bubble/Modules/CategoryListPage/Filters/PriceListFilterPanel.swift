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
    var thePanel: PriceListFilterPanel? = nil
    return { (index, container) in

        if let container = container, let node = nodes.first {
            if thePanel == nil {
                thePanel = PriceListFilterPanel(nodes: node.children)
            }
            container.addSubview(thePanel!)
            thePanel?.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            thePanel?.didSelect = { nodes in action(index, nodes) }
        }
    }
}

func parsePriceConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    if let node = nodePath.last, node.label != "不限" {
        return .condition(node.label)
    }
    return .noCondition("总价")
}

func parsePriceSearchCondition(nodePath: [Node]) -> (String) -> String {
    return {
        if let first = nodePath.first {
            return "\($0)&\(first.externalConfig)"
        } else {
            return $0
        }
    }
}

class PriceListFilterPanel: UIView {

    var dataSource: PriceListTableViewDataSource

    var didSelect: (([Node]) -> Void)?

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        return result
    }()

    fileprivate lazy var bottomInputView: PriceBottomInputView = {
        let re = PriceBottomInputView()
        return re
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
        addSubview(bottomInputView)
        bottomInputView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
        }
        bottomInputView.lu.addTopBorder()

        tableView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomInputView.snp.top).offset(0.5)
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

    var selectedIndexPaths: [IndexPath] = []

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

    lazy var checkboxBtn: UIButton = {
        let re = UIButton()
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name"), for: .normal)
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name-checked"), for: .selected)
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(checkboxBtn)
        checkboxBtn.snp.makeConstraints { maker in
            maker.right.equalTo(-24)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(14)
        }

        contentView.addSubview(label)

        label.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.right.equalTo(checkboxBtn.snp.left).offset(-24)
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

fileprivate class PriceBottomInputView: UIView {

    lazy var lowerPriceTextField: UITextField = {
        let re = UITextField()
        re.placeholder = "最低价格 (万)"
        re.textAlignment = .center
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.layer.cornerRadius = 4
        return re
    }()

    lazy var upperPriceTextField: UITextField = {
        let re = UITextField()
        re.placeholder = "最高价格 (万)"
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textAlignment = .center
        re.layer.cornerRadius = 4
        return re
    }()

    lazy var configBtn: UIButton = {
        let re = UIButton()
        re.setTitle("确定", for: .normal)
        re.setTitleColor(UIColor.white, for: .normal)
        re.backgroundColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var seperaterLineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#d8d8d8")
        return re
    }()

    lazy var topBorderLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.white
        addSubview(lowerPriceTextField)
        lowerPriceTextField.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.top.equalTo(8)
            maker.bottom.equalTo(-8)
            maker.height.equalTo(28)
            maker.width.equalTo(105)
        }

        addSubview(seperaterLineView)
        seperaterLineView.snp.makeConstraints { maker in
            maker.left.equalTo(lowerPriceTextField.snp.right).offset(5)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(1)
            maker.width.equalTo(10)
        }

        addSubview(upperPriceTextField)
        upperPriceTextField.snp.makeConstraints { maker in
            maker.left.equalTo(seperaterLineView.snp.right).offset(5)
            maker.top.equalTo(8)
            maker.bottom.equalTo(-8)
            maker.height.equalTo(28)
            maker.width.equalTo(105)
        }

        addSubview(configBtn)
        configBtn.snp.makeConstraints { maker in
            maker.right.top.bottom.equalToSuperview()
            maker.left.equalTo(upperPriceTextField.snp.right).offset(21)
        }

        addSubview(topBorderLine)
        topBorderLine.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(0.5)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
