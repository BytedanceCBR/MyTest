//
//  PriceListFilterPanel.swift
//  Bubble
//
//  Created by linlin on 2018/6/21.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

func constructPriceListConditionPanelWithContainer(
        index: Int,
        nodes: [Node],
        container: UIView,
        action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
        let thePanel = PriceListFilterPanel(nodes: nodes.first?.children ?? [])
        thePanel.isHidden = true
        container.addSubview(thePanel)
        thePanel.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(352)
        }
        thePanel.didSelect = { nodes in action(index, nodes) }

        NotificationCenter.default.rx
                .notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
                .debounce(0.08, scheduler: MainScheduler.instance)
                .subscribe(onNext: { notification in
                    let userInfo = notification.userInfo!
                    let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

                    let animations:(() -> Void) = {
                        if thePanel.superview != nil {
                            //键盘的偏移量
                            thePanel.snp.remakeConstraints { maker in
                                maker.left.right.top.equalToSuperview()
                                maker.bottom.equalToSuperview().offset(-keyBoardBounds.size.height)
                            }
                        }
                    }

                    if duration > 0 {
                        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                        UIView.animate(
                                withDuration: duration,
                                delay: 0,
                                options:options,
                                animations: animations,
                                completion: nil)
                    }else{
                        animations()
                    }
                })
                .disposed(by: thePanel.disposeBag)
        return thePanel
}

func constructPriceListConditionPanel(
        nodes: [Node],
        _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    let disposeBag = DisposeBag()
    return { (index, container) in
        if let container = container, let node = nodes.first {
            let thePanel = PriceListFilterPanel(nodes: node.children)
            container.addSubview(thePanel)
            thePanel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(352)
            }
            thePanel.didSelect = { nodes in action(index, nodes) }

            NotificationCenter.default.rx
                .notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
                .subscribe(onNext: { notification in
                    let userInfo = notification.userInfo!
                    let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

                    let animations:(() -> Void) = {
                        if thePanel.superview != nil {
                        //键盘的偏移量
                            thePanel.snp.remakeConstraints { maker in
                                maker.left.right.top.equalToSuperview()
                                maker.bottom.equalToSuperview().offset(-keyBoardBounds.size.height)
                            }
                        }
                    }

                    if duration > 0 {
                        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                        UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
                    }else{
                        animations()
                    }
                })
                .disposed(by: disposeBag)
            return thePanel
        }
        return nil
    }
}

func catulateOffsetByKeybroadSize(_ panel: PriceListFilterPanel?, keybrodaSize: CGSize) -> CGFloat {
    let safeHeight = UIScreen.main.bounds.size.height - keybrodaSize.height
    var offset: CGFloat = 0
    if let panel = panel {
        offset = (panel.frame.minY + panel.frame.height + 104) - safeHeight
    }
    return offset
}

func parsePriceConditionItemLabel(label: String, nodePath: [Node]) -> ConditionItemType {
    if let node = nodePath.last, node.label != "不限" {
        if nodePath.count > 1 {
            return .condition("\(label)(\(nodePath.count))")
        } else {
            return .condition(node.label)
        }
    }
    return .noCondition(label)
}

func parsePriceSearchCondition(nodePath: [Node]) -> (String) -> String {
    return {
        return nodePath.reduce($0) { (result, node) in
            "\(result)&\(node.externalConfig)"
        }
    }
}

class PriceListFilterPanel: BaseConditionPanelView {

    var dataSource: PriceListTableViewDataSource

    var didSelect: (([Node]) -> Void)?

    let disposeBag = DisposeBag()

