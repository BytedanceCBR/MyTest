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

func constructAreaConditionPanelWithContainer(
    nodes: [Node],
    container: UIView,
    action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
    let thePanel = AreaConditionFilterPanel(nodes: nodes)
    thePanel.isHidden = true
    container.addSubview(thePanel)
    thePanel.snp.makeConstraints { maker in
        maker.left.right.top.equalToSuperview()
        maker.height.equalTo(352)
    }
    thePanel.didSelect = { nodes in
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        for node in nodes {
            if node.parentLabel == "附近" && status != .authorizedWhenInUse && status != .authorizedAlways {
                showLocationGuideAlert()
                return
            }
        }
        action(0, nodes)
    }
    return thePanel
}

func constructAreaConditionPanel(
        nodes: [Node],
        _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let thePanel = AreaConditionFilterPanel(nodes: nodes)

            container.addSubview(thePanel)
            thePanel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            thePanel.didSelect = { nodes in
                action(index, nodes)
            }
            return thePanel
        }
        return nil
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

class AreaConditionFilterPanel: BaseConditionPanelView {

    fileprivate lazy var tableViews: [UITableView] = {
        (0..<3).map { _ in
            let result = UITableView()
            result.separatorStyle = .none
            result.rowHeight = UITableViewAutomaticDimension
            result.register(AreaConditionCell.self, forCellReuseIdentifier: "item")
            result.contentInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 10,
                                               right: 0)
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
        result.layer.cornerRadius = 20
        let buttomAttr = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "081f33")]
        let attrText = NSAttributedString(string: "重置", attributes: buttomAttr)
        result.setAttributedTitle(attrText, for: .normal)
        result.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        result.setTitleColor(hexStringToUIColor(hex: "#081f33"), for: .normal)
        return result
    }()

    lazy var confirmBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = hexStringToUIColor(hex: "#299cff")
        result.layer.cornerRadius = 20
        let buttomAttr = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                          NSAttributedStringKey.foregroundColor: UIColor.white]
        let attrText = NSAttributedString(string: "确定", attributes: buttomAttr)
        result.setAttributedTitle(attrText, for: .normal)
        return result
    }()

    lazy var lineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()

    private var nodes: [Node]

    private let redDots: [String]

    var didSelect: (([Node]) -> Void)?

    let disposeBag = DisposeBag()

    init() {
        nodes = []
        self.redDots = []
        super.init(frame: CGRect.zero)
        initPanelWithNativeDS()
    }

    init(nodes: [Node], redDots: [String] = []) {
        self.nodes = nodes
        self.redDots = redDots
        super.init(frame: CGRect.zero)
        dataSources.first?.nodes = self.nodes
        initPanelWithNativeDS()
    }

    override func setSelectedConditions(conditions: [String : Any]) {

        self.dataSources.forEach { (datasource) in
            datasource.selectedIndexPaths = []
        }
        self.tableViews.forEach { (tableView) in
            tableView.reloadData()
        }

        choiceFirstAndSecondSelection(conditions)

        self.dataSources.forEach { $0.storeSelectedState() }
        let selected = self.selectNodePath()
        self.conditionLabelSetter?(selected)
//        self.didSelect?(selected)
        if selected.count > 0 {
            scrollVisibleCellInScreen()
        }
    }

    func scrollVisibleCellInScreen() {
        let secondTable = self.tableViews[1]
        let secondDs = self.dataSources[1]
        scrollToFirstVisibleItem(tableView: secondTable, datasource: secondDs)
        let thirdTable = self.tableViews[2]
        let thirdDs = self.dataSources[2]
        scrollToFirstVisibleItem(tableView: thirdTable, datasource: thirdDs)
//        DispatchQueue.main.async { [weak self] in
//            self?.scrollToFirstVisibleItem(tableView: thirdTable, datasource: thirdDs)
//        }
    }

    fileprivate func choiceFirstAndSecondSelection(_ conditions: [String : Any]) {

        let conditionStrArray = conditions
            .map { (e) -> [String] in
                convertKeyValueToCondition(key: e.key, value: e.value)
            }.reduce([]) { (result, nodes) -> [String] in
                result + nodes
            }
        nodes
            .enumerated()
            .forEach { (firstOffset, item) in
                item.children
                    .enumerated()
                    .forEach({ [unowned self] (offset, secondCategory) in
                        let key = getEncodingString("\(secondCategory.key)")
                        if let _ = conditions[key],
                            let filterCondition = secondCategory.filterCondition {
                            let comparedCondition = "\(key)=\(stringValueOfAny(filterCondition))"
                            if conditionStrArray.contains(comparedCondition) {
                                dataSources[0].selectedIndexPaths = [IndexPath(row: firstOffset, section: 0)]
                                //切换中间列表的数据源
                                if dataSources[0].nodes.count > firstOffset {
                                    dataSources[1].nodes = dataSources[0].nodes[firstOffset].children
                                } else {
                                    assertionFailure()
                                }
                                dataSources[1].selectedIndexPaths = [IndexPath(row: offset, section: 0)]
                                self.choiceLastSectionSelection(
                                    conditions: conditions,
                                    conditionStrArray: conditionStrArray,
                                    nodes: secondCategory.children)
                            }
                        }
                    })
        }

        if dataSources[1].selectedNodes().count > 0,
            dataSources[2].nodes.count > 0 {
            self.displayExtendValue()
        }
    }

    func stringValueOfAny(_ value: Any) -> String {
        if let v = value as? String {
            return "\(v)"
        } else if let v = value as? Int {
            return "\(v)"
        } else if let v = value as? Int64 {
            return "\(v)"
        }
        return "\(value)"
    }


    fileprivate func choiceLastSectionSelection(conditions: [String : Any], conditionStrArray: [String], nodes: [Node]) {
        dataSources[2].selectedIndexPaths.removeAll()
        dataSources[2].nodes = nodes
        nodes
            .filter { $0.isEmpty != 1 }
            .enumerated()
            .forEach { (offset, item) in
                let key = getEncodingString("\(item.key)")
                if let _ = conditions[key],
                    let filterCondition = item.filterCondition {
                    let comparedCondition = "\(key)=\(stringValueOfAny(filterCondition))"
                    if conditionStrArray.contains(comparedCondition) {
//                        print(comparedCondition)
                        dataSources[2].selectedIndexPaths.insert(IndexPath(row: offset + 1, section: 0))
                    }
                }
            }

//        else
//        {
//            self.displayNormalCondition()
//        }
//        if needShowThirdList {
//            self.displayExtendValue()
//        }
//        let thirdTable = self.tableViews[2]
//        let thirdDs = self.dataSources[2]
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 2)) { [weak self] in
//            self?.scrollToFirstVisibleItem(tableView: thirdTable, datasource: thirdDs)
//        }

    }

    fileprivate func getEncodingString(_ string: String) -> String {
        let encodingString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodingString == nil ? string : encodingString!
    }

    override func viewDidDisplay() {
        setDataBySelectedState()
        adjustTablesLayout()
        scrollVisibleCellInScreen()
    }

    fileprivate func setDataBySelectedState() {
        if dataSources.count >= 3 {
            if let nodes = dataSources.first?.nodes {
                let selectedIndexPath = dataSources.first?.selectedIndexPaths.first ?? IndexPath(row: 0, section: 0)
                if nodes.count > selectedIndexPath.row {
                    reBindTableItemSelector()

                    //根据第一列选择行设置第二列数据
                    dataSources[1].nodes = nodes[selectedIndexPath.row].children
                    if dataSources[1].nodes.count > dataSources[1].selectedIndexPaths.first?.row ?? 0 {
                        //根据第二列选中行设置第三列数据
                        dataSources[2].nodes = dataSources[1].nodes[dataSources[1].selectedIndexPaths.first?.row ?? 0].children
                    }
                }
            }
            reloadAllTables()
        }
    }

    override func viewDidDismiss() {
//        print("AreaConditionFilterPanel -> viewDidDismiss")
        zip(dataSources, tableViews).forEach { (e) in
            let (dataSource, tableView) = e
            dataSource.restoreSelectedState()
            tableView.reloadData()
            if dataSource.nodes.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        //如果第三列没有任何选择项，则恢复成两列显示
//        if let dataSource = dataSources.last {
        adjustTablesLayout()
//        }
        scrollVisibleCellInScreen()
        FHFilterRedDotManager.shared.mark()
    }

    func adjustTablesLayout() {
        //如果第三列没有任何选择项，则恢复成两列显示
        //        if let dataSource = dataSources.last {
        if dataSources[1].selectedIndexPaths.count == 0 {
            self.displayNormalCondition()
        } else {
            if let row = dataSources[1].selectedIndexPaths.first?.row,
                row < dataSources[1].nodes.count {
                dataSources[2].nodes = dataSources[1].nodes[row].children
            }
            if dataSources[2].nodes.count > 0 {
                self.displayExtendValue()
            } else {
                self.displayNormalCondition()
            }
        }
    }

    func initPanelWithNativeDS() {

        dataSources.last?.isShowCheckBox = true
        dataSources.last?.isMultiSelected = true
        dataSources.first?.isShowRedDot = true
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
                    let subCategoryDS = self.dataSources[ConditionType.subCategory.rawValue]
                    let categoryDS = self.dataSources[ConditionType.category.rawValue]
                    let extentValueDS = self.dataSources[ConditionType.extendValue.rawValue]
                    subCategoryDS.nodes = categoryDS.nodes.first?.children ?? []
                    extentValueDS.nodes = subCategoryDS.nodes.first?.children ?? []


                    self.dataSources.forEach {
                        $0.selectedIndexPaths.removeAll()
                    }
                    self.reBindTableItemSelector()

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
                    if subCategoryTable.numberOfRows(inSection: 0) > 0 {
                        subCategoryTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }

                    self.displayNormalCondition()
                })
                .disposed(by: disposeBag)

        confirmBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.dataSources.forEach { $0.storeSelectedState() }
                    let selected = self.selectNodePath()
                    self.didSelect?(selected)
                })
                .disposed(by: disposeBag)
    }

    fileprivate func reBindTableItemSelector() {

        func bindExtensionValueListSelector(_ children: [Node]) {
            if children.count > 1,
                children[1].children.count > 0 {
                dataSources[ConditionType.subCategory.rawValue].onSelect = createSubCategorySelector(nodes: children)
            } else {
                dataSources[ConditionType.subCategory.rawValue].onSelect = { _ in }
                //触发收起第三级列表页收起
                self.displayNormalCondition()

            }
        }

        let categoryDS = dataSources[ConditionType.category.rawValue]
        categoryDS.onSelect = createCategorySelectorHandler(nodes: nodes)

        if let node = categoryDS.selectedNodes().first {
            bindExtensionValueListSelector(node.children)
        } else if let node = nodes.first {
            bindExtensionValueListSelector(node.children)
        }

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onInit() {

        let inputBgView = UIView()
        inputBgView.lu.addTopBorder(color: hexStringToUIColor(hex: "#e8eaeb"))
        inputBgView.backgroundColor = UIColor.white
        addSubview(inputBgView)
        inputBgView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalTo(60)
        }

        inputBgView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(20)
            maker.right.equalTo(self.snp.centerX).offset(-10)
            maker.height.equalTo(40)
        }

        inputBgView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.right.equalTo(-20)
            maker.left.equalTo(self.snp.centerX).offset(10)
            maker.height.equalTo(40)
        }


        tableViews[ConditionType.category.rawValue].snp.makeConstraints { maker in
            maker.left.top.equalToSuperview()
            maker.bottom.equalTo(inputBgView.snp.top)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.subCategory.rawValue].snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalTo(inputBgView.snp.top)
            maker.left.equalTo(tableViews[ConditionType.category.rawValue].snp.right)
            maker.width.equalTo(halfWidthOfScreen())
        }
        tableViews[ConditionType.extendValue.rawValue].snp.makeConstraints { maker in
            maker.top.right.equalToSuperview()
            maker.bottom.equalTo(inputBgView.snp.top)
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
            maker.left.equalTo(secondTableView.snp.right).offset(-0.5)
            maker.width.equalTo(0.5)
            maker.top.equalTo(secondTableView)
            maker.bottom.equalTo(inputBgView.snp.top)
        }

        bindAllTableReloader()
    }

    func bindAllTableReloader() {
        dataSources.forEach { [weak self] (ds) in
            ds.allTableReloader = {
                self?.tableViews.forEach({ (tableView) in
                    tableView.reloadData()
                })
            }
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
            } else { //点击第一列选项
                subCategoryDS?.nodes = nodes[indexPath.row].children
                subCategoryDS?.onSelect = self?.createSubCategorySelector(nodes: nodes[indexPath.row].children)
                subCategoryDS?.selectedIndexPaths.removeAll()

                extentValueDS?.selectedIndexPaths.removeAll()

                self?.displayNormalCondition()
                subCategoryTable?.reloadData()
                if subCategoryDS?.nodes.count ?? 0 > 0 {
//                    subCategoryTable?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    if let subCategoryTable = subCategoryTable {
                    subCategoryTable.scrollRectToVisible(CGRect(x: 0,
                                                         y: -10,
                                                         width: subCategoryTable.frame.width,
                                                         height: subCategoryTable.frame.height),
                                                  animated: false)
                    }
                }
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
            if indexPath.row >= nodes.count {
                return
            }
            let extentValueDS = self?.dataSources[ConditionType.extendValue.rawValue]
            let extentValueTable = self?.tableViews[ConditionType.extendValue.rawValue]
            let subCategoryTable = self?.tableViews[ConditionType.subCategory.rawValue]

            if nodes[indexPath.row].children.isEmpty {
                extentValueDS?.selectedIndexPaths.removeAll()
                extentValueTable?.reloadData()
                self?.displayNormalCondition()
            } else { // 点击中间列选项
                extentValueDS?.nodes = nodes[indexPath.row].children
                extentValueTable?.reloadData()
                if let displayExtendValue = self?.displayExtendValue {
                    self?.layoutWithAniminate(apply: displayExtendValue)
                }
                extentValueDS?.onSelect = { (indexPath) in
                    extentValueTable?.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                extentValueDS?.selectedIndexPaths.removeAll()
//                extentValueTable?.reloadData()

                subCategoryTable?.selectRow(
                        at: indexPath,
                        animated: false,
                        scrollPosition: .none)
                extentValueTable?.selectRow(
                        at: IndexPath(row: 0, section: 0),
                        animated: false,
                        scrollPosition: .none)
                if extentValueDS?.nodes.count ?? 0 > 0 {
                    DispatchQueue.main.async {
                        extentValueTable?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                }
            }
        }
    }

    func selectNodePath() -> [Node] {
        let selectedDatasource = dataSources[1...]
        let paths = selectedDatasource
                .reversed()
                .first {
                    $0.selectedIndexPaths.count > 0 && $0.selectedNodes().first?.isEmpty == 0
                }
                .map {
                    $0.selectedNodes()
                }
        return paths ?? []
    }

    override func selectedNodes() -> [Node] {
        return selectNodePath()
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

    fileprivate func scrollToFirstVisibleItem(tableView: UITableView, datasource: ConditionTableViewDataSource) {
        let sortedIndexPath = datasource.selectedIndexPaths.sorted()
        if datasource.selectedIndexPaths.count > 0,
            let itemPath = sortedIndexPath.first,
            itemPath.row < tableView.numberOfRows(inSection: 0) {
            tableView.scrollToRow(at: itemPath, at: .top, animated: false)
        } else {
            tableView.scrollRectToVisible(CGRect(x: 0,
                                                 y: -10,
                                                 width: tableView.frame.width,
                                                 height: tableView.frame.height),
                                          animated: false)
        }
    }

    func addTableViewScrollMonitor() {
        let firstTable = tableViews.first
        tableViews.forEach { (tableView) in
            tableView.rx.didScroll
                .skip(1)
                .debounce(0.3, scheduler: MainScheduler.instance)
                .bind(onNext: { [weak firstTable] () in
                    FHFilterRedDotManager.shared.mark()
                    firstTable?.reloadData()
                })
                .disposed(by: disposeBag)
        }
    }

}

fileprivate class ConditionTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []

    var selectedIndexPaths: Set<IndexPath> = []

    var onSelect: ((IndexPath) -> Void)?

    var isShowCheckBox = false

    var isMultiSelected = false

    let index: Int

    var isShowRedDot: Bool = false

    var allTableReloader: (() -> Void)?

    init(index: Int) {
        self.index = index
    }

    func restoreSelectedState() {
        selectedIndexPaths = originSelectIndexPaths
    }

    func storeSelectedState() {
        originSelectIndexPaths = selectedIndexPaths
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? AreaConditionCell, nodes.count > indexPath.row {
            theCell.label.text = nodes[indexPath.row].label
            theCell.showCheckbox(isShowCheckBox && nodes[indexPath.row].isEmpty != 1)
            if selectedIndexPaths.contains(indexPath) {
                setCellSelected(true, cell: theCell)
            }

            if selectedIndexPaths.count == 0 && indexPath.row == 0 {
                setCellSelected(true, cell: theCell)
            }
            if FHFilterRedDotManager.shared.shouldShowRedDot(key: nodes[indexPath.row].key) && isShowRedDot {
                theCell.redDot.isHidden = false
            } else {
                theCell.redDot.isHidden = true
            }
//            theCell.redDot.isHidden = true
            return theCell
        } else {
            return UITableViewCell()
        }
    }

    func setCellSelected(_ isSelected: Bool, cell: AreaConditionCell) {
        cell.checkboxBtn.isSelected = isSelected
        if isSelected {
            cell.label.textColor = hexStringToUIColor(hex: "#299cff")
        } else {
            cell.label.textColor = hexStringToUIColor(hex: "#081f33")
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
        FHFilterRedDotManager.shared.selectFilterItem(key: node.key)

        if !selectedIndexPaths.contains(indexPath) {
            if selectedIndexPaths.count >= 20 {
                fhShowToast("最多支持同时选中20个")
            } else {
                selectedIndexPaths.insert(indexPath)
            }
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        if let allTableReloader = allTableReloader {
            allTableReloader()
        } else {
            assertionFailure()
        }

    }

    func selectedNodes() -> [Node] {
        let sortedPaths = selectedIndexPaths.sorted(by: { (l, r) -> Bool in
            l.row < r.row
        })
        return sortedPaths.map { path -> Node in
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
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        result.numberOfLines = 2
        return result
    }()

    lazy var checkboxBtn: UIButton = {
        let re = UIButton()
        re.isHidden = true
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name"), for: .normal)
        re.setBackgroundImage(UIImage(named: "checkbox-checked"), for: .selected)
        return re
    }()

    lazy var redDot: UIView = {
        let re = UIView()
//        re.isHidden = true
        re.layer.cornerRadius = 2.5
        re.backgroundColor = hexStringToUIColor(hex: "#ff5b4c")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear

        contentView.addSubview(checkboxBtn)
        contentView.addSubview(label)

        checkboxBtn.snp.makeConstraints { maker in
            maker.right.equalTo(-23)
            maker.centerY.equalTo(label)
            maker.width.height.equalTo(14)
        }

        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgView
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(20)
            maker.bottom.equalToSuperview()
            maker.right.lessThanOrEqualTo(checkboxBtn.snp.left).offset(-5)
        }

        contentView.addSubview(redDot)
        redDot.snp.makeConstraints { (make) in
            make.top.equalTo(label).offset(4)
            make.left.equalTo(label.snp.right).offset(1)
            make.height.width.equalTo(5)
        }

    }

    fileprivate func showCheckbox(_ showCheckBox: Bool) {
        checkboxBtn.isHidden = !showCheckBox
        checkboxBtn.snp.updateConstraints { (maker) in
            if showCheckBox {
                maker.right.equalTo(-23)
            } else {
                maker.right.equalTo(0)
            }
        }
    }

    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        checkboxBtn.isHidden = true
        checkboxBtn.isSelected = false

        label.textColor = hexStringToUIColor(hex: "#081f33")
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
    let filterCondition: Any?
    let key: String
    let isSupportMulti: Bool
    let isEmpty: Int
    let isNoLimit: Int
    let parentLabel: String?
    let rate: Int
    let rankType: String?
    let children: [Node]

    init(id: String,
         label: String,
         externalConfig: String,
         filterCondition: Any?,
         key: String,
         isSupportMulti: Bool,
         isEmpty: Int,
         isNoLimit: Int,
         parentLabel: String? = nil,
         rate: Int,
         rankType: String? = nil,
         children: [Node]) {
        self.id = id
        self.label = label
        self.externalConfig = externalConfig
        self.filterCondition = filterCondition
        self.key = key
        self.isSupportMulti = isSupportMulti
        self.isEmpty = isEmpty
        self.isNoLimit = isNoLimit
        self.parentLabel = parentLabel
        self.rate = rate
        self.rankType = rankType
        self.children = children
    }

    init(
        id: String,
        label: String,
        externalConfig: String,
        filterCondition: Any?,
        key: String) {
        self.id = id
        self.label = label
        self.isEmpty = 0
        self.isNoLimit = 0
        self.externalConfig = externalConfig
        self.filterCondition = filterCondition
        self.key = key
        self.isSupportMulti = false
        self.parentLabel = nil
        self.rate = 1
        self.rankType = "unknowned"
        self.children = []
    }
}
