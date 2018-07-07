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

func constructBubbleSelectCollectionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    var thePanel: BubbleSelectCollectionView? = nil
    return { (index, container) in
        if let container = container {
            if thePanel == nil {
                thePanel = BubbleSelectCollectionView(nodes: nodes)
            }
            container.addSubview(thePanel!)
            thePanel?.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(190)
            }
            thePanel?.didSelect = { nodes in
                action(index, nodes)
            }
        }
    }
}

func parseHorseTypeConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    if nodePath.count > 1 {
        return .condition("户型 (多选)")
    } else if nodePath.count == 1 {
        return .condition(nodePath.first!.label)
    } else {
        return .noCondition("户型")
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

func constructMoreSelectCollectionPanel(nodes: [Node], _ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    var thePanel: BubbleSelectCollectionView? = nil
    return { (index, container) in
        if let container = container {
            if thePanel == nil {
                thePanel = BubbleSelectCollectionView(nodes: nodes)
            }
            container.addSubview(thePanel!)
            thePanel?.snp.makeConstraints { maker in
                maker.left.right.top.bottom.equalToSuperview()
            }
            thePanel?.didSelect = { nodes in
                action(index, nodes)
            }
        }
    }
}

func parseMoreConditionItemLabel(nodePath: [Node]) -> ConditionItemType {
    if nodePath.count > 1 {
        return .condition("更多 (多选)")
    } else if nodePath.count == 1 {
        return .condition(nodePath.first!.label)
    } else {
        return .noCondition("更多")
    }
}

class BubbleSelectCollectionView: UIView {

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: BubbleSelectCollectionView.catulateCellWidthBaseOnScreen(), height: 28)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        result.backgroundColor = UIColor.clear
        return result
    }()

    lazy var clearBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.white
        result.lu.addTopBorder(color: hexStringToUIColor(hex: "#f4f5f6"))

        result.setTitle("不限条件", for: .normal)
        result.setTitleColor(hexStringToUIColor(hex: "#222222"), for: .normal)
        return result
    }()

    lazy var confirmBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = hexStringToUIColor(hex: "#f85959")
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

    func setupUI() {
        backgroundColor = UIColor.white

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

        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalTo(24)
            maker.right.equalToSuperview().offset(-24)
            maker.bottom.equalTo(clearBtn.snp.top)
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
                    self.didSelect?(self.dataSource.selectedNodes())
                })
                .disposed(by: disposeBag)

        clearBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.dataSource.selectedIndexPaths = []
                    self.didSelect?([])
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BubbleSelectDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    var nodes: [Node] = []

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
            selectedIndexPaths = selectedIndexPaths.filter { $0.section != indexPath.section }
        }

        if !selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
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
        return selectedIndexPaths.map {
            nodes[$0.section].children[$0.row]
        }
    }
}

fileprivate class BubbleCollectionCell: UICollectionViewCell {

    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
    fileprivate override var isSelected: Bool {
        didSet {
            configSelectedStyle(isSelected: isSelected)
        }
    }
    lazy var label: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.highlightedTextColor = hexStringToUIColor(hex: "#f85959")
        result.adjustsFontSizeToFitWidth = true
        result.font = CommonUIStyle.Font.pingFangRegular(14)
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
            contentView.layer.masksToBounds = true
            contentView.layer.borderWidth = 0.5
            contentView.layer.borderColor = hexStringToUIColor(hex: "#f85959").cgColor
            contentView.layer.cornerRadius = 4
            contentView.backgroundColor = UIColor.white
        } else {
            contentView.layer.masksToBounds = false
            contentView.layer.cornerRadius = 4
            contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
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

fileprivate class BubbleCollectionSectionHeader: UICollectionReusableView {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.right.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

