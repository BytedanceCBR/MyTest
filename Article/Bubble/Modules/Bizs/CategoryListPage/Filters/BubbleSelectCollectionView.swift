//
//  BubbleSelectCollectionView.swift
//  Bubble
//
//  Created by linlin on 2018/6/20.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

//MARK: 构造半屏幕collection搜索过滤器 （户型/楼龄）
func constructBubbleSelectCollectionPanelWithContainer(
        index: Int,
        nodes: [Node],
        container: UIView,
        _ action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
    let thePanel = BubbleSelectCollectionView(nodes: nodes)
    thePanel.isHidden = true
    container.addSubview(thePanel)
    thePanel.snp.makeConstraints { maker in
        maker.left.right.top.equalToSuperview()
        maker.height.equalTo(208)
    }
    
    thePanel.contentSizeDidChange = { [unowned thePanel] size in
        let height = min(size.height , thePanel.superview!.height)
        thePanel.snp.updateConstraints({ (maker) in
            maker.height.equalTo(height)
        })
    }
    
    thePanel.didSelect = { nodes in
        action(index, nodes)
    }
    return thePanel
}

func constructBubbleSelectCollectionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let thePanel = BubbleSelectCollectionView(nodes: nodes)
            container.addSubview(thePanel)
            thePanel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(190)
            }
            thePanel.clearBtn.setTitle("不限条件", for: .normal)

            thePanel.didSelect = { nodes in
                action(index, nodes)
            }
            return thePanel
        }
        return nil
    }
}

func parseHorseTypeConditionItemLabel(label: String, nodePath: [Node]) -> ConditionItemType {
    if nodePath.count > 1 {
        return .condition("\(label) (\(nodePath.count))")
    } else if nodePath.count == 1 {
        return .condition(nodePath.first!.label)
    } else {
        return .noCondition(label)
    }
}

func parseHorseTypeSearchCondition(nodePath: [Node]) -> (String) -> String {
    return { query in
        if let (head, tail) = nodePath.slice.decomposed {
            let content = tail.reduce(head.externalConfig, { (result, node) -> String in
                "\(result)&\(node.externalConfig)"
            })
            return "\(query)&\(content)"
        } else {
            if let externalConfig = nodePath.first?.externalConfig {
                return "\(query)&\(externalConfig)"
            } else {
                return query
            }
        }
    }
}

//MARK: 更多过滤器
func constructMoreSelectCollectionPanelWithContainer(
        index: Int,
        nodes: [Node],
        container: UIView,
        _ action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
    let thePanel = BubbleSelectCollectionView(nodes: nodes,
                                              resetBtnName: "重置",
                                              queryWhenClean: false)
    thePanel.isHidden = true
    container.addSubview(thePanel)
    thePanel.snp.makeConstraints { maker in
        maker.left.right.top.bottom.equalToSuperview()
    }
    thePanel.didSelect = { nodes in
        action(index, nodes)
    }
    
    thePanel.contentSizeDidChange = { [unowned thePanel] size in
        let height = min(size.height , thePanel.superview!.height)
        let offset = height - thePanel.superview!.height
        thePanel.snp.updateConstraints({ (maker) in
            maker.bottom.equalToSuperview().offset(offset)
        })
    }
    
    return thePanel
}

func constructMoreSelectCollectionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let thePanel = BubbleSelectCollectionView(nodes: nodes)
            container.addSubview(thePanel)
            thePanel.snp.makeConstraints { maker in
                maker.left.right.top.bottom.equalToSuperview()
            }
            thePanel.didSelect = { nodes in
                action(index, nodes)
            }
            return thePanel
        }
        return nil
    }
}

func parseMoreConditionItemLabel(label: String, nodePath: [Node]) -> ConditionItemType {
    if nodePath.count >= 1 {
        return .condition("\(label)(\(nodePath.count))")
//    }
//    else if nodePath.count == 1 {
//        return .condition(nodePath.first!.label)
    } else {
        return .noCondition(label)
    }
}

//TODO: fixbug 滚动栏跑偏
class BubbleSelectCollectionView: BaseConditionPanelView {

