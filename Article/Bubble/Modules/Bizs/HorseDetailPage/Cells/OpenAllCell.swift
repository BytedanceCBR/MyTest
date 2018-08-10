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
        return result
    }()

    lazy var title: UILabel = {
        let re = UILabel()
        let attriStr = NSMutableAttributedString(
                string: "查看更多",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#222222")])

        re.backgroundColor = UIColor.white
        re.attributedText = attriStr
        return re
    }()

    lazy var bottomMaskView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    lazy var settingArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "setting-arrow-1")
        return re
    }()

    var disposeBag: DisposeBag?


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(6)
        }

        contentView.addSubview(openAllBtn)
        openAllBtn.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(6)
            maker.bottom.equalTo(bottomMaskView.snp.top).offset(-6)
        }

        contentView.addSubview(title)
        title.snp.makeConstraints { maker in
            maker.center.equalTo(openAllBtn)
        }

        contentView.addSubview(settingArrowImageView)
        settingArrowImageView.snp.makeConstraints { maker in
            maker.height.equalTo(8)
            maker.width.equalTo(6)
            maker.centerY.equalTo(openAllBtn.snp.centerY)
            maker.left.equalTo(title.snp.right).offset(6)
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

    func setIsShowBottomBar(isHsowBottomBar: Bool) {
        bottomMaskView.snp.updateConstraints { maker in
            if isHsowBottomBar {
                maker.height.equalTo(6)
            } else {
                maker.height.equalTo(0)
            }
        }
    }

}


func parseOpenAllNode(
        _ hasMore: Bool,
        isShowBottomBar: Bool = true,
        callBack: @escaping () -> Void) -> () -> TableSectionNode {
    return {
        if hasMore {
            let cellRender = curry(fillOpenAllCell)(isShowBottomBar)(callBack)
            return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: OpenAllCell.identifier))
        } else {
            return TableSectionNode(items: [], selectors: nil, label: "", type: .node(identifier: OpenAllCell.identifier))
        }
    }
}

func fillOpenAllCell(
    isShowBottomBar: Bool = true,
    callBack: @escaping () -> Void,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? OpenAllCell {
        theCell.setIsShowBottomBar(isHsowBottomBar: isShowBottomBar)
        let disposeBag = DisposeBag()
        theCell.disposeBag = disposeBag
        theCell.openAllBtn.rx.tap
                .subscribe(onNext: callBack)
                .disposed(by: disposeBag)
    }
}