    var queryKey: String?

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        result.rowHeight = UITableViewAutomaticDimension

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
        if nodes.count > 1 {
            queryKey = nodes[1].key
        }
        dataSource.nodes = nodes
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        self.dataSource.bottomInputView = bottomInputView
        setupUI()
    }

    func setupUI() {
        dataSource.didSelect = { [weak self] nodes in
            self?.bottomInputView.upperPriceTextField.text = ""
            self?.bottomInputView.lowerPriceTextField.text = ""
        }

        let rate = self.dataSource.nodes.first?.rate ?? 1
        self.bottomInputView.lowerPriceTextField.placeholder = "最低价格 (\(self.getRateTextByRateValue(rate)))"
        self.bottomInputView.upperPriceTextField.placeholder = "最高价格 (\(self.getRateTextByRateValue(rate)))"
        
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
        tableView.selectRow(
            at: IndexPath(row: 0, section: 0),
            animated: false,
            scrollPosition: .none)
        bindInputPanelObservable()
        binfConfig()
        dataSource.didSelect = { [unowned self] (nodes) in
            self.didSelect?(nodes)
        }

        dataSource.selectedIndexPaths
                .skip(1)
                .filter { $0.count != 0 }
                .bind { [unowned self] set in
                    self.bottomInputView.upperPriceTextField.text = nil
                    self.bottomInputView.lowerPriceTextField.text = nil
                    self.bottomInputView.lowerPriceTextField.resignFirstResponder()
                    self.bottomInputView.upperPriceTextField.resignFirstResponder()
                }.disposed(by: disposeBag)
    }

    func bindInputPanelObservable() {
        bottomInputView.upperPriceTextField.rx.text
                .filter { $0?.isEmpty == false }
                .subscribe(onNext: { [unowned self] s in
                    self.dataSource.selectedIndexPaths.accept([])
                    self.tableView.reloadData()
                })
                .disposed(by: disposeBag)
        bottomInputView.lowerPriceTextField.rx.text
                .filter { $0?.isEmpty == false }
                .subscribe(onNext: { [unowned self] s in
                    self.dataSource.selectedIndexPaths.accept([])
                    self.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

    override func viewDidDisplay() {
//        print("AreaConditionFilterPanel -> viewDidDisplay")
        self.bottomInputView.lowerPriceTextField.text = dataSource.lowerInput
        self.bottomInputView.upperPriceTextField.text = dataSource.upperInput
    }

    override func viewDidDismiss() {
//        print("AreaConditionFilterPanel -> viewDidDismiss")
        dataSource.restoreSelectedState()
        tableView.reloadData()
        self.bottomInputView.lowerPriceTextField.resignFirstResponder()
        self.bottomInputView.upperPriceTextField.resignFirstResponder()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func binfConfig() {
        bottomInputView.configBtn.rx.tap
            .subscribe(onNext: { [unowned self] () in


                self.dataSource.storeSelectedState()
                let nodes = self.dataSource.nodes
                let datas = self.dataSource.selectedIndexPaths.value.map { path -> Node in
                    nodes[path.row]
                }
                if datas.isEmpty {
                    self.processUserInputPrice()

//                    } else{
//                        self.dataSource.lowerInput = ""
//                        self.dataSource.upperInput = ""
//                        self.didSelect?([])
//                    }
                } else {
                    self.dataSource.lowerInput = ""
                    self.dataSource.upperInput = ""
                    self.didSelect?(datas)
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func processUserInputPrice() {
        let rate = self.dataSource.nodes.first?.rate ?? 1
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        let theQueryKey = self.queryKey ?? "price"
        let low = Int(self.bottomInputView.lowerPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0
        let upper = Int(self.bottomInputView.upperPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0

        if low == 0 && upper == 0 {
            self.dataSource.lowerInput = ""
            self.dataSource.upperInput = ""
            self.didSelect?([])
            return
        } else if low == 0 {
            self.dataSource.lowerInput = "\(low)"
            self.dataSource.upperInput = "\(upper)"
            self.didSelect?([Node(
                id: "",
                label: "\(low)-\(upper)\(getRateTextByRateValue(rate))",
                externalConfig: "\(theQueryKey)=[\(low * rate),\(upper * rate)]",
                filterCondition: "[\(low * rate),\(upper * rate)" as Any,
                key: "\(theQueryKey)")])
        } else if upper == 0 {
            self.dataSource.lowerInput = "\(low)"
            self.dataSource.upperInput = ""
            self.didSelect?([Node(
                id: "",
                label: "\(low)\(getRateTextByRateValue(rate))以上",
                externalConfig: "\(theQueryKey)=[\(low * rate)]",
                filterCondition: "[\(low * rate)]" as Any,
                key: "\(theQueryKey)")])
        } else {
            let theLow = low < upper ? low : upper
            let theUpper = low < upper ? upper : low
            self.dataSource.lowerInput = "\(theLow)"
            self.dataSource.upperInput = "\(theUpper)"
            self.didSelect?([Node(
                id: "",
                label: "\(theLow)-\(theUpper)\(getRateTextByRateValue(rate))",
                externalConfig: "\(theQueryKey)=[\(theLow * rate),\(theUpper * rate)]",
                filterCondition: "[\(theLow * rate),\(theUpper * rate)" as Any,
                key: "\(theQueryKey)")])
        }
    }

    func getRateTextByRateValue(_ rate: Int) -> String {
        if rate == 10000 {
            return "万"
        } else {
            return "元"
        }
    }

    func textDidChange(_ textInput: UITextInput?) {
        
    }

    override func setSelectedConditions(conditions: [String : Any]) {
        dataSource.selectedIndexPaths.accept([])
        self.tableView.reloadData()
        let rate = self.dataSource.nodes.first?.rate ?? 1
        let conditionStrArray = conditions
            .map { (e) -> [String] in
                convertKeyValueToCondition(key: e.key, value: e.value)
            }.reduce([]) { (result, nodes) -> [String] in
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

        //如果没有匹配到列表页中的任何项，则将第一条数据填充到用户自定义输入中
        if self.dataSource.selectedIndexPaths.value.count == 0 {
            if let priceKey = (self.queryKey ?? "price").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let price = conditions[priceKey],
                    let priceString = (price as? [String])?.first,
                    let jsonData = priceString.data(using: .utf8),
                    let datas = try? JSONSerialization.jsonObject(with: jsonData) as? [Int] ?? [] {
                    if datas.count == 1 {
                        self.bottomInputView.lowerPriceTextField.text = "\((datas.first ?? 0) / rate)"
                    } else if datas.count == 2 {
                        self.bottomInputView.lowerPriceTextField.text = "\(datas[0] / rate)"
                        self.bottomInputView.upperPriceTextField.text = "\(datas[1] / rate)"
                    }
                    if datas.count > 0 {
                        self.processUserInputPrice()
                    } else {
                        self.didSelect?(self.dataSource.selectedNodes())
                    }
                }
            }
        } else {
            self.dataSource.storeSelectedState()
            self.didSelect?(self.dataSource.selectedNodes())
        }
        self.tableView.reloadData()
    }

    fileprivate func getEncodingString(_ string: String) -> String {
        let encodingString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodingString == nil ? string : encodingString!
    }

}

class PriceListTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []

    let selectedIndexPaths = BehaviorRelay<Set<IndexPath>>(value: [])

    var didSelect: (([Node]) -> Void)?
    
    var disableDefaultSelected = false
    
    var lowerInput: String = ""

    var upperInput: String = ""
    
    fileprivate weak var bottomInputView: PriceBottomInputView?

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
            if selectedIndexPaths.value.count == 0,
                nodes[indexPath.row].isNoLimit == 1,
                bottomInputView?.lowerPriceTextField.text?.isEmpty ?? true,
                bottomInputView?.upperPriceTextField.text?.isEmpty ?? true {
                setCellSelected(true, cell: theCell)
            }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nodes[indexPath.row].isNoLimit == 1 {
//            didSelect?([nodes[indexPath.row]])
            self.bottomInputView?.lowerPriceTextField.text = nil
            self.bottomInputView?.upperPriceTextField.text = nil
            selectedIndexPaths.accept([])
            tableView.reloadData()
            
        } else {
            if !selectedIndexPaths.value.contains(indexPath) {
                var selected = selectedIndexPaths.value
                selected.insert(indexPath)
                selectedIndexPaths.accept(selected)
            } else {
                var selected = selectedIndexPaths.value
                selected.remove(indexPath)
                selectedIndexPaths.accept(selected)
            }


            tableView.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func restoreSelectedState() {
        selectedIndexPaths.accept(originSelectIndexPaths)
    }

    func storeSelectedState() {
        originSelectIndexPaths = selectedIndexPaths.value
    }

    func selectedNodes() -> [Node] {
        return selectedIndexPaths.value.map { path -> Node in
            nodes[path.row]
        }
    }

}

class PriceListItemCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#45494d")
        return result
    }()

    lazy var checkboxBtn: UIButton = {
        let re = UIButton()
        re.setBackgroundImage(#imageLiteral(resourceName: "invalid-name"), for: .normal)
        re.setBackgroundImage(UIImage(named: "checkbox-checked"), for: .selected)
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

    override func prepareForReuse() {
        checkboxBtn.isSelected = false
        label.textColor = hexStringToUIColor(hex: "#45494d")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class PriceBottomInputView: UIView, UITextFieldDelegate {

    lazy var lowerPriceTextField: UITextField = {
        let re = UITextField()
        re.placeholder = "最低价格 (万)"
        re.textAlignment = .left
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.layer.cornerRadius = 4
        re.keyboardType = .numberPad
        re.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        re.leftViewMode = .always
        re.delegate = self
        return re
    }()

    lazy var upperPriceTextField: UITextField = {
        let re = UITextField()
        re.placeholder = "最高价格 (万)"
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textAlignment = .left
        re.layer.cornerRadius = 4
        re.keyboardType = .numberPad
        re.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        re.leftViewMode = .always
        re.delegate = self

        return re
    }()

    lazy var configBtn: UIButton = {
        let re = UIButton()
        re.setTitle("确定", for: .normal)
        re.setTitleColor(UIColor.white, for: .normal)
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        return re
    }()

    lazy var seperaterLineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()

    lazy var topBorderLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()

    lazy var priceInputBoard: UIView = {
        let re = UIView()
        return re
    }()

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.white

        addSubview(configBtn)
        configBtn.snp.makeConstraints { maker in
            maker.right.top.bottom.equalToSuperview()
            maker.width.greaterThanOrEqualTo(90).priority(.high)
        }

        addSubview(priceInputBoard)
        priceInputBoard.snp.makeConstraints { maker in
            maker.top.bottom.left.equalToSuperview()
            maker.right.equalTo(configBtn.snp.left)
        }


        priceInputBoard.addSubview(lowerPriceTextField)
        lowerPriceTextField.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(8)
            maker.bottom.equalTo(-8)
            maker.height.equalTo(28)
            maker.right.equalTo(priceInputBoard.snp.centerX).offset(-10)
        }

        priceInputBoard.addSubview(seperaterLineView)
        seperaterLineView.snp.makeConstraints { maker in
            maker.left.equalTo(lowerPriceTextField.snp.right).offset(5)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(1)
            maker.width.equalTo(10)
        }

        priceInputBoard.addSubview(upperPriceTextField)
        upperPriceTextField.snp.makeConstraints { maker in
            maker.left.equalTo(seperaterLineView.snp.right).offset(5)
            maker.top.equalTo(8)
            maker.bottom.equalTo(-8)
            maker.height.equalTo(28)
            maker.width.greaterThanOrEqualTo(80)
            maker.right.equalTo(-20)
        }

//        addSubview(topBorderLine)
//        topBorderLine.snp.makeConstraints { maker in
//            maker.left.right.top.equalToSuperview()
//            maker.height.equalTo(0.5)
//         }
        self.lu.addTopBorder(color: hexStringToUIColor(hex: kFHSilver2Color))
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UITextFieldTextDidChange, object: nil)
            .subscribe(onNext: { [unowned self] notification in
                if let text = self.lowerPriceTextField.text, text.count > 9 {
                    let index = text.index(text.startIndex, offsetBy: 0)
                    let endIndex = text.index(text.startIndex, offsetBy:9)

                    self.lowerPriceTextField.text =  String(text[index..<endIndex])
                }

                if let text = self.upperPriceTextField.text, text.count > 9 {
                    let index = text.index(text.startIndex, offsetBy: 0)
                    let endIndex = text.index(text.startIndex, offsetBy:9)
                    self.upperPriceTextField.text = String(text[index..<endIndex])

                }
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        if (range.length == 1 && string.count == 0) {
            return true
        } else if (textField.text?.count ?? 0 >= 9) {
            return false
        } else if Int(string) == nil {
            return false
        } else if  (textField.text?.count ?? 0 + string.count >= 9) {
            return false
        }
        return true
    }
}
