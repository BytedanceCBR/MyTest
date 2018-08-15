//
//  FlatGridCell.swift
//  Article
//
//  Created by leo on 2018/7/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
class FlatGridCell: BaseUITableViewCell {

    lazy var containerView: UIView = {
        let re = UIView()
        return re
    }()

    open override class var identifier: String {
        return "FlatGridCell"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.bottom.equalToSuperview()
        }
    }

    fileprivate func setGridItem(items: [ItemView]) {
        containerView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        items.forEach { view in
            containerView.addSubview(view)
        }
        items.snp.distributeSudokuViews(fixedLineSpacing: 7, fixedInteritemSpacing: 7, warpCount: 4)
    }

}

fileprivate class ItemView: UIView {

    var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textAlignment = .center
        re.textColor = hexStringToUIColor(hex: "#505050")
        return re
    }()

    var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.layer.cornerRadius = 4
        self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.top.equalTo(5)
            maker.bottom.equalTo(-5)
            maker.height.equalTo(20)
        }

        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate func fillItemView(
    _ items: [OpData.Item],
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    cell: BaseUITableViewCell) {
    if let theCell = cell as? FlatGridCell {
        let itemViews = items.map { item -> ItemView in
            let re = ItemView()
            re.label.text = item.title
            re.label.textColor = hexStringToUIColor(hex: item.textColor)
            if let backgroundColor = item.backgroundColor, !backgroundColor.isEmpty {
                re.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            }
            re.tapGesture.rx.event.subscribe(onNext: { (_) in
                if let openUrl = item.openUrl {
                    let theTraceParams = traceParams <|>
                        toTracerParams(item.title ?? "be_null", key: "operation_name") <|>
                        toTracerParams("maintab_operation", key: "element_from")
                    let paramsMap = theTraceParams.paramsGetter([:])
                    let userInfo = TTRouteUserInfo(info: paramsMap)
                    TTRoute.shared().openURL(byPushViewController: URL(string: openUrl), userInfo: userInfo)
                }
            }).disposed(by: disposeBag)
            return re
        }

        theCell.setGridItem(items: itemViews)
    }
}

func parseFlatOpNode(
    _ items: [OpData.Item],
    traceParams: TracerParams,
    disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillItemView)(items)(traceParams)(disposeBag)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: FlatGridCell.identifier))
    }
}
