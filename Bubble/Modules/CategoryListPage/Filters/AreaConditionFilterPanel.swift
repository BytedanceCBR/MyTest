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

func constructAreaConditionPanel(
        nodes: [Node],
        _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let panel = AreaConditionFilterPanel(nodes: nodes)
            container.addSubview(panel)
            panel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            panel.didSelect = { nodes in
                action(index, nodes)
            }
        }
    }
}

func parseAreaCondition(nodePath: [Node]) -> (String) -> String {
    return { (condition) in
        let theCondition = nodePath
                .filter {
                    $0.label != "不限"
                }.reduce("", { (result, node) -> String in
                    "\(result)&\(node.externalConfig)"
                })
        return "\(condition)&\(theCondition)"
    }
}

func parseAreaConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    let filteredNodes = nodePath.filter {
        $0.label != "不限"
    }
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

func parseAreaSearchCondition(nodePath: [Node]) -> (String) -> String {
    return { query in
        let filteredNodes = nodePath.filter {
            $0.label != "不限"
        }
        if filteredNodes.count <= 1 {
            return query
        } else {
            return "\(query)&\(filteredNodes.last!.externalConfig)"
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

    lazy var clearBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.white
        result.lu.addTopBorder(color: hexStringToUIColor(hex: "#f4f5f6"))

        result.setTitle("重置", for: .normal)
        result.setTitleColor(hexStringToUIColor(hex: "#222222"), for: .normal)
        return result
    }()

    lazy var confirmBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = hexStringToUIColor(hex: "#f85959")
        result.setTitle("确定", for: .normal)
        return result
    }()

    private var nodes: [Node]

    var didSelect: (([Node]) -> Void)?

    let disposeBag = DisposeBag()

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

        dataSources.last?.isShowCheckBox = true
        dataSources.last?.isMultiSelected = true
        tableViews.forEach { view in
            addSubview(view)
        }

        zip(tableViews, dataSources).forEach { (e) in
            e.0.dataSource = e.1
            e.0.delegate = e.1
        }

        tableViews.first?.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        onInit()
        clearBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.dataSources.forEach { $0.selectedIndexPaths.removeAll() }
                    self.tableViews.forEach { $0.reloadData() }
                })
                .disposed(by: disposeBag)
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onInit() {

        addSubview(clearBtn)
        clearBtn.snp.makeConstraints { maker in
            maker.bottom.left.equalToSuperview()
            maker.right.equalTo(self.snp.centerX)
            maker.height.equalTo(44)
        }

        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.bottom.right.equalToSuperview()
            maker.left.equalTo(self.snp.centerX)
            maker.height.equalTo(44)
        }


        tableViews[ConditionType.category.rawValue].snp.makeConstraints { maker in
            maker.left.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.extendValue.rawValue].snp.makeConstraints { maker in
            maker.top.right.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.left.equalTo(tableViews[ConditionType.subCategory.rawValue].snp.right)
        }

        displayNormalCondition()
        dataSources[ConditionType.category.rawValue].nodes = nodes
        if let first = nodes.first {
            dataSources[ConditionType.subCategory.rawValue].nodes = first.children
        }
        if let first = dataSources.first {
            first.selectedIndexPath = IndexPath(row: 0, section: 0)
        }
        dataSources[ConditionType.category.rawValue].onSelect = createCategorySelectorHandler(nodes: nodes)

        if let children = nodes.first?.children {
            dataSources[ConditionType.subCategory.rawValue].onSelect = createSubCategorySelector(nodes: children)
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
            maker.left.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.remakeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(halfWidthOfScreen())
        }
    }

    func displayExtendValue() {
        tableViews[ConditionType.category.rawValue].snp.remakeConstraints { maker in
            maker.left.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.width.equalTo(minWidth())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.remakeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(minWidth())
        }
    }

    fileprivate func createCategorySelectorHandler(nodes: [Node]) -> (IndexPath) -> Void {
        return { [weak self] (indexPath) in
            if nodes[indexPath.row].children.isEmpty {
                self?.dataSources[ConditionType.subCategory.rawValue].selectedIndexPath = nil
                self?.dataSources[ConditionType.extendValue.rawValue].selectedIndexPath = nil
//                self?.didSelect?(self?.selectNodePath() ?? [])
            } else {
                self?.dataSources[ConditionType.subCategory.rawValue].nodes = nodes[indexPath.row].children
                self?.dataSources[ConditionType.subCategory.rawValue].onSelect = self?.createSubCategorySelector(nodes: nodes[indexPath.row].children)
                self?.dataSources[ConditionType.subCategory.rawValue].selectedIndexPath = nil
                self?.dataSources[ConditionType.extendValue.rawValue].selectedIndexPath = nil

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

            let extentValueDS = self?.dataSources[ConditionType.extendValue.rawValue]
            let extentValueTable = self?.tableViews[ConditionType.extendValue.rawValue]

            if nodes[indexPath.row].children.isEmpty {
                extentValueDS?.selectedIndexPath = nil
//                self?.didSelect?(self?.selectNodePath() ?? [])
            } else {
                self?.dataSources[ConditionType.extendValue.rawValue].nodes = nodes[indexPath.row].children
                if let displayExtendValue = self?.displayExtendValue {
                    self?.layoutWithAniminate(apply: displayExtendValue)
                }
                self?.dataSources[ConditionType.extendValue.rawValue].onSelect = { [weak self] (indexPath) in
                    self?.tableViews[ConditionType.extendValue.rawValue].selectRow(at: indexPath, animated: false, scrollPosition: .none)
//                    self?.didSelect?(self?.selectNodePath() ?? [])
                }
                self?.dataSources[ConditionType.extendValue.rawValue].selectedIndexPath = nil
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
        let paths = dataSources
                .filter {
                    $0.selectedIndexPath != nil
                }
                .map {
                    $0.selectedIndexPath!
                }
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

fileprivate class ConditionTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var nodes: [Node] = []

    var selectedIndexPath: IndexPath?

    var selectedIndexPaths: Set<IndexPath> = []

    var onSelect: ((IndexPath) -> Void)?

    var isShowCheckBox = false

    var isMultiSelected = false

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? AreaConditionCell {
            theCell.label.text = nodes[indexPath.row].label
            theCell.checkboxBtn.isHidden = !isShowCheckBox || nodes[indexPath.row].isEmpty == 1
            if selectedIndexPaths.contains(indexPath) {
                theCell.checkboxBtn.isSelected = true
                theCell.label.textColor = hexStringToUIColor(hex: "#f85959")
            }

            if selectedIndexPaths.count == 0 && indexPath.row == 0 {
                theCell.isHighlighted = true
            }

            return theCell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        onSelect?(indexPath)
        if isMultiSelected != true {
            selectedIndexPaths = selectedIndexPaths.filter { $0.section != indexPath.section }
        }

        if !selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        tableView.reloadData()
    }

}

fileprivate class AreaConditionCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
//        result.highlightedTextColor = hexStringToUIColor(hex: "#f85959")
        return result
    }()

    lazy var checkboxBtn: UIButton = {
        let re = UIButton()
        re.isHidden = true
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name"), for: .normal)
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name-checked"), for: .selected)
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear

        contentView.addSubview(checkboxBtn)
        checkboxBtn.snp.makeConstraints { maker in
            maker.right.equalTo(-23)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(14)
        }

        contentView.addSubview(label)
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgView
        label.snp.makeConstraints { maker in
            maker.left.right.equalTo(25)
            maker.top.equalTo(12)
            maker.height.equalTo(21)
            maker.right.equalTo(checkboxBtn.snp.left).offset(5)
        }

    }

    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        checkboxBtn.isHidden = true
        checkboxBtn.isSelected = false

        label.textColor = hexStringToUIColor(hex: "#222222")
        label.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Node {
    let id: String
    let label: String
    let externalConfig: String
    let isSupportMulti: Bool
    let isEmpty: Int
    let children: [Node]

    init(id: String,
         label: String,
         externalConfig: String,
         isSupportMulti: Bool,
         isEmpty: Int,
         children: [Node]) {
        self.id = id
        self.label = label
        self.externalConfig = externalConfig
        self.isSupportMulti = isSupportMulti
        self.isEmpty = isEmpty
        self.children = children
    }

    init(id: String, label: String, externalConfig: String) {
        self.id = id
        self.label = label
        self.isEmpty = 0
        self.externalConfig = externalConfig
        self.isSupportMulti = false
        self.children = []
    }
}
