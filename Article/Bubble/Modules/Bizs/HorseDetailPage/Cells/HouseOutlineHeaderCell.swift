//
//  HouseOutlineHeaderCell.swift
//  NewsLite
//
//  Created by 张元科 on 2018/11/7.
//

import UIKit
import SnapKit

class HouseOutlineHeaderCell: BaseUITableViewCell {
    
    open override class var identifier: String {
        return "HouseOutlineHeaderCell"
    }
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var infoButton: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "info-outline-material"), for: .normal)
        
        re.setTitle("举报", for: .normal)
        let attriStr = NSAttributedString(
            string: "举报",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(12) ,
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        return re
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(self).offset(-60)
            maker.top.equalTo(10)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview().offset(0)
        }
        
        contentView.addSubview(infoButton)
        
        infoButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(label)
            maker.right.equalTo(self).offset(-25)
        }
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

func parseHouseOutlineHeaderNode(
    _ title: String,
    filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        if let filter = filter, filter() == false {
            return nil
        } else {
            let cellRender = curry(fillHouseOutlineHeaderCell)(title)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: HouseOutlineHeaderCell.identifier))
        }
    }
}

func fillHouseOutlineHeaderCell(_ title: String, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? HouseOutlineHeaderCell {
        theCell.label.text = title
    }
}