    var collectionView: UICollectionView?

    lazy var clearBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.white

        result.setTitle("不限条件", for: .normal)
        result.layer.cornerRadius = 20
        result.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        result.setTitleColor(hexStringToUIColor(hex: kFHDarkIndigoColor), for: .normal)
        return result
    }()

    lazy var confirmBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = hexStringToUIColor(hex: "#299cff")
        result.layer.cornerRadius = 20
        result.setTitle("确定", for: .normal)
        return result
    }()

    fileprivate class func catulateCellWidthBaseOnScreen() -> CGFloat {
        let collectionViewWidth = UIScreen.main.bounds.width - 24 * 2
        if (75 * 4 + 9 * 3) > collectionViewWidth {
            return (collectionViewWidth - 9 * 2) / 3
        } else {
            return 75
        }
    }

    var dataSource: BubbleSelectDataSource

    var didSelect: (([Node]) -> Void)?
    
    var contentSizeDidChange : ((CGSize) -> Void)?

    let disposeBag = DisposeBag()

    var contentDisposeBag : DisposeBag? = DisposeBag()
    
    var headerViewType: AnyClass
    var queryWhenClean: Bool = true

    convenience init(nodes: [Node], resetBtnName: String = "不限条件", queryWhenClean: Bool = true) {
        self.init(nodes: nodes, headerView: BubbleCollectionSectionHeader.self)
        self.queryWhenClean = queryWhenClean
        clearBtn.setTitle(resetBtnName, for: .normal)
    }

    init(
            dataSource: BubbleSelectDataSource,
            delegate: UICollectionViewDelegate) {
        self.dataSource = dataSource
        self.headerViewType = BubbleCollectionSectionHeader.self
        super.init(frame: CGRect.zero)
        self.collectionView = BubbleSelectCollectionView.createCollectionView()
        setupUI()
        collectionView?.delegate = delegate
        collectionView?.dataSource = dataSource
    }

    convenience init(nodes: [Node], headerView: AnyClass) {
        let dataSource = BubbleSelectDataSource(nodes: nodes)
        self.init(nodes: nodes, headerView: headerView, dataSource: dataSource)
        self.dataSource = dataSource
        setupUI()
    }

    init(nodes: [Node], headerView: AnyClass, dataSource: BubbleSelectDataSource) {
        self.headerViewType = headerView
        let dataSource = dataSource
        self.dataSource = dataSource
        self.collectionView = BubbleSelectCollectionView.createCollectionView()

        super.init(frame: CGRect.zero)

        setupUI()
        collectionView?.dataSource = dataSource
        collectionView?.delegate = dataSource
        collectionView?.reloadData()
    }
    override func setSelectedConditions(conditions: [String : Any]) {
        dataSource.selectedIndexPaths.accept([])
        collectionView?.reloadData()
        let conditionStrArray = conditions
            .map { (e) -> [String] in
                convertKeyValueToCondition(key: e.key, value: e.value)
            }.reduce([]) { (result, nodes) -> [String] in
                result + nodes
        }
        dataSource.nodes
            .enumerated()
            .forEach { [weak dataSource] (offset, e) in
                e.children.filter { $0.isEmpty == 0 }
                    .enumerated()
                    .forEach { (rowOffset, item) in
                        if let externalConfig = item.externalConfig.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                            conditionStrArray.contains(externalConfig) {
                            if var indexs = dataSource?.selectedIndexPaths.value {
                                indexs.insert(IndexPath(row: rowOffset, section: offset))
                                dataSource?.selectedIndexPaths.accept(indexs)
                            }
                        }
                }
        }
//        self.didSelect?(self.dataSource.selectedNodes())
        self.conditionLabelSetter?(self.dataSource.selectedNodes())
        self.dataSource.storeSelectedState()
    }

    class func createCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: BubbleSelectCollectionView.catulateCellWidthBaseOnScreen(), height: 28)
        flowLayout.minimumLineSpacing = 12
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        result.backgroundColor = UIColor.clear
        return result
    }

    func setupUI() {
        backgroundColor = UIColor.white
        let inputBgView = UIView()
        inputBgView.lu.addTopBorder(color: hexStringToUIColor(hex: "#e8eaeb"))
        inputBgView.backgroundColor = UIColor.white
        addSubview(inputBgView)
        inputBgView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(60)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }

        inputBgView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(self.snp.centerX).offset(-10)
            maker.height.equalTo(40)
            maker.bottom.equalTo(-10)
        }

        inputBgView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { maker in
            maker.right.equalTo(-20)
            maker.bottom.equalTo(clearBtn)
            maker.left.equalTo(self.snp.centerX).offset(10)
            maker.height.equalTo(40)
        }
        if let collectionView = collectionView {
            addSubview(collectionView)
            collectionView.snp.makeConstraints { maker in
                maker.top.left.right.equalToSuperview()
                maker.bottom.equalTo(inputBgView.snp.top)
            }
            collectionView.register(
                    BubbleCollectionCell.self,
                    forCellWithReuseIdentifier: "item")
            collectionView.register(
                    headerViewType,
                    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "header")
            collectionView.register(
                BubbleCollectionSectionHeader.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "default")


            collectionView.rx.observe(CGSize.self, "contentSize", options: .new, retainSelf: false)
                .subscribe(onNext: { [unowned self](size) in
                    if let size = size {
                        self.contentSizeDidChange?(CGSize(width: size.width,height: size.height + 10.0 + 60.0)) // collection view height + vertical margin + input bg view
                    }
                })
                .disposed(by: contentDisposeBag!)
        }
        bindButtonActions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        contentDisposeBag = nil
    }

    func bindButtonActions() {
        confirmBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
                self.onConfirm()
            })
            .disposed(by: disposeBag)

        clearBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
                self.onClean()
            })
            .disposed(by: disposeBag)
    }

    func onConfirm() {
        self.dataSource.storeSelectedState()
        self.didSelect?(self.dataSource.selectedNodes())
    }

    func onClean() {
        self.dataSource.selectedIndexPaths.accept([])
        self.collectionView?.reloadData()
        if queryWhenClean {
            self.didSelect?([])
        }
    }

    override func viewDidDisplay() {
//        print("AreaConditionFilterPanel -> viewDidDisplay")
    }

    override func viewDidDismiss() {
//        print("AreaConditionFilterPanel -> viewDidDismiss")
        dataSource.restoreSelectedState()
        collectionView?.reloadData()
    }

    override func selectedNodes() -> [Node] {
        self.dataSource.storeSelectedState()
        return dataSource.selectedNodes()
    }

}

class BubbleSelectDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []
    fileprivate var selectedIndexPaths = BehaviorRelay<Set<IndexPath>>(value: [])

    var headerViewBinder: ((UICollectionReusableView) -> Void)?

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nodes.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes[section].children.filter { $0.isEmpty == 0 }.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath)
        if let theCell = cell as? BubbleCollectionCell {
            theCell.label.text = nodes[indexPath.section].children.filter { $0.isEmpty == 0 }[indexPath.row].label
            if selectedIndexPaths.value.contains(indexPath) {
                theCell.isSelected = true
            } else {
                theCell.isSelected = false
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if nodes[indexPath.section].isSupportMulti != true {
            if selectedIndexPaths.value.contains(indexPath) {
                selectedIndexPaths.accept(selectedIndexPaths.value.filter { $0.section != indexPath.section })
            } else if selectedIndexPaths.value.contains(where: { $0.section == indexPath.section }) {
                var indexs = selectedIndexPaths.value.filter { $0.section != indexPath.section }
                indexs.insert(indexPath)
                selectedIndexPaths.accept(indexs)
            } else {
                var indexs = selectedIndexPaths.value
                indexs.insert(indexPath)
                selectedIndexPaths.accept(indexs)
            }
        } else {
            if !selectedIndexPaths.value.contains(indexPath) {
                var indexs = selectedIndexPaths.value
                indexs.insert(indexPath)
                selectedIndexPaths.accept(indexs)
            } else {
                var indexs = selectedIndexPaths.value
                indexs.remove(indexPath)
                selectedIndexPaths.accept(indexs)
            }
        }


        collectionView.reloadData()    
    }

    func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        if let theHeaderView = headerView as? BubbleCollectionSectionHeader {
            theHeaderView.label.text = nodes[indexPath.section].label
        }
        return headerView
    }

    func selectedNodes() -> [Node] {
        let sortedSelecteds = selectedIndexPaths.value.sorted(by: { (left, right) -> Bool in
            if left.section < right.section {
                return true
            } else if left.section == right.section {
                return left.row <= right.row
            } else {
                return false
            }
        })
        return sortedSelecteds.map {
            nodes[$0.section].children.filter { $0.isEmpty == 0 }[$0.row]
        }
    }

    func restoreSelectedState() {
        selectedIndexPaths.accept(originSelectIndexPaths)
    }

    func storeSelectedState() {
        originSelectIndexPaths = selectedIndexPaths.value
    }

    func unselectedIndexsExportFor(key: String) -> Set<IndexPath> {
        let indexPaths =  selectedIndexPaths.value.filter { (indexPath) in
            let node = nodes[indexPath.section].children[indexPath.row]
            return node.key == key
        }
        return indexPaths
    }

    func isOnlySelected(key: String) -> Bool {
        var result = true
        selectedIndexPaths.value.forEach { (indexPath) in
            let node = nodes[indexPath.section].children[indexPath.row]
            if node.key != key {
                result = false
            }
        }
        return result
    }
}

