//
// Created by leo on 2018/8/7.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
class InformationCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "InformationCell"
    }

    lazy var infoLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(13)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.numberOfLines = 0
        return re
    }()

    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { maker in
            maker.height.equalTo(6)
            maker.left.right.bottom.equalToSuperview()
        }

        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(10)
            maker.bottom.equalTo(bottomLine.snp.top).offset(-10)
        }
        contentView.lu.addTopBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate func fillCell(content: String?, cell: BaseUITableViewCell) {
    if let theCell = cell as? InformationCell {
        theCell.infoLabel.text = content
    }
}

func parseInfoNode(_ content: String?) -> () -> TableSectionNode {
    return {
        let render = curry(fillCell)(content)
        return TableSectionNode(items: [render], selectors: [], label: "", type: .node(identifier: InformationCell.identifier))
    }
}
