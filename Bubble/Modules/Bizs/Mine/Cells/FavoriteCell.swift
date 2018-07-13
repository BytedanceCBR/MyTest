//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class FavoriteCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "FavoriteCell"
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

    fileprivate func setItem(items: [FavoriteItemView]) {
        for v in contentView.subviews where v is FavoriteItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            contentView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
    }
}


fileprivate class FavoriteItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#5050505")
        return re
    }()

    lazy var IconView: UIImageView = {
        let re = UIImageView()
        return re
    }()


    init(image: UIImage, title: String) {
        super.init(frame: CGRect.zero)

        IconView.image = image
        addSubview(IconView)
        IconView.snp.makeConstraints { maker in
            maker.width.height.equalTo(42)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(15)
        }

        keyLabel.text = title
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(IconView.snp.bottom).offset(9)
            maker.centerX.equalTo(IconView)
            maker.bottom.equalTo(-18)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseFavoriteNode() -> () -> TableSectionNode? {
    let items: [FavoriteItemView] = [
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-ershoufang"), title: "二手房"),
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-xinfang"), title: "新房"),
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-zufang"), title: "租房"),
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-xiaoqu"), title: "小区"),
    ]
    return {
        let cellRender = curry(fillFavoriteCell)(items)
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: FavoriteCell.identifier))
    }
}

fileprivate func fillFavoriteCell(_ items: [FavoriteItemView], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FavoriteCell {
        theCell.setItem(items: items)
    }
}
