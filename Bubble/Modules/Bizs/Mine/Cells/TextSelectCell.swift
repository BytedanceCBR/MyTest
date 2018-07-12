//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit


class TextRowCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "TextRowCell"
    }

    lazy var bgView: UIView = {
        let re = UIView()
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.top.equalTo(6)
            maker.left.right.equalToSuperview()
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setItem(items: [TextRowItemView]) {
        for v in contentView.subviews where v is TextRowItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            contentView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
        }
    }
}


class TextRowItemView: UIView {

    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangMedium(24)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.textAlignment = .left
        return result
    }()

    lazy var arrayIcon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "arrowicon-feed")
        return re
    }()

    lazy var labelIcon: UIImageView = {
        let re = UIImageView()
        return re
    }()

    init(image: UIImage, title: String) {
        super.init(frame: CGRect.zero)

        labelIcon.image = image
        addSubview(labelIcon)
        labelIcon.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.width.height.equalTo(24)
            maker.top.equalTo(13)
        }

        addSubview(arrayIcon)
        arrayIcon.snp.makeConstraints { maker in
            maker.right.equalTo(-14)
            maker.height.width.equalTo(14)
            maker.top.equalTo(17)
            maker.bottom.equalTo(-19)
        }

        label.text = title
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(14)
            maker.left.equalTo(labelIcon.snp.right).offset(12)
            maker.bottom.equalTo(-14)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseTextRowCell() -> () -> TableSectionNode? {
    let items: [TextRowItemView] = [
        TextRowItemView(image: #imageLiteral(resourceName: "icon-ershoufang"), title: "我的问答"),
        TextRowItemView(image: #imageLiteral(resourceName: "icon-xinfang"), title: "我的收藏"),
        TextRowItemView(image: #imageLiteral(resourceName: "icon-zufang"), title: "用户反馈"),
        TextRowItemView(image: #imageLiteral(resourceName: "icon-xiaoqu"), title: "系统设置"),
    ]
    return {
        let cellRender = curry(fillTextRowCell)(items)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: TextRowCell.identifier))
    }
}

fileprivate func fillTextRowCell(_ items: [TextRowItemView], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? TextRowCell {
        theCell.setItem(items: items)
    }
}
