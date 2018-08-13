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
func constructPriceListConditionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    var thePanel: PriceListFilterPanel? = nil
    let disposeBag = DisposeBag()
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

            NotificationCenter.default.rx
                .notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
                .subscribe(onNext: { notification in
                    let userInfo = notification.userInfo!
                    let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

                    let animations:(() -> Void) = {
                        if thePanel?.superview != nil {
                        //键盘的偏移量
                            thePanel?.snp.remakeConstraints { maker in
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
        }
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

class PriceListFilterPanel: UIView {

    var dataSource: PriceListTableViewDataSource

    var didSelect: (([Node]) -> Void)?

    let disposeBag = DisposeBag()

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
            self?.bottomInputView.upperPriceTextField.text = ""
            self?.bottomInputView.lowerPriceTextField.text = ""
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func binfConfig() {
        bottomInputView.configBtn.rx.tap
            .subscribe(onNext: { [unowned self] () in
                let nodes = self.dataSource.nodes
                let datas = self.dataSource.selectedIndexPaths.value.map { path -> Node in
                    nodes[path.row]
                }
                if datas.isEmpty {
                    if let low = Int(self.bottomInputView.lowerPriceTextField.text ?? ""),
                            let upper = Int(self.bottomInputView.upperPriceTextField.text ?? "") {
                        self.didSelect?([Node(
                            id: "",
                            label: "\(low)-\(upper)万",
                            externalConfig: "price[]=[\(low * 10000),\(upper * 10000)]")])
                    } else{
                        self.didSelect?([])

                    }
                } else {
                    self.didSelect?(datas)
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

}

class PriceListTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var nodes: [Node] = []

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
            if selectedIndexPaths.value.count == 0, nodes[indexPath.row].isNoLimit == 1 {
                setCellSelected(true, cell: theCell)
            }
        }
        return cell ?? UITableViewCell()
    }

    fileprivate func setCellSelected(_ isSelected: Bool, cell: PriceListItemCell) {
        cell.checkboxBtn.isSelected = isSelected
        if isSelected {
            cell.label.textColor = hexStringToUIColor(hex: "#f85959")
        } else {
            cell.label.textColor = hexStringToUIColor(hex: "#222222")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nodes[indexPath.row].isNoLimit == 1 {
            didSelect?([nodes[indexPath.row]])
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
}

class PriceListItemCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
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

    override func prepareForReuse() {
        checkboxBtn.isSelected = false
        label.textColor = hexStringToUIColor(hex: "#222222")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class PriceBottomInputView: UIView {

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

    lazy var priceInputBoard: UIView = {
        let re = UIView()
        return re
    }()

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
