//
//  GridOpBoardCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
class GridOpBoardCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "GridOpBoardCell"
    }

    fileprivate lazy var grids: [GridView] = {
        (0...3).map({ (_) -> GridView in
            GridView()
        })
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let gridView = grids[0]
        contentView.addSubview(gridView)
        gridView.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.bottom.equalToSuperview()
            maker.height.equalTo(180)
            if UIScreen.main.bounds.width > 320 {
                maker.width.equalTo(140)
            } else {
                maker.width.equalTo(110)
            }
        }

        let secondView = grids[1]
        contentView.addSubview(secondView)
        secondView.snp.makeConstraints { maker in
            maker.left.equalTo(gridView.snp.right).offset(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(75)
            maker.top.equalToSuperview()
         }

        let thirdView = grids[2]
        contentView.addSubview(thirdView)
        thirdView.snp.makeConstraints { maker in
            maker.top.equalTo(secondView.snp.bottom).offset(10)
            maker.left.equalTo(gridView.snp.right).offset(10)
            maker.height.equalTo(95)
            maker.bottom.equalToSuperview()
            maker.right.equalTo(secondView.snp.centerX).offset(-5)
        }

        let lastView = grids[3]
        contentView.addSubview(lastView)
        lastView.snp.makeConstraints { maker in
            maker.left.equalTo(thirdView.snp.right).offset(10)
            maker.top.equalTo(secondView.snp.bottom).offset(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(95)
            maker.bottom.equalToSuperview()
         }
    }
}

fileprivate class GridView: UIView {

    lazy var bgImage: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var name: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var desc: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        re.textColor = hexStringToUIColor(hex: "#707070")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(bgImage)
        bgImage.snp.makeConstraints { maker in
            maker.top.right.left.bottom.equalToSuperview()
        }

        addSubview(name)
        name.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(18)
        }

        addSubview(desc)
        desc.snp.makeConstraints { maker in
            maker.top.equalTo(name.snp.bottom)
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(14)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseGridOpNode(_ items: [OpData.Item], disposeBag: DisposeBag) -> () -> TableSectionNode? {
    assert(items.count == 4)
    if items.count >= 4 {
        let its = items.take(4)
        return {
            let cellRender = curry(fillGridOpCell)(its)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: GridOpBoardCell.identifier))
        }
    } else {
        return { nil }
    }

}

fileprivate func fillGridOpCell(_ items: [OpData.Item], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? GridOpBoardCell {
        if items.count >= 4 {
            theCell.grids.enumerated().forEach { e in
                let (index, view) = e
                if let urlStr = items[index].image.first?.url, let url = URL(string: urlStr) {
                    view.bgImage.bd_setImage(with: url)
                }
                view.name.text = items[index].title
                view.desc.text = items[index].description
            }
        }
    }
}