class BubbleCollectionCell: UICollectionViewCell {

    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
    internal override var isSelected: Bool {
        didSet {
            configSelectedStyle(isSelected: isSelected)
        }
    }
    lazy var label: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: "#45494d")
        result.highlightedTextColor = hexStringToUIColor(hex: "#ffffff")
        result.adjustsFontSizeToFitWidth = true
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textAlignment = .center
        return result
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        configSelectedStyle(isSelected: isSelected)
        label.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
            maker.width.greaterThanOrEqualTo(65)
        }
    }

    private func configSelectedStyle(isSelected: Bool) {
        if isSelected {
            label.textColor = hexStringToUIColor(hex: "#ffffff")
            contentView.layer.cornerRadius = 4
            contentView.backgroundColor = hexStringToUIColor(hex: "#299cff")
        } else {
            label.textColor = hexStringToUIColor(hex: "#45494d")
            contentView.layer.cornerRadius = 4
            contentView.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.isSelected = false
        contentView.layer.masksToBounds = false
        contentView.layer.borderColor = hexStringToUIColor(hex: "#f4f5f6").cgColor
    }

}

class BubbleCollectionSectionHeader: UICollectionReusableView {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(16)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        return result
    }()

    lazy var deleteBtn: UIButton = {
        let re = UIButton()
        re.isHidden = true
        re.setBackgroundImage(UIImage(named: "delete"), for: .normal)
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(16)
            maker.bottom.equalToSuperview().offset(-14)
            maker.right.equalTo(-20)
            maker.left.equalTo(20)
        }

        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { maker in
            maker.height.width.equalTo(20)
            maker.right.equalTo(-20)
            maker.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deleteBtn.isHidden = true
    }
}


//MARK: 单选样式价格选择器

func constructPriceBubbleSelectCollectionPanelWithContainer(
    index: Int,
    nodes: [Node],
    container: UIView,
    _ action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
    let thePanel = PriceBubbleSelectCollectionView(nodes: nodes, headerView: PriceBubbleCollectionSectionHeader.self)
    thePanel.isHidden = true
    container.addSubview(thePanel)
    thePanel.queryKey = nodes.first?.key
    thePanel.snp.makeConstraints { maker in
        maker.left.right.top.equalToSuperview()
        maker.height.equalTo(208)
    }

    thePanel.contentSizeDidChange = { [unowned thePanel] size in
        let height = min(size.height , thePanel.superview!.height)
        thePanel.snp.updateConstraints({ (maker) in
            maker.height.equalTo(height)
        })
    }

    thePanel.didSelect = { nodes in
        action(index, nodes)
    }
    if let layout = thePanel.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 114)
    }
    return thePanel
}

