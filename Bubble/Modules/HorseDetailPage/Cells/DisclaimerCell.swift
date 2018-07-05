//
//  DisclaimerCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class DisclaimerCell: BaseUITableViewCell {

    lazy var contentLabel: UILabel = {
        let re = UILabel()
        re.numberOfLines = 0
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.text = "本页面所含的信息来源于互联网公开信息，未经人工筛选/校对/核实，信息真实性，完整性请浏览者慎重查阅原始信息来源或链接，请阅读《法律与免责声明》。"
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview().offset(-14)
            maker.right.equalTo(-15)
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

}

func parseErshouHouseDisclaimerNode(_ data: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillDisclaimerCell)
        return TableSectionNode(items: [cellRender], label: "", type: .node(identifier: DisclaimerCell.identifier))
    }
}


func parseDisclaimerNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillDisclaimerCell)
        return TableSectionNode(items: [cellRender], label: "", type: .node(identifier: DisclaimerCell.identifier))
    }
}

func fillDisclaimerCell(cell: BaseUITableViewCell) -> Void {

}
