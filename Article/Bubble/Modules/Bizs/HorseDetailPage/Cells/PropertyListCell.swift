//
//  PropertyListCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class PropertyListCell: BaseUITableViewCell, RefreshableTableViewCell {
    
    var refreshCallback: CellRefreshCallback?
    
    var isNeighborhoodInfoFold:Bool = true
    
    open override class var identifier: String {
        return "PropertyListCell"
    }

    lazy var wrapperView: UIView = {
        let re = UIView()
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // addBottomLine()

        contentView.addSubview(wrapperView)
        wrapperView.snp.makeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(-26)
            maker.left.right.equalToSuperview()
        }
        
        contentView.addSubview(bottomMaskView)
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

    override func prepareForReuse() {
        for v in wrapperView.subviews {
            v.removeFromSuperview()
        }
        resetListBottomView()
    }
    
    func removeListBottomView(_ heightOffset:CGFloat = -10, _ bottomMaskHidden:Bool = true) {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(heightOffset)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = bottomMaskHidden
    }
    
    func resetListBottomView()
    {
        wrapperView.snp.remakeConstraints { maker in
            maker.top.equalTo(2)
            maker.bottom.equalToSuperview().offset(-26)
            maker.left.right.equalToSuperview()
        }
        bottomMaskView.isHidden = false
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

fileprivate class TwoRowView: UIView {

}

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



func parsePropertyListNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        
        if let count = ershouHouseData.baseInfo?.count, count > 0 {
            
            let cellRender = curry(fillPropertyListCell)(ershouHouseData.baseInfo)(ershouHouseData.outLineOverreview != nil)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            
            return nil
        }
    }
}

func parseFloorPlanPropertyListNode(_ data: FloorPlanInfoData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillPropertyListCell)(data.baseInfo)(false)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
                tracer: nil,
            label: "",
            type: .node(identifier: PropertyListCell.identifier))
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



func fillPropertyListCell(_ infos: [ErshouHouseBaseInfo]?,_ hasOutLineInfo:Bool = false, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
        if hasOutLineInfo {
            theCell.removeListBottomView()
        }
        let groups: [[ErshouHouseBaseInfo]]? = infos?.reduce([[], []]) { (result, info) -> [[ErshouHouseBaseInfo]] in
            if info.isSingle == false {
                return [result[0] + [info], result[1]]
            } else {
                return [result[0], result[1] + [info]]
            }
        }

        if let groups = groups {

            func setRowValue(_ info: ErshouHouseBaseInfo, _ rowView: RowView) {
                rowView.keyLabel.text = info.attr
                rowView.valueLabel.text = info.value
            }

            var twoValueView: [UIView] = []
            groups[0].enumerated().forEach { (e) in
                let (offset, info) = e
                if offset % 2 == 0 {
                    let twoRow = TwoRowView()
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow.addSubview(row)
                    twoValueView.append(twoRow)
                } else {
                    let twoRow = twoValueView.last
                    let row = RowView()
                    setRowValue(info, row)
                    twoRow?.addSubview(row)
                }
            }

            twoValueView.forEach { view in
                view.subviews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
            }

            twoValueView.forEach { view in
                view.subviews.snp.makeConstraints { maker in
                    maker.top.bottom.equalToSuperview()
                    maker.height.equalTo(35)
                }
            }

            let singleViews = groups[1].map { (info) -> UIView in
                let re = RowView()
                setRowValue(info, re)
                return re
            }

            theCell.addRowView(rows: twoValueView + singleViews)
        }
    }
}

// 房源概况-info
fileprivate class HouseOutlineInfoView:UIView {
    
    lazy var iconImg: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "rectangle-11")
        return re
    }()
    
    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()
    
    lazy var valueLabel: UILabel = {
        let re = UILabel()
        re.numberOfLines = 0
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#737a80")
        re.textAlignment = .left
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(iconImg)
        addSubview(keyLabel)
        addSubview(valueLabel)
        
        iconImg.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.width.equalTo(10)
            maker.height.equalTo(8)
            maker.centerY.equalTo(keyLabel)
        }
        
        keyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconImg.snp.right).offset(4)
            maker.top.equalTo(10)
            maker.height.equalTo(26)
            maker.right.equalTo(self).offset(-20)
        }
        
        valueLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconImg)
            maker.right.equalTo(-20)
            maker.top.equalTo(keyLabel.snp.bottom).offset(2)
            maker.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


func parseHouseOutlineListNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        
        if let outline = ershouHouseData.outLineOverreview {
            
            let cellRender = curry(fillHouseOutlineListCell)(outline)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            
            return nil
        }
    }
}


func fillHouseOutlineListCell(_ outLineOverreview:ErshouOutlineOverreview, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
        theCell.removeListBottomView(-26, false)
        func setInfoValue(_ keyText: String, _ valueText: String, _ infoView: HouseOutlineInfoView) {
            infoView.keyLabel.text = keyText
            infoView.valueLabel.text = valueText
            infoView.valueLabel.sizeToFit()
        }
        
        let listView = outLineOverreview.list?.enumerated().map({ (e) -> HouseOutlineInfoView in
            let (_,outline) = e
            let re = HouseOutlineInfoView()
            setInfoValue(outline.title ?? "", outline.content ?? "", re)
            return re
        })
        
        theCell.addRowView(rows: listView ?? [], fixedSpacing: 4, averageLayout: false)
        
        if let count = listView?.count, count == 1 {
            listView![0].snp.remakeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
    }
}
