//
//  BubbleSelectCollectionView.swift
//  Bubble
//
//  Created by linlin on 2018/6/20.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

func constructBubbleSelectCollectionPanel(_ action: @escaping ConditionSelectAction) -> ConditionFilterPanelGenerator {
    return { (index, container) in
        if let container = container {
            let panel = BubbleSelectCollectionView()
            container.addSubview(panel)
            panel.snp.makeConstraints { maker in
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(190)
            }
            panel.didSelect = { nodes in action(index, nodes) }
        }
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

    var dataSource: UICollectionViewDataSource

    var didSelect: (([Node]) -> Void)?

    init() {
        let dataSource = BubbleSelectDataSource(nodes: mockup())
        self.dataSource = dataSource
        super.init(frame: CGRect.zero)
        setupUI()
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.reloadData()
    }

    init(
            dataSource: UICollectionViewDataSource,
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

fileprivate func mockup() -> [Node] {
    let children = [Node(id: "", label: "一居", externalConfig: ""),
                    Node(id: "", label: "二居", externalConfig: ""),
                    Node(id: "", label: "二居", externalConfig: ""),
                    Node(id: "", label: "二居", externalConfig: ""),
                    Node(id: "", label: "二居", externalConfig: ""),
                    Node(id: "", label: "五居及以上", externalConfig: "")]
    return [Node(id: "", label: "户型选择", externalConfig: "", children: children)]
}
