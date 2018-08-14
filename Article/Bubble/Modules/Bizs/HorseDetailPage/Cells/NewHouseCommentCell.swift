//
//  NewHouseCommentCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
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
        re.numberOfLines = 2
        re.textColor = hexStringToUIColor(hex: "#222222")
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
        re.textColor = hexStringToUIColor(hex: "#999999")
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
            maker.width.equalTo(100)
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

    func setContent(content: String, isExpand: Bool) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let attrText = NSMutableAttributedString(
            string: content,
            attributes: [.font: CommonUIStyle.Font.pingFangRegular(16),
                         .foregroundColor: hexStringToUIColor(hex: "#222222"),
                         .paragraphStyle: style])
        contentLabel.attributedText = attrText
        if isExpand {
            contentLabel.numberOfLines = 0
        }
//        re.font = CommonUIStyle.Font.pingFangRegular(16)
//        re.textColor = hexStringToUIColor(hex: "#222222")
    }
}

func parseNewHouseCommentNode(_ newHouseData: NewHouseData, processor: @escaping TableCellSelectedProcess) -> () -> TableSectionNode {
    return {

        let renders = newHouseData.comment?.list?.map(curry(fillNewHouseCommentCell)).map { $0(false) }
        var selectors:[TableCellSelectedProcess]?
        if let list = newHouseData.comment?.list {

            selectors = list.map { _ in processor }
        }

        return TableSectionNode(items: renders ?? [],
                                selectors: selectors,
                                label: "全网点评",
                                type: .node(identifier: NewHouseCommentCell.identifier))

    }
}

func fillNewHouseCommentCell(
    _ data: NewHouseComment.Item,
    isExpand: Bool = false,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseCommentCell {
        theCell.fromLabel.text = "来自\(data.source ?? "")"
        
        theCell.dateTiemLabel.text = CommonUIStyle.DateTime.dateFormat.string(from: Date(timeIntervalSince1970: TimeInterval(data.createTime ?? 0)))
        if let content = data.content {
            theCell.setContent(content: content, isExpand: isExpand)
        }
    }
}

func parseNewHouseCommentNode(_ items: [NewHouseComment.Item]) -> () -> [TableRowNode] {
    return {
        let renders = items.map(curry(fillNewHouseCommentCell)).map({ (render) -> TableRowNode in
            TableRowNode(
                itemRender: render(true),
                selector: nil,
                type: .node(identifier: NewHouseCommentCell.identifier),
                editor: nil)
        })
        return renders
    }
}
