//
//  AgentListCell.swift
//  Article
//
//  Created by leo on 2019/1/2.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
fileprivate class ExpandItemView: UIView {

    private var itemViews: [ItemView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

    }

    func addItems(items: [ItemView]) {
        itemViews.forEach { (view) in
            view.removeFromSuperview()
        }

        itemViews = items
        layoutItems()
    }

    private func layoutItems() {
        itemViews.forEach { (view) in
            self.addSubview(view)
        }

        if itemViews.count == 1, let itemView = itemViews.first {
            itemView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else if itemViews.count > 1 {
            itemViews.snp.distributeViewsAlong(axisType: .vertical,
                                               fixedSpacing: 0,
                                               averageLayout: true,
                                               leadSpacing: 0,
                                               tailSpacing: 0)
            itemViews.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
            }
        }
    }

}

fileprivate class ItemView: UIView {

    lazy var avator: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFit
        re.clipsToBounds = true
        re.image = #imageLiteral(resourceName: "default-avatar-icons")
        return re
    }()

    lazy var licenceIcon: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "contact"), for: .normal)
        return re
    }()

    lazy var callBtn: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "icon-phone"), for: .normal)
        return re
    }()

    lazy var name: UILabel = {
        let re = UILabel()
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "081f33")
        return re
    }()

    lazy var agency: UILabel = {
        let re = UILabel()
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "a1aab3")
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.addSubview(avator)
        self.addSubview(name)
        self.addSubview(agency)
        self.addSubview(licenceIcon)
        self.addSubview(callBtn)

        avator.snp.makeConstraints { (make) in
            make.height.width.equalTo(46)
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }

        name.snp.makeConstraints { (make) in
            make.left.equalTo(avator.snp.right).offset(14)
            make.top.equalTo(avator).offset(4)
            make.height.equalTo(22)
        }

        agency.snp.makeConstraints { (make) in
            make.top.equalTo(name.snp.bottom)
            make.height.equalTo(20)
            make.left.equalTo(avator.snp.right).offset(14)
            make.right.lessThanOrEqualTo(callBtn.snp.left)
        }

        licenceIcon.snp.makeConstraints { (make) in
            make.left.equalTo(name.snp.right).offset(4)
            make.height.width.equalTo(20)
            make.centerY.equalTo(name)
            make.right.lessThanOrEqualTo(callBtn.snp.left)
        }

        callBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(-20)
            make.centerY.equalTo(avator)
        }
    }
}

class FHAgentListCell: BaseUITableViewCell, RefreshableTableViewCell {
    var refreshCallback: CellRefreshCallback?

    var disposeBag = DisposeBag()

    var isExpanding = false

    lazy var phoneCallViewModel: FHPhoneCallViewModel = {
        let re = FHPhoneCallViewModel()
        return re
    }()

    private var itemCount = 0

    fileprivate lazy var expandItemView: ExpandItemView = {
        let re = ExpandItemView(frame: CGRect.zero)
        return re
    }()

    lazy var expandBtnView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()

    lazy var arrowIcon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-feed-2")
        return re
    }()

    lazy var expandBtn: UIButton = {
        let re = UIButton()
        return re
    }()

    lazy var expandLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "299cff")
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.text = "展开查看全部"
        return re
    }()

    lazy var containerView: UIView = {
        let re = UIView()
        re.clipsToBounds = true
        return re
    }()

    open override class var identifier: String {
        return "FHAgentListCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(containerView)
        contentView.addSubview(expandBtnView)
        contentView.addSubview(expandBtn)

        containerView.addSubview(expandItemView)
        expandBtnView.addSubview(arrowIcon)
        expandBtnView.addSubview(expandLabel)
        expandBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(expandBtnView)
        }
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        expandItemView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    fileprivate func addItems(items: [ItemView]) {
        itemCount = items.count
        expandItemView.addItems(items: items)
        if items.count > 3 {
            self.setupExpaneView()
        }
    }

    fileprivate func setupExpaneView() {
        expandItemView.snp.remakeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }
        containerView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(expandBtnView.snp.top)
            make.top.left.right.equalToSuperview()
            make.height.equalTo(66 * 3)
        }
        expandBtnView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(58)
        }

        expandLabel.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.left.equalToSuperview()
            make.top.equalTo(20)
            make.right.equalTo(arrowIcon.snp.left)
        }

        arrowIcon.snp.makeConstraints { (make) in
            make.height.width.equalTo(18)
            make.centerY.equalTo(expandLabel)
            make.right.equalToSuperview()
        }
        bindExpandingBtn()
        updateBottomBarState(isExpand: self.isExpanding)
    }

    func bindExpandingBtn() {
        disposeBag = DisposeBag()
        expandBtn.rx.tap
            .bind(onNext: { [unowned self] in
                self.isExpanding = !self.isExpanding
                self.updateBottomBarState(isExpand: self.isExpanding)
                self.refreshCell()
            })
            .disposed(by: disposeBag)
    }

    func updateByExpandingState() {
        if self.isExpanding {
            self.containerView.snp.updateConstraints { (make) in
                make.height.equalTo(66 * self.itemCount)
            }
        } else {
            self.containerView.snp.updateConstraints { (make) in
                make.height.equalTo(66  * 3)
            }
        }
    }

    func updateBottomBarState(isExpand: Bool) {
        if isExpand {
            expandLabel.text = "收起"
            arrowIcon.image = UIImage(named: "arrowicon-feed-2")
        } else {
            expandLabel.text = "查看全部"
            arrowIcon.image = UIImage(named: "arrowicon-feed-3")
        }
    }

}

func parseAgentListCell() -> () -> TableSectionNode? {
    let cellRender = curry(fillAgentListCell)
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: [],
            tracer:  [],
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHAgentListCell.identifier))
    }
}

func fillAgentListCell(cell: BaseUITableViewCell) {
    guard let theCell = cell as? FHAgentListCell else {
        return
    }
    let itemView = ItemView(frame: CGRect.zero)
    itemView.name.text = "李强"
    itemView.agency.text = "链家"
    theCell.phoneCallViewModel.bindCallBtn(btn: itemView.callBtn,
                                           disposeBag: theCell.disposeBag)
    let itemView1 = ItemView(frame: CGRect.zero)
    itemView1.name.text = "李强"
    itemView1.agency.text = "链家"
    theCell.phoneCallViewModel.bindCallBtn(btn: itemView1.callBtn,
                                           disposeBag: theCell.disposeBag)

    let itemView2 = ItemView(frame: CGRect.zero)
    itemView2.name.text = "李强"
    itemView2.agency.text = "链家"
    theCell.phoneCallViewModel.bindCallBtn(btn: itemView2.callBtn,
                                           disposeBag: theCell.disposeBag)

    let itemView3 = ItemView(frame: CGRect.zero)
    itemView3.name.text = "李强"
    itemView3.agency.text = "链家"
    theCell.phoneCallViewModel.bindCallBtn(btn: itemView3.callBtn,
                                           disposeBag: theCell.disposeBag)

    let itemView4 = ItemView(frame: CGRect.zero)
    itemView4.name.text = "李强"
    itemView4.agency.text = "链家"
    theCell.phoneCallViewModel.bindCallBtn(btn: itemView4.callBtn,
                                           disposeBag: theCell.disposeBag)

    theCell.addItems(items: [itemView, itemView1, itemView2, itemView3, itemView4])
    theCell.updateByExpandingState()
}
