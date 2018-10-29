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

func constructMoreSelectCollectionPanelWithContainer(
        index: Int,
        nodes: [Node],
        container: UIView,
        _ action: @escaping ConditionSelectAction) -> BaseConditionPanelView {
    let thePanel = BubbleSelectCollectionView(nodes: nodes)
    thePanel.isHidden = true
    container.addSubview(thePanel)
    thePanel.snp.makeConstraints { maker in
        maker.left.right.top.bottom.equalToSuperview()
    }
    thePanel.didSelect = { nodes in
        action(index, nodes)
    }
    
    thePanel.contentSizeDidChange = { size in
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

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: BubbleSelectCollectionView.catulateCellWidthBaseOnScreen(), height: 28)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        result.backgroundColor = UIColor.clear
        return result
    }()

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

    private class func catulateCellWidthBaseOnScreen() -> CGFloat {
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

    init(nodes: [Node]) {
        let dataSource = BubbleSelectDataSource(nodes: nodes)
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        setupUI()
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.reloadData()
    }

    init(
            dataSource: BubbleSelectDataSource,
            delegate: UICollectionViewDelegate) {
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        setupUI()
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
    }

    override func setSelectedConditions(conditions: [String : Any]) {
        dataSource.selectedIndexPaths = []
        collectionView.reloadData()
        let conditionStrArray = conditions
            .map { (e) -> [String] in
                convertKeyValueToCondition(key: e.key, value: e.value)
            }.reduce([]) { (result, nodes) -> [String] in
                result + nodes
        }
        dataSource.nodes
            .enumerated()
            .forEach { (offset, e) in
                e.children
                    .enumerated()
                    .forEach { (rowOffset, item) in
                        if let externalConfig = item.externalConfig.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                            conditionStrArray.contains(externalConfig) {
                            dataSource.selectedIndexPaths.insert(IndexPath(row: rowOffset, section: offset))
                        }
                }
        }
        self.didSelect?(self.dataSource.selectedNodes())
        self.dataSource.storeSelectedState()
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

        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.bottom.equalTo(inputBgView.snp.top)
        }
        collectionView.register(
                BubbleCollectionCell.self,
                forCellWithReuseIdentifier: "item")
        collectionView.register(
                BubbleCollectionSectionHeader.self,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "header")

        confirmBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.dataSource.storeSelectedState()
                    self.didSelect?(self.dataSource.selectedNodes())
                })
                .disposed(by: disposeBag)

        clearBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.dataSource.selectedIndexPaths = []
//                    self.didSelect?([])
                    self.collectionView.reloadData()
                })
                .disposed(by: disposeBag)
        
        
        collectionView.rx.observe(CGSize.self, "contentSize", options: .new, retainSelf: false)
            .subscribe(onNext: { [unowned self](size) in
                if let size = size {
                    self.contentSizeDidChange?(CGSize(width: size.width,height: size.height + 10.0 + 60.0)) // collection view height + vertical margin + input bg view
                }
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisplay() {
//        print("AreaConditionFilterPanel -> viewDidDisplay")
    }

    override func viewDidDismiss() {
//        print("AreaConditionFilterPanel -> viewDidDismiss")
        dataSource.restoreSelectedState()
        collectionView.reloadData()
    }
}

class BubbleSelectDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    var nodes: [Node] = []

    var originSelectIndexPaths: Set<IndexPath> = []

    fileprivate var selectedIndexPaths: Set<IndexPath> = []

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nodes.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes[section].children.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath)
        if let theCell = cell as? BubbleCollectionCell {
            theCell.label.text = nodes[indexPath.section].children[indexPath.row].label
            if selectedIndexPaths.contains(indexPath) {
                theCell.isSelected = true
            } else {
                theCell.isSelected = false
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if nodes[indexPath.section].isSupportMulti != true {
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths = selectedIndexPaths.filter { $0.section != indexPath.section }
            } else if selectedIndexPaths.contains(where: { $0.section == indexPath.section }) {
                selectedIndexPaths = selectedIndexPaths.filter { $0.section != indexPath.section }
                selectedIndexPaths.insert(indexPath)
            } else {
                selectedIndexPaths.insert(indexPath)
            }
        } else {
            if !selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.insert(indexPath)
            } else {
                selectedIndexPaths.remove(indexPath)
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
        let sortedSelecteds = selectedIndexPaths.sorted(by: { (left, right) -> Bool in
            if left.section < right.section {
                return true
            } else if left.section == right.section {
                return left.row <= right.row
            } else {
                return false
            }
        })
        return sortedSelecteds.map {
            nodes[$0.section].children[$0.row]
        }
    }

    func restoreSelectedState() {
        selectedIndexPaths = originSelectIndexPaths
    }

    func storeSelectedState() {
        originSelectIndexPaths = selectedIndexPaths
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

//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        //Exhibit A - We need to cache our calculation to prevent a crash.
//        if !isHeightCalculated {
//            setNeedsLayout()
//            layoutIfNeeded()
//            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//            var newFrame = layoutAttributes.frame
//            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//            layoutAttributes.frame = newFrame
//            isHeightCalculated = true
//        }
//        return layoutAttributes
//    }
}

class BubbleCollectionSectionHeader: UICollectionReusableView {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(18)
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

