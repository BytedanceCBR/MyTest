//
//  NeighborhoodPropertyInfoCell.swift
//  Article
//
//  Created by 张元科 on 2018/11/19.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

// 小区概况（折叠动画）
class NeighborhoodPropertyInfoCell :  BaseUITableViewCell, RefreshableTableViewCell {
    var refreshCallback: CellRefreshCallback?
    
    var isNeighborhoodInfoFold:Bool = true {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    let disposeBag:DisposeBag = DisposeBag()
    
    override open class var identifier: String {
        return "NeighborhoodPropertyInfoCell"
    }
    
    lazy var headListView: PropertyListView = {
        let view = PropertyListView()
        return view
    }()
    
    lazy var bottomListView: PropertyListView = {
        let view = PropertyListView()
        return view
    }()
    
    lazy var bottomBgView: UIView = {
        let view = UIView()
        return view
    }()
    
    let foldButton = CommonFoldViewButton(downText: "查看全部信息", upText: "收起")
    
    let itemCellHeight:CGFloat = 30.0
    
    var headerListCount:Int = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    var bottomListCount:Int = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(headListView)
        headListView.removeListBottomView(0, true)
        self.contentView.addSubview(bottomBgView)
        bottomBgView.clipsToBounds = true
        bottomBgView.addSubview(bottomListView)
        bottomListView.removeListBottomView(0, true)
        bottomBgView.addSubview(foldButton)
        foldButton.backgroundColor = UIColor.white
        foldButton.isFold = self.isNeighborhoodInfoFold
        
        foldButton.rx.tap
            .bind(onNext: { [weak self, weak foldButton] () in
                self?.refreshCell()
                foldButton?.isFold = self?.isNeighborhoodInfoFold ?? true
            })
            .disposed(by: disposeBag)
    }
    
    override func updateConstraints() {
        
        headListView.snp.remakeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(CGFloat(headerListCount) * itemCellHeight)
        }
        
        let count = isNeighborhoodInfoFold ? 0 : bottomListCount
        
        bottomBgView.snp.remakeConstraints { maker in
            maker.top.equalToSuperview().offset(CGFloat(headerListCount) * itemCellHeight)
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(CGFloat(count) * itemCellHeight + 58)
        }
        
        bottomListView.snp.remakeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(CGFloat(bottomListCount) * itemCellHeight)
        }
        foldButton.snp.remakeConstraints { (maker) in
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalTo(58)
        }
        super.updateConstraints()
    }
}

// 子View列表容器
class PropertyListView: UIView {
    
    lazy var wrapperView: UIView = {
        let re = UIView()
        return re
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { maker in
            maker.top.equalTo(0)
            maker.bottom.equalToSuperview().offset(-26)
            maker.left.right.equalToSuperview()
        }
        
        self.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(6)
        }
    }
    
    lazy var bottomMaskView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addRowView(rows: [UIView], fixedSpacing:CGFloat = 0, averageLayout: Bool = true ) {
        for v in wrapperView.subviews {
            v.removeFromSuperview()
        }
        
        rows.forEach { view in
            wrapperView.addSubview(view)
        }
        rows.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: fixedSpacing, averageLayout:averageLayout)
        rows.snp.makeConstraints { maker in
            maker.width.equalToSuperview()
            maker.left.right.equalToSuperview()
        }
    }
    
    func prepareForReuse() {
        for v in wrapperView.subviews {
            v.removeFromSuperview()
        }
        resetListBottomView()
    }
    
    func removeListBottomView(_ heightOffset:CGFloat = -10, _ bottomMaskHidden:Bool = true) {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(0)
            maker.bottom.equalToSuperview().offset(heightOffset)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = bottomMaskHidden
    }
    
    func resetListBottomView()
    {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(0)
            maker.bottom.equalToSuperview().offset(-26)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = false
    }
}

class CommonFoldViewButton:UIButton {
    
    lazy var iconView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-feed-2")
        return re
    }()
    
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.text = ""
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#299cff")
        return re
    }()
    
    var upText:String = "收起"
    var downText:String = "展开"
    
    var isFold:Bool = true {
        didSet {
            if isFold {
                keyLabel.text = self.downText
                iconView.image = UIImage(named: "arrowicon-feed-3")
            } else {
                keyLabel.text = self.upText
                iconView.image = UIImage(named: "arrowicon-feed-2")
            }
        }
    }
    
    init(downText:String, upText:String) {
        self.upText = upText
        self.downText = downText
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    func setupUI()
    {
        addSubview(keyLabel)
        addSubview(iconView)
        
        keyLabel.snp.makeConstraints { maker in
            maker.centerX.equalTo(self).offset(-11)
            maker.top.equalTo(self).offset(20)
            maker.height.equalTo(18)
        }
        
        iconView.snp.makeConstraints { maker in
            maker.left.equalTo(keyLabel.snp.right).offset(4)
            maker.centerY.equalTo(keyLabel)
            maker.height.width.equalTo(18)
        }
        self.isFold = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class RowView: UIView {
    
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        return re
    }()
    
    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        re.textAlignment = .left
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        addSubview(keyLabel)
        addSubview(valueLabel)
        
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(keyLabel.snp.right).offset(10)
            maker.right.equalTo(-25)
            maker.top.equalTo(14)
            maker.bottom.equalTo(keyLabel)
        }
    }
    // 小区详情页布局
    func remakeValueLabelConstraints() {
        
        keyLabel.snp.remakeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(10)
            maker.height.equalTo(20)
            maker.bottom.equalToSuperview()
        }
        valueLabel.snp.remakeConstraints { maker in
            maker.left.equalToSuperview().offset(96)
            maker.right.equalToSuperview().offset(-25)
            maker.top.equalToSuperview().offset(10)
            maker.height.equalTo(20)
            maker.bottom.equalTo(keyLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseNeighborhoodPropertyListNode(_ data: NeighborhoodDetailData, traceExtension: TracerParams = TracerParams.momoid(), disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        
        let params = TracerParams.momoid() <|>
            toTracerParams("neighborhood_info", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
        traceExtension
        
        if let count = data.baseInfo?.count, count > 0 {
            let cellRender = curry(fillNeighborhoodPropertyListCell)(data.baseInfo)(disposeBag)
            return TableSectionNode(
                items: [oneTimeRender(cellRender)],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: NeighborhoodPropertyInfoCell.identifier))
        }else {
            return nil
        }
    }
}

func fillNeighborhoodPropertyListCell(_ infos: [NeighborhoodItemAttribute]?, disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodPropertyInfoCell {
        if let groups = infos {
            func setRowValue(_ info: NeighborhoodItemAttribute, _ rowView: RowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }
            
            var singleViews = groups.map { (info) -> UIView in
                let re = RowView()
                setRowValue(info, re)
                re.remakeValueLabelConstraints()
                return re
            }
            
            let headVeiws = singleViews.take(4)
            theCell.headListView.addRowView(rows: headVeiws)
            //            headVeiws
            theCell.headerListCount = headVeiws.count
            if singleViews.count > 4 {
                singleViews.removeFirst(4)
                theCell.bottomListView.addRowView(rows: singleViews)
                theCell.bottomListCount = singleViews.count
            } else {
                theCell.bottomListCount = 0
            }
            theCell.updateConstraintsIfNeeded()
        }
    }
}