class PriceBubbleSelectCollectionView: BubbleSelectCollectionView  {

    var queryKey: String?

    var fillPriceInput: (() -> Void)?

    var userInput: [String]?

    init(nodes: [Node], headerView: AnyClass) {
        let dataSource = PriceBubbleSelectDataSource(nodes: nodes)
        super.init(
            nodes: nodes,
            headerView: headerView,
            dataSource: dataSource)
//        self.collectionView = PriceBubbleSelectCollectionView.createCollectionView()
//        self.collectionView?.dataSource = dataSource
//        self.collectionView?.delegate = dataSource
        if let ds = self.priceDataSource() {
            ds.onHeaderViewInit = { [weak self] in
                self?.bindInputPanelObservable()
            }
        }
    }


    override class func createCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: BubbleSelectCollectionView.catulateCellWidthBaseOnScreen(), height: 28)
        //        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        result.backgroundColor = UIColor.clear
        return result
    }

    func bindInputPanelObservable() {

        if let ds = self.priceDataSource() {
            //这里必须调用一下，是的inputHeaderView不为空
            let rate = self.dataSource.nodes.first?.rate ?? 1
            ds.inputHeaderView?.priceInputView.lowerPriceTextField.placeholder = "最低价格 (\(getRateTextByRateValue(rate)))"
            ds.inputHeaderView?.priceInputView.upperPriceTextField.placeholder = "最高价格 (\(getRateTextByRateValue(rate)))"

            ds.selectedIndexPaths
                .skip(1)
                .filter { $0.count != 0 }
                .bind { [unowned ds] set in
                    if let node = ds.selectedNodes().first, node.key != "rental_pay_period[]" {
                        ds.inputHeaderView?.priceInputView.upperPriceTextField.text = nil
                        ds.inputHeaderView?.priceInputView.upperPriceTextField.resignFirstResponder()
                        ds.inputHeaderView?.priceInputView.lowerPriceTextField.text = nil
                        ds.inputHeaderView?.priceInputView.lowerPriceTextField.resignFirstResponder()
                    }
                }.disposed(by: disposeBag)
        }

        if let ds = self.priceDataSource() {
            if let inputHeaderView = ds.inputHeaderView {
                Observable.combineLatest(inputHeaderView.priceInputView.upperPriceTextField.rx.text,
                                         inputHeaderView.priceInputView.lowerPriceTextField.rx.text)
                    .filter { !($0.0?.isEmpty ?? true) && !($0.1?.isEmpty ?? true) }
                    .debounce(0.2, scheduler: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [unowned self, unowned ds] s in
                        if ds.selectedIndexPaths.value.count > 0 && !ds.isOnlySelected(key: "rental_pay_period[]"){
                            ds.selectedIndexPaths.accept(ds.unselectedIndexsExportFor(key: "rental_pay_period[]"))
                            //                        ds.selectedIndexPaths.accept([])
                            if let collectionView = self.collectionView {
                                self.collectionView?.reloadItems(at: collectionView.indexPathsForVisibleItems)
                            }
                            ds.inputHeaderView?.priceInputView.upperPriceTextField.becomeFirstResponder()
                        }
                    })
                    .disposed(by: disposeBag)
            }


//            ds.inputHeaderView?.priceInputView.upperPriceTextField.rx.text
//                .filter { $0?.isEmpty == false }
//                .subscribeOn(MainScheduler.asyncInstance)
//                .subscribe(onNext: { [unowned self, unowned ds] s in
//                    if ds.selectedIndexPaths.value.count > 0 {
////                        ds.selectedIndexPaths.accept(ds.unselectedIndexsExportFor(key: "rental_pay_period[]"))
//                        print(ds.unselectedIndexsExportFor(key: "rental_pay_period[]"))
////                        ds.selectedIndexPaths.accept([])
//                        if let collectionView = self.collectionView {
//                            self.collectionView?.reloadItems(at: collectionView.indexPathsForVisibleItems)
//                        }
//                        ds.inputHeaderView?.priceInputView.upperPriceTextField.becomeFirstResponder()
//                    }
//                })
//                .disposed(by: disposeBag)
//            ds.inputHeaderView?.priceInputView.lowerPriceTextField.rx.text
//                .filter { $0?.isEmpty == false }
//                .subscribeOn(MainScheduler.asyncInstance)
//                .subscribe(onNext: { [unowned self, unowned ds] s in
//                    if ds.selectedIndexPaths.value.count > 0 {
//                        print(ds.unselectedIndexsExportFor(key: "rental_pay_period[]"))
////                        ds.selectedIndexPaths.accept(ds.unselectedIndexsExportFor(key: "rental_pay_period[]"))
////                        ds.selectedIndexPaths.accept([])
//                        if let collectionView = self.collectionView {
//                            self.collectionView?.reloadItems(at: collectionView.indexPathsForVisibleItems)
//                        }
//                        ds.inputHeaderView?.priceInputView.lowerPriceTextField.becomeFirstResponder()
//                    }
//                })
//                .disposed(by: disposeBag)
        }
        fillPriceInput?()
        fillPriceInput = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func onConfirm() {
        super.onConfirm()

        let sortedSelecteds = self.dataSource.selectedIndexPaths.value.sorted(by: { (left, right) -> Bool in
            if left.section < right.section {
                return true
            } else if left.section == right.section {
                return left.row <= right.row
            } else {
                return false
            }
        })
        let nodes = self.dataSource.nodes
        let datas = sortedSelecteds.map { path -> Node in
            nodes[path.section].children.filter { $0.isEmpty == 0 }[path.row]
        }
        if datas.isEmpty || priceDataSource()?.isOnlySelected(key: "rental_pay_period[]") ?? false {
            self.processUserInputPrice()
        } else {
            if let ds = priceDataSource() {
                ds.lowerInput = ""
                ds.upperInput = ""
            }
            self.didSelect?(datas)
        }
    }

    override func onClean() {
        super.onClean()
        priceDataSource()?.inputHeaderView?.priceInputView.upperPriceTextField.text = nil
        priceDataSource()?.inputHeaderView?.priceInputView.lowerPriceTextField.text = nil
        self.dataSource.selectedIndexPaths.accept([])
        self.collectionView?.reloadData()
        self.didSelect?([])
    }

    override func viewDidDisplay() {
        if let ds = self.priceDataSource() {
            ds.inputHeaderView?.priceInputView.lowerPriceTextField.text = ds.lowerInput
            ds.inputHeaderView?.priceInputView.upperPriceTextField.text = ds.upperInput
        }
    }

    override func viewDidDismiss() {
        super.viewDidDismiss()
        if let ds = self.priceDataSource() {
            ds.inputHeaderView?.priceInputView.lowerPriceTextField.resignFirstResponder()
            ds.inputHeaderView?.priceInputView.upperPriceTextField.resignFirstResponder()
        }
    }

    override func setSelectedConditions(conditions: [String : Any]) {
        super.setSelectedConditions(conditions: conditions)

        //如果没有匹配到列表页中的任何项，则将第一条数据填充到用户自定义输入中
        if self.dataSource.selectedIndexPaths.value.count == 0 ||
            dataSource.isOnlySelected(key: "rental_pay_period[]") {
            if let priceKey = (self.queryKey ?? "price").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                self.userInput = conditions[priceKey] as? [String]
                fillPriceInput = fillPriceByCondition(priceKey: priceKey, conditions: conditions)
                if self.priceDataSource()?.inputHeaderView != nil {
                    fillPriceInput?()
                    fillPriceInput = nil
                }
            }
        } else {
            let ds = priceDataSource()
            ds?.inputHeaderView?.priceInputView.lowerPriceTextField.text = nil
            ds?.inputHeaderView?.priceInputView.lowerPriceTextField.text = nil
            ds?.lowerInput = ""
            ds?.upperInput = ""
        }
    }

    func fillPriceByCondition(priceKey: String, conditions: [String : Any]) -> () -> Void {
        let rate = self.dataSource.nodes.first?.rate ?? 1
        let ds = priceDataSource()
        return { [weak ds, unowned self] in
            if let dds = ds {
                if let price = conditions[priceKey],
                    let priceString = (price as? [String])?.first,
                    let jsonData = priceString.data(using: .utf8),
                    let datas = try? JSONSerialization.jsonObject(with: jsonData) as? [Int] ?? [] {
                    if datas.count == 1 {
                        dds.inputHeaderView?.priceInputView.lowerPriceTextField.text = "\((datas.first ?? 0) / rate)"
                    } else if datas.count == 2 {
                        dds.inputHeaderView?.priceInputView.lowerPriceTextField.text = "\(datas[0] / rate)"
                        dds.inputHeaderView?.priceInputView.upperPriceTextField.text = "\(datas[1] / rate)"
                    }
                    if datas.count > 0 {
                        self.processUserInputPrice(updateFilterOnly: true)
                    } else {
                        self.didSelect?(self.dataSource.selectedNodes())
                    }
                }
            }
        }
    }

    func priceDataSource() -> PriceBubbleSelectDataSource? {
        return self.dataSource as? PriceBubbleSelectDataSource
    }

    override func selectedNodes() -> [Node] {
        self.dataSource.storeSelectedState()
        let selectedNodes = dataSource.selectedNodes()
        if selectedNodes.count == 0 || dataSource.isOnlySelected(key: "rental_pay_period[]") {
            // 再试着取一下用户手动输入是否有值
            let (low, upper) = getUserInputValue()
            let result = getUserInputPriceNode(low: low, upper: upper)
            return result + selectedNodes
        } else {
            return selectedNodes
        }
    }

    func getUserInputValue() -> (Int, Int) {
        let rate = self.dataSource.nodes.first?.rate ?? 1
        if let ds = priceDataSource(),
            let inputHeaderView = ds.inputHeaderView {
            let whitespace = NSCharacterSet.whitespacesAndNewlines
            let low = Int(inputHeaderView.priceInputView.lowerPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0
            let upper = Int(inputHeaderView.priceInputView.upperPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0
            return (low, upper)
        } else {
            if let userInput = self.userInput,
                let priceString = userInput.first,
                let jsonData = priceString.data(using: .utf8),
                let datas = try? JSONSerialization.jsonObject(with: jsonData) as? [Int] ?? [] {
                    if datas.count == 1 {
                        return ((datas.first ?? 0) / rate, 0)
                    } else if datas.count == 2 {
                        return (((datas[0] / rate)), ((datas[1] / rate)))
                    }
            }
        }
        return (0, 0)
    }

    func processUserInputPrice(updateFilterOnly: Bool = false) {
        if let ds = priceDataSource() {
            let whitespace = NSCharacterSet.whitespacesAndNewlines
            let low = Int(ds.inputHeaderView?.priceInputView.lowerPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0
            let upper = Int(ds.inputHeaderView?.priceInputView.upperPriceTextField.text?.trimmingCharacters(in: whitespace) ?? "0") ?? 0
            let nodes = self.selectedNodes()
            if updateFilterOnly {
                self.conditionLabelSetter?(nodes)
            } else {
                self.didSelect?(nodes)
            }
        }

    }

    func getUserInputPriceNode(low: Int, upper: Int) -> [Node] {

        if let ds = priceDataSource() {
            let rate = self.dataSource.nodes.first?.rate ?? 1
            let theQueryKey = self.queryKey ?? "price"
            if low == 0 && upper == 0 {
                ds.lowerInput = ""
                ds.upperInput = ""
                return []
            } else if low == 0 {
                ds.lowerInput = "\(low)"
                ds.upperInput = "\(upper)"
                return [Node(
                    id: "",
                    label: "\(upper)\(getRateTextByRateValue(rate))以下",
                    externalConfig: "\(theQueryKey)=[\(low * rate),\(upper * rate)]",
                    filterCondition: "[\(low * rate),\(upper * rate)" as Any,
                    key: "\(theQueryKey)")]
            } else if upper == 0 {
                ds.lowerInput = "\(low)"
                ds.upperInput = ""
                return [Node(
                    id: "",
                    label: "\(low)\(getRateTextByRateValue(rate))以上",
                    externalConfig: "\(theQueryKey)=[\(low * rate)]",
                    filterCondition: "[\(low * rate)]" as Any,
                    key: "\(theQueryKey)")]
            } else {
                let theLow = low < upper ? low : upper
                let theUpper = low < upper ? upper : low
                ds.lowerInput = "\(theLow)"
                ds.upperInput = "\(theUpper)"
                return [Node(
                    id: "",
                    label: "\(theLow)-\(theUpper)\(getRateTextByRateValue(rate))",
                    externalConfig: "\(theQueryKey)=[\(theLow * rate),\(theUpper * rate)]",
                    filterCondition: "[\(theLow * rate),\(theUpper * rate)" as Any,
                    key: "\(theQueryKey)")]
            }
        } else {
            return []
        }
    }



}

fileprivate func getRateTextByRateValue(_ rate: Int) -> String {
    if rate == 10000 {
        return "万"
    } else {
        return "元"
    }
}

class PriceBubbleSelectDataSource: BubbleSelectDataSource , UICollectionViewDelegateFlowLayout {

    var disposeBag = DisposeBag()

    weak var inputHeaderView: PriceBubbleCollectionSectionHeader?

    var lowerInput: String = ""

    var upperInput: String = ""

    var onHeaderViewInit: (() -> Void)?

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let theHeaderView = headerView as? PriceBubbleCollectionSectionHeader {
                inputHeaderView = theHeaderView
                theHeaderView.label.text = "\(nodes[indexPath.section].label)"
                if let theOnHeaderViewInit = onHeaderViewInit,
                    indexPath.section == 0 {
                    theOnHeaderViewInit()
                    onHeaderViewInit = nil
                }
            }
            return headerView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "default", for: indexPath)
            if let theHeaderView = headerView as? BubbleCollectionSectionHeader {
                theHeaderView.label.text = "\(nodes[indexPath.section].label)"
            }
            return headerView
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: 114)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 58)
        }
    }
}


