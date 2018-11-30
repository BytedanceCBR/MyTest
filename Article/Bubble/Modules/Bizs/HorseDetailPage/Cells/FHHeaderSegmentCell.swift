//
//  FHHeaderSegmentCell.swift
//  Article
//
//  Created by 张静 on 2018/11/29.
//

import UIKit

class FHHeaderSegmentCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "FHHeaderSegmentCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview()
        }
        
        contentView.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { maker in
            maker.left.equalTo(titleLabel.snp.right).offset(20)
            maker.centerY.equalTo(titleLabel)
            maker.right.equalToSuperview().offset(-20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    private lazy var segmentControl: FWSegmentedControl = {
        let re = FWSegmentedControl.segmentedWith(
            scType: SCType.text,
            scWidthStyle: SCWidthStyle.dynamicFixedSuper,
            sectionTitleArray: nil,
            sectionImageArray: nil,
            sectionSelectedImageArray: nil,
            frame: CGRect.zero)
        re.selectionIndicatorHeight = 0
        
        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(14),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHCoolGrey3Color)]
        
        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangMedium(14),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHClearBlueColor)]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        
        return re
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

func parseHeaderSegmentNode(
    _ title: String,
    subTitle: String = "查看更多",
    showLoadMore: Bool = false,
    adjustBottomSpace: CGFloat = -20,
    process: TableCellSelectedProcess? = nil,
    filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        if let filter = filter, filter() == false {
            return nil
        } else {
            let cellRender = curry(fillHeaderCell)(title)(subTitle)(showLoadMore)(adjustBottomSpace)
            var selectors: [TableCellSelectedProcess] = []
            if process != nil {
                selectors.append(process!)
            }
            return TableSectionNode(
                items: [cellRender],
                selectors: selectors,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: FHHeaderSegmentCell.identifier))
        }
    }
}

func fillHeaderSegmentCell(_ title: String, subTitle: String, showLoadMore: Bool, adjustBottomSpace: CGFloat, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FHHeaderSegmentCell {
        theCell.titleLabel.text = title

    }
}

