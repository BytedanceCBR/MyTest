//
//  OpenAllCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class OpenAllCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "OpenAllCell"
    }

    lazy var openAllBtn: UIButton = {
        let result = UIButton()
        let attriStr = NSAttributedString(
                string: "查看更多 >",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16) ?? UIFont.systemFont(ofSize: 16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#222222")])
        result.setAttributedTitle(attriStr, for: .normal)
        result.backgroundColor = UIColor.white
        return result
    }()

    var disposeBag: DisposeBag?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        let maskView = UIView()
        contentView.addSubview(maskView)
        maskView.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-6)
        }

        maskView.addSubview(openAllBtn)
        maskView.lu.addTopBorder()
        openAllBtn.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
            maker.height.equalTo(48)
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
        disposeBag = nil
    }
}


func parseOpenAllNode(_ hasMore: Bool, callBack: @escaping () -> Void) -> () -> TableSectionNode {
    return {
        if hasMore {
            let cellRender = curry(fillOpenAllCell)(callBack)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: OpenAllCell.identifier))
        } else {
            return TableSectionNode(items: [], selectors: nil, label: "", type: .node(identifier: OpenAllCell.identifier))
        }
    }
}

func fillOpenAllCell(callBack: @escaping () -> Void, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? OpenAllCell {
        let disposeBag = DisposeBag()
        theCell.disposeBag = disposeBag
        theCell.openAllBtn.rx.tap
                .subscribe(onNext: callBack)
                .disposed(by: disposeBag)
    }
}
