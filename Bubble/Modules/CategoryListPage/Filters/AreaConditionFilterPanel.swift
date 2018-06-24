//
// Created by linlin on 2018/6/20.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

fileprivate enum ConditionType: Int {
    case category = 0
    case subCategory = 1
    case extendValue = 2
}

func constructAreaConditionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let panel = AreaConditionFilterPanel(nodes: nodes)
            container.addSubview(panel)
            panel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            panel.didSelect = { nodes in action(index, nodes) }
        }
    }
}

func parseAreaCondition(nodePath: [Node]) -> (String) -> String {
    return { (condition) in
        let theCondition = nodePath
            .filter { $0.label != "不限" }.reduce("", { (result, node) -> String in
                "\(result)&\(node.externalConfig)"
            })
        return "\(condition)&\(theCondition)"
    }
}

func parseAreaConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    let filteredNodes = nodePath.filter { $0.label != "不限" }
    if filteredNodes.count <= 1 {
        return .noCondition("区域")
    } else {
        if let node = filteredNodes.last {
            return .condition(node.label)
        } else {
            return .noCondition("区域")
        }
    }
}


class AreaConditionFilterPanel: UIView {

    fileprivate lazy var tableViews: [UITableView] = {
        (0..<3).map { _ in
            let result = UITableView()
            result.separatorStyle = .none
            result.register(AreaConditionCell.self, forCellReuseIdentifier: "item")
            return result
        }
    }()

    fileprivate lazy var dataSources: [ConditionTableViewDataSource] = {
        (0..<3).map { _ in
            ConditionTableViewDataSource()
        }
    }()

    fileprivate lazy var delegates: [ConditionTableViewDelegate] = {
        (0..<3).map { _ in
            ConditionTableViewDelegate()
        }
    }()

    private var nodes: [Node]

    var didSelect: (([Node]) -> Void)?

    init() {
        nodes = []
        super.init(frame: CGRect.zero)
        initPanelWithNativeDS()
    }

    init(nodes: [Node]) {
        self.nodes = nodes
        super.init(frame: CGRect.zero)
        initPanelWithNativeDS()
    }

    func initPanelWithNativeDS() {
        tableViews.forEach { view in
            addSubview(view)
        }

        zip(tableViews, dataSources).forEach { (e) in
            e.0.dataSource = e.1
        }

        zip(tableViews, delegates).forEach { (e) in
            e.0.delegate = e.1
        }

        tableViews.first?.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        onInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onInit() {
        tableViews[ConditionType.category.rawValue].snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.extendValue.rawValue].snp.makeConstraints { maker in
            maker.top.bottom.right.equalToSuperview()
            maker.left.equalTo(tableViews[ConditionType.subCategory.rawValue].snp.right)
        }

        displayNormalCondition()
        dataSources[ConditionType.category.rawValue].nodes = nodes
        if let first = nodes.first {
            dataSources[ConditionType.subCategory.rawValue].nodes = first.children
        }
        if let first = delegates.first {
            first.selectedIndexPath = IndexPath(row: 0, section: 0)
        }
        delegates[ConditionType.category.rawValue].onSelect = createCategorySelectorHandler(nodes: nodes)

        if let children = nodes.first?.children {
            delegates[ConditionType.subCategory.rawValue].onSelect = createSubCategorySelector(nodes: children)
        }

        reloadAllTables()
        tableViews[ConditionType.category.rawValue].selectRow(
                at: IndexPath(row: 0, section: 0),
                animated: false,
                scrollPosition: .none)
        tableViews[ConditionType.subCategory.rawValue].selectRow(
                at: IndexPath(row: 0, section: 0),
                animated: false,
                scrollPosition: .none)
    }

