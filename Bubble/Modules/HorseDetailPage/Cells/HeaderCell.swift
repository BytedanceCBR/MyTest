//
//  HeaderCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class HeaderCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "HeaderCell"
    }

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var loadMore: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#707070")
        re.text = "查看更多"
        re.isHidden = true
        return re
    }()

    lazy var arrowsImg: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "arrowicon-feed")
        re.isHidden = true
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.height.equalTo(22)
            maker.bottom.equalToSuperview().offset(-16)
         }

        contentView.addSubview(arrowsImg)
        arrowsImg.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-9)
            maker.height.width.equalTo(18)
            maker.top.equalTo(18)
         }

        contentView.addSubview(loadMore)
        loadMore.snp.makeConstraints { maker in
            maker.top.equalTo(20)
            maker.height.equalTo(14)
            maker.width.equalTo(56)
            maker.right.equalTo(arrowsImg.snp.left)
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
        loadMore.isHidden = true
        arrowsImg.isHidden = true
    }
}

func parseTimeLineHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.timeLine?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("楼盘动态")(false)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseFloorPanHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.floorPan?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("楼盘户型")(false)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseCommentHeaderNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        if newHouseData.comment?.list?.count ?? 0 > 0 {
            let cellRender = curry(fillHeaderCell)("全网点评")(false)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: HeaderCell.identifier))
        } else {
            return nil
        }
    }
}

func parseHeaderNode(
        _ title: String,
        showLoadMore: Bool = false,
        filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        if let filter = filter, filter() == false {
            return nil
        } else {
            let cellRender = curry(fillHeaderCell)(title)(showLoadMore)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: HeaderCell.identifier))
        }
    }
}

func fillHeaderCell(_ title: String, showLoadMore: Bool, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? HeaderCell {
        theCell.label.text = title
        theCell.arrowsImg.isHidden = !showLoadMore
        theCell.loadMore.isHidden = !showLoadMore
    }
}
