//
//  NewHouseCommentCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import BDWebImage
import SnapKit

class NewHouseCommentCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NewHouseCommentCell"
    }

    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "36")
        return re
    }()

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangSemibold(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.text = "用户*****"
        return re
    }()

    lazy var contentLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.numberOfLines = 2
        return re
    }()

    lazy var showAllBtn: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        re.isHidden = true
        return re
    }()

    lazy var dateTiemLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textColor = hexStringToUIColor(hex: "#707070")
        re.textAlignment = .left
        return re
    }()

    lazy var fromLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textColor = hexStringToUIColor(hex: "#707070")
        re.textAlignment = .right
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(icon)
        icon.snp.makeConstraints { maker in
            maker.left.top.equalTo(13)
            maker.height.width.equalTo(40)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(icon.snp.centerY)
            maker.left.equalTo(icon.snp.right).offset(8)
            maker.right.equalToSuperview().offset(-15)
        }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(icon.snp.bottom).offset(8)
            maker.right.equalToSuperview().offset(-15)
        }

        contentView.addSubview(showAllBtn)

        contentView.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalTo(contentLabel.snp.bottom).offset(16)
            maker.bottom.equalToSuperview().offset(-15)
        }

        contentView.addSubview(dateTiemLabel)
        dateTiemLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(contentLabel.snp.bottom).offset(16)
            maker.right.equalTo(fromLabel.snp.left)
            maker.bottom.equalToSuperview().offset(-15)
            maker.width.equalTo(89)
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
        showAllBtn.isHidden = true
    }
}

func parseNewHouseCommentNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let renders = newHouseData.comment?.list?.map(curry(fillNewHouseCommentCell))
        return TableSectionNode(items: renders ?? [], label: "全网点评", type: .node(identifier: NewHouseCommentCell.identifier))
    }
}

func fillNewHouseCommentCell(_ data: NewHouseComment.Item, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseCommentCell {
        theCell.contentLabel.text = data.content
        theCell.fromLabel.text = data.source
    }
}