    func displayNormalCondition() {
        tableViews[ConditionType.category.rawValue].snp.remakeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.remakeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(halfWidthOfScreen())
        }
    }

    func displayExtendValue() {
        tableViews[ConditionType.category.rawValue].snp.remakeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(minWidth())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.remakeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(minWidth())
        }
    }

    fileprivate func createCategorySelectorHandler(
        nodes: [Node]) -> (IndexPath) -> Void {
        return { [weak self] (indexPath) in
            if nodes[indexPath.row].children.isEmpty {
                self?.delegates[ConditionType.subCategory.rawValue].selectedIndexPath = nil
                self?.delegates[ConditionType.extendValue.rawValue].selectedIndexPath = nil
                self?.didSelect?(self?.selectNodePath() ?? [])
            } else {
                self?.dataSources[ConditionType.subCategory.rawValue].nodes = nodes[indexPath.row].children
                self?.delegates[ConditionType.subCategory.rawValue].onSelect = self?.createSubCategorySelector(nodes: nodes[indexPath.row].children)
                self?.delegates[ConditionType.subCategory.rawValue].selectedIndexPath = nil
                self?.delegates[ConditionType.extendValue.rawValue].selectedIndexPath = nil

                self?.displayNormalCondition()
                self?.tableViews[ConditionType.subCategory.rawValue].reloadData()
                self?.tableViews[ConditionType.category.rawValue].selectRow(
                    at: indexPath,
                    animated: false,
                    scrollPosition: .none)
                self?.tableViews[ConditionType.subCategory.rawValue].selectRow(
                    at: IndexPath(row: 0, section: 0),
                    animated: false,
                    scrollPosition: .none)
            }
        }
    }

    fileprivate func createSubCategorySelector(nodes: [Node]) -> (IndexPath) -> Void {
        return { [weak self] (indexPath) in
            if nodes[indexPath.row].children.isEmpty {
                self?.delegates[ConditionType.extendValue.rawValue].selectedIndexPath = nil
                self?.didSelect?(self?.selectNodePath() ?? [])
            } else {
                self?.dataSources[ConditionType.extendValue.rawValue].nodes = nodes[indexPath.row].children
                if let displayExtendValue = self?.displayExtendValue {
                    self?.layoutWithAniminate(apply: displayExtendValue)
                }
                self?.delegates[ConditionType.extendValue.rawValue].onSelect = { [weak self] (indexPath) in
                    self?.tableViews[ConditionType.extendValue.rawValue].selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    self?.didSelect?(self?.selectNodePath() ?? [])
                }
                self?.delegates[ConditionType.extendValue.rawValue].selectedIndexPath = nil
                self?.tableViews[ConditionType.extendValue.rawValue].reloadData()
                self?.tableViews[ConditionType.subCategory.rawValue].selectRow(
                    at: indexPath,
                    animated: false,
                    scrollPosition: .none)
                self?.tableViews[ConditionType.extendValue.rawValue].selectRow(
                    at: IndexPath(row: 0, section: 0),
                    animated: false,
                    scrollPosition: .none)
            }
        }
    }

    func selectNodePath() -> [Node] {
        let paths = delegates
            .filter { $0.selectedIndexPath != nil }
            .map { $0.selectedIndexPath! }
        var currentNode: Node?
        var result: [Node] = []
        paths.forEach { path in
            if let theCurrentNode = currentNode {
                let nextNode = theCurrentNode.children[path.row]
                currentNode = nextNode
                result.append(nextNode)
            } else {
                let nextNode = nodes[path.row]
                currentNode = nextNode
                result.append(nextNode)
            }
        }
        return result
    }

    func layoutWithAniminate(apply: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: apply)
    }

    func reloadAllTables() {
        tableViews.forEach {
            $0.reloadData()
        }
    }

    func halfWidthOfScreen() -> CGFloat {
        return UIScreen.main.bounds.width / 2
    }

    func minWidth() -> CGFloat {
        return UIScreen.main.bounds.width / 3 - 8
    }
}


fileprivate class ConditionTableViewDelegate: NSObject, UITableViewDelegate {

    var selectedIndexPath: IndexPath?

    var onSelect: ((IndexPath) -> Void)?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        onSelect?(indexPath)
    }

}

fileprivate class ConditionTableViewDataSource: NSObject, UITableViewDataSource {

    var nodes: [Node] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? AreaConditionCell {
            theCell.label.text = nodes[indexPath.row].label
            return theCell
        } else {
            return UITableViewCell()
        }
    }
}

fileprivate class AreaConditionCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.highlightedTextColor = hexStringToUIColor(hex: "#f85959")
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        contentView.addSubview(label)
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgView
        label.snp.makeConstraints { maker in
            maker.left.right.equalTo(25)
            maker.top.equalTo(12)
            maker.height.equalTo(21)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Node {
    let id: String
    let label: String
    let externalConfig: String
    let children: [Node]
}

extension Node {
    init(id: String, label: String, externalConfig: String) {
        self.id = id
        self.label = label
        self.externalConfig = externalConfig
        self.children = []
    }
}

private func mockupData() -> [Node] {
    let nodes = [Node(id: "1", label: "不限", externalConfig: ""),
                 Node(id: "2", label: "安定门", externalConfig: "")]

    let area = Node(id: "3", label: "朝阳", externalConfig: "", children: nodes)
    let unliminte = Node(id: "8", label: "不限", externalConfig: "")

    let root = Node(id: "4", label: "区域", externalConfig: "", children: [unliminte, area])
    let zhichunlu = Node(id: "10", label: "知春路", externalConfig: "")
    let subWay = Node(id: "9", label: "地铁", externalConfig: "", children: [zhichunlu])
    return [root, subWay]
}