class PriceBubbleCollectionSectionHeader: UICollectionReusableView {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#081f33")
        return result
    }()

    fileprivate lazy var priceInputView: PriceBottomInputView = {
        let re = PriceBottomInputView()
        return re
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(priceInputView)
        priceInputView.snp.makeConstraints { (maker) in
            maker.top.equalTo(20)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
        }

        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(priceInputView.snp.bottom).offset(20)
            maker.bottom.equalToSuperview().offset(-14)
            maker.right.equalTo(-20)
            maker.left.equalTo(20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func setInputViewHidden(isHidden: Bool) {
        priceInputView.isHidden = isHidden
        if isHidden {
            label.snp.remakeConstraints { (make) in
                make.top.equalTo(14)
                make.bottom.equalToSuperview().offset(-14)
                make.right.equalTo(-20)
                make.left.equalTo(20)
            }
        } else {
            label.snp.remakeConstraints { (make) in
                make.top.equalTo(priceInputView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().offset(-14)
                make.right.equalTo(-20)
                make.left.equalTo(20)
            }
        }
    }
}


fileprivate class PriceBottomInputView: UIView, UITextFieldDelegate {

    lazy var lowerPriceTextField: UITextField = {
        let re = UITextField()
        re.placeholder = "最低价格 (万)"
        re.textAlignment = .left
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        re.font = CommonUIStyle.Font.pingFangRegular(13)
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
        re.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textAlignment = .left
        re.layer.cornerRadius = 4
        re.keyboardType = .numberPad
        re.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        re.leftViewMode = .always
        re.delegate = self

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

        addSubview(priceInputBoard)
        priceInputBoard.snp.makeConstraints { maker in
            maker.top.bottom.left.equalToSuperview()
            maker.right.equalToSuperview()
        }


        priceInputBoard.addSubview(lowerPriceTextField)
        lowerPriceTextField.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.height.equalTo(36)
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
            maker.top.bottom.right.equalToSuperview()
            maker.height.equalTo(36)
            maker.width.greaterThanOrEqualTo(80)
        }


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
