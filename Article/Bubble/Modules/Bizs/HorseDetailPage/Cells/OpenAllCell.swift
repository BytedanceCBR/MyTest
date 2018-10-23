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

class FGrayLineCell: BaseUITableViewCell {
    
    open override class var identifier: String {
        return "FGrayLineCell"
    }
    
    lazy var bottomMaskView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.height.equalTo(0)
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

    func setBarHeight(_ height: CGFloat) {
        bottomMaskView.snp.updateConstraints { maker in
            maker.height.equalTo(height)
        }
    }
    
}

func fillFGrayLineCell(
    barHeight: CGFloat = 6,
    bgColor: UIColor = hexStringToUIColor(hex: "#f4f5f6"),
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FGrayLineCell {
        theCell.setBarHeight(barHeight)
        theCell.bottomMaskView.backgroundColor = bgColor
        theCell.bottomMaskView.snp.updateConstraints { (maker) in
            
            maker.left.equalTo(0)
            maker.right.equalTo(0)
        }
    }
}

func fillFMarginGrayLineCell(
    barHeight: CGFloat = 6,
    bgColor: UIColor = hexStringToUIColor(hex: "#f4f5f6"),
    left: CGFloat = 0,
    right: CGFloat = 0,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FGrayLineCell {
        theCell.setBarHeight(barHeight)
        theCell.bottomMaskView.backgroundColor = bgColor
        theCell.bottomMaskView.snp.updateConstraints { (maker) in
            
            maker.left.equalTo(left)
            maker.right.equalTo(right)
        }
    }
}


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
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHDarkIndigoColor)])

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
        re.image = #imageLiteral(resourceName: "setting-arrow")
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
            maker.centerX.equalTo(openAllBtn).offset(-9)
            maker.centerY.equalTo(openAllBtn)

        }

        contentView.addSubview(settingArrowImageView)
        settingArrowImageView.snp.makeConstraints { maker in
            maker.height.equalTo(14)
            maker.width.equalTo(14)
            maker.centerY.equalTo(openAllBtn.snp.centerY)
            maker.left.equalTo(title.snp.right).offset(4)
         }

        contentView.lu.addTopBorder()

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
        _ moreText: String? = "查看更多",
        isShowBottomBar: Bool = true,
        barHeight: CGFloat = 0,
        bgColor: UIColor = hexStringToUIColor(hex: "#f4f5f6"),
        callBack: @escaping () -> Void) -> () -> TableSectionNode {
    return {
        if hasMore {
            let cellRender = curry(fillOpenAllCell)(isShowBottomBar)(moreText)(callBack)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                    tracer: nil,
                label: "",
                type: .node(identifier: OpenAllCell.identifier))
        } else if barHeight > 0 {
            let cellRender = curry(fillFGrayLineCell)(barHeight)(bgColor)
            return TableSectionNode(
                    items: [cellRender],
                    selectors: nil,
                    tracer: nil,
                    label: "",
                    type: .node(identifier: FGrayLineCell.identifier))
        }else {
            return TableSectionNode(
                items: [],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FGrayLineCell.identifier))
        }
    }
}

func parseFlineNode(
    _ barHeight: CGFloat = 6,
    bgColor: UIColor = hexStringToUIColor(hex: "#f4f5f6")) -> () -> TableSectionNode {
    return {
        if barHeight > 0 {
            let cellRender = curry(fillFGrayLineCell)(barHeight)(bgColor)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FGrayLineCell.identifier))
        }else {
            return TableSectionNode(
                items: [],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FGrayLineCell.identifier))
        }
    }
}

func parseFMarginLineNode(
    _ barHeight: CGFloat = 6,
    bgColor: UIColor = hexStringToUIColor(hex: "#f4f5f6"),
    left: CGFloat = 0,
    right: CGFloat = 0) -> () -> TableSectionNode {
    return {
        if barHeight > 0 {
            let cellRender = curry(fillFMarginGrayLineCell)(barHeight)(bgColor)(left)(right)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FGrayLineCell.identifier))
        }else {
            return TableSectionNode(
                items: [],
                selectors: nil,
                tracer: nil,
                label: "",
                type: .node(identifier: FGrayLineCell.identifier))
        }
    }
}

func fillOpenAllCell(
    isShowBottomBar: Bool = true,
    _ moreText: String? = "查看更多",
    callBack: @escaping () -> Void,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? OpenAllCell {
        theCell.setIsShowBottomBar(isHsowBottomBar: isShowBottomBar)
        let disposeBag = DisposeBag()
        theCell.disposeBag = disposeBag
        
        let attriStr = NSMutableAttributedString(
            string: moreText ?? "查看更多",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHDarkIndigoColor)])
        theCell.backgroundColor = UIColor.white
        theCell.title.attributedText = attriStr
        
        theCell.openAllBtn.rx.tap
                .subscribe(onNext: callBack)
                .disposed(by: disposeBag)
    }
}
