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
    var thePanel: AreaConditionFilterPanel? = nil
    return { (index, container) in
        if let container = container {
            if thePanel == nil {
                thePanel = AreaConditionFilterPanel(nodes: nodes)
            }

            container.addSubview(thePanel!)
            thePanel?.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            thePanel?.didSelect = { nodes in
                action(index, nodes)
            }
        }
    }
}

func parseAreaConditionItemLabel(label: String, nodePath: [Node]) -> ConditionItemType {
    if nodePath.count == 0 {
        return .noCondition(label)
    } else if nodePath.count == 1 {
        if let node = nodePath.first, node.isNoLimit != 1 /*判定是否是不限*/ {
            return .condition(node.label)
        } else {
            return .noCondition(label)
        }
    } else {
        return .condition("\(nodePath.first!.parentLabel ?? label)(\(nodePath.count))")
    }
}

func parseAreaSearchCondition(nodePath: [Node]) -> (String) -> String {
    return { query in
        let queryCondition = nodePath.reduce("", { (result, node) -> String in
            return "\(result)&\(node.externalConfig)"
        })
        return "\(query)\(queryCondition)"
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
        (0..<3).map { index in
            ConditionTableViewDataSource(index: index)
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

    lazy var lineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#d8d8d8")
        return re
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
                    let subCategoryTable = self.tableViews[ConditionType.subCategory.rawValue]
                    let extentValueTable = self.tableViews[ConditionType.extendValue.rawValue]
                    let categoryTable = self.tableViews[ConditionType.category.rawValue]
                    self.dataSources.forEach {
                        $0.selectedIndexPaths.removeAll()
                    }
                    self.tableViews.forEach {
                        $0.reloadData()
                    }
                    categoryTable.selectRow(
                            at: IndexPath(row: 0, section: 0),
                            animated: false,
                            scrollPosition: .none)
                    subCategoryTable.selectRow(
                            at: IndexPath(row: 0, section: 0),
                            animated: false,
                            scrollPosition: .none)
                    extentValueTable.selectRow(
                            at: IndexPath(row: 0, section: 0),
                            animated: false,
                            scrollPosition: .none)
                    self.displayNormalCondition()
                })
                .disposed(by: disposeBag)

        confirmBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    let selected = self.selectNodePath()
                    self.didSelect?(selected)
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

        let secondTableView = tableViews[1]
        addSubview(lineView)
        lineView.snp.makeConstraints { [unowned secondTableView] maker in
            maker.left.equalTo(secondTableView.snp.right).offset(0.5)
            maker.width.equalTo(0.5)
            maker.bottom.top.equalTo(secondTableView)
        }

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
            maker.width.equalTo(UIScreen.main.bounds.width / 10 * 2)
        }
        tableViews[ConditionType.subCategory.rawValue].snp.remakeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalTo(clearBtn.snp.top)
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(UIScreen.main.bounds.width / 10 * 3)
        }
    }

    fileprivate func createCategorySelectorHandler(nodes: [Node]) -> (IndexPath) -> Void {
        return { [weak self] (indexPath) in

            let extentValueDS = self?.dataSources[ConditionType.extendValue.rawValue]
            let subCategoryDS = self?.dataSources[ConditionType.subCategory.rawValue]
            let subCategoryTable = self?.tableViews[ConditionType.subCategory.rawValue]
            let categoryTable = self?.tableViews[ConditionType.category.rawValue]

            if nodes[indexPath.row].isNoLimit == 1 || nodes[indexPath.row].children.isEmpty {
                subCategoryDS?.selectedIndexPaths.removeAll()
                extentValueDS?.selectedIndexPaths.removeAll()
            } else {
                subCategoryDS?.nodes = nodes[indexPath.row].children
                subCategoryDS?.onSelect = self?.createSubCategorySelector(nodes: nodes[indexPath.row].children)
                subCategoryDS?.selectedIndexPaths.removeAll()

                extentValueDS?.selectedIndexPaths.removeAll()

                self?.displayNormalCondition()
                subCategoryTable?.reloadData()
                categoryTable?.selectRow(
                        at: indexPath,
                        animated: false,
                        scrollPosition: .none)
                subCategoryTable?.selectRow(
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
            let subCategoryTable = self?.tableViews[ConditionType.subCategory.rawValue]

            if nodes[indexPath.row].children.isEmpty {
                extentValueDS?.selectedIndexPaths.removeAll()
                extentValueTable?.reloadData()
                self?.displayNormalCondition()
            } else {
                extentValueDS?.nodes = nodes[indexPath.row].children
                if let displayExtendValue = self?.displayExtendValue {
                    self?.layoutWithAniminate(apply: displayExtendValue)
                }
                extentValueDS?.onSelect = { (indexPath) in
                    extentValueTable?.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                extentValueDS?.selectedIndexPaths.removeAll()
                extentValueTable?.reloadData()
                subCategoryTable?.selectRow(
                        at: indexPath,
                        animated: false,
                        scrollPosition: .none)
                extentValueTable?.selectRow(
                        at: IndexPath(row: 0, section: 0),
                        animated: false,
                        scrollPosition: .none)
            }
        }
    }

    func selectNodePath() -> [Node] {
        let paths = dataSources
                .reversed()
                .first {
                    $0.selectedIndexPaths.count > 0 && $0.selectedNodes().first?.isEmpty == 0
                }
                .map {
                    $0.selectedNodes()
                }
        return paths ?? []
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

    var selectedIndexPaths: Set<IndexPath> = []

    var onSelect: ((IndexPath) -> Void)?

    var isShowCheckBox = false

    var isMultiSelected = false

    let index: Int

    init(index: Int) {
        self.index = index
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? AreaConditionCell {
            theCell.label.text = nodes[indexPath.row].label
            theCell.checkboxBtn.isHidden = !isShowCheckBox || nodes[indexPath.row].isEmpty == 1
            if selectedIndexPaths.contains(indexPath) {
                setCellSelected(true, cell: theCell)
            }

            if selectedIndexPaths.count == 0 && indexPath.row == 0 {
                setCellSelected(true, cell: theCell)
            }

            return theCell
        } else {
            return UITableViewCell()
        }
    }

    func setCellSelected(_ isSelected: Bool, cell: AreaConditionCell) {
        cell.checkboxBtn.isSelected = isSelected
        if isSelected {
            cell.label.textColor = hexStringToUIColor(hex: "#f85959")
        } else {
            cell.label.textColor = hexStringToUIColor(hex: "#222222")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(indexPath)
        if isMultiSelected != true {
            selectedIndexPaths = selectedIndexPaths.filter {
                $0.section != indexPath.section
            }
        }

        let node = nodes[indexPath.row]
        if node.isEmpty != 0 {
            selectedIndexPaths = []
        } else {
            selectedIndexPaths = selectedIndexPaths.filter {
                nodes[$0.row].isEmpty == 0
            }
        }


        if !selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        tableView.reloadData()
    }

    func selectedNodes() -> [Node] {
        return selectedIndexPaths.map { path -> Node in
            nodes[path.row]
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

fileprivate class AreaConditionCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
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
            maker.right.equalTo(checkboxBtn.snp.left).offset(10)
            //TODO: fixbug 文字右侧约束不起作用
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
    let isNoLimit: Int
    let parentLabel: String?
    let children: [Node]

    init(id: String,
         label: String,
         externalConfig: String,
         isSupportMulti: Bool,
         isEmpty: Int,
         isNoLimit: Int,
         parentLabel: String? = nil,
         children: [Node]) {
        self.id = id
        self.label = label
        self.externalConfig = externalConfig
        self.isSupportMulti = isSupportMulti
        self.isEmpty = isEmpty
        self.isNoLimit = isNoLimit
        self.parentLabel = parentLabel
        self.children = children
    }

    init(id: String, label: String, externalConfig: String) {
        self.id = id
        self.label = label
        self.isEmpty = 0
        self.isNoLimit = 0
        self.externalConfig = externalConfig
        self.isSupportMulti = false
        self.parentLabel = nil
        self.children = []
    }
}
