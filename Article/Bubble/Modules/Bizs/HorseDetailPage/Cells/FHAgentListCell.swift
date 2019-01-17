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
import JXPhotoBrowser
import Photos
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

fileprivate class ItemView: UIControl {

    lazy var avator: UIImageView = {
        let re = UIImageView()
        re.layer.cornerRadius = 23
        re.contentMode = .scaleAspectFill
        re.clipsToBounds = true
        re.image = #imageLiteral(resourceName: "default-avatar-icons")
        return re
    }()

    lazy var licenceIcon: UIButton = {
        let re = ExtendHotAreaButton()
        re.setImage(UIImage(named: "contact"), for: .normal)
        return re
    }()

    lazy var callBtn: UIButton = {
        let re = ExtendHotAreaButton()
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
        self.addSubview(callBtn)
        self.addSubview(licenceIcon)

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
            make.right.lessThanOrEqualTo(callBtn.snp.left).offset(-10)
        }

        callBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(-20)
            make.centerY.equalTo(avator)
        }
    }
}

class FHAgentListCell: BaseUITableViewCell, RefreshableTableViewCell {

    var displayRecords:[() -> Void]?

    var refreshCallback: CellRefreshCallback?

    var disposeBag = DisposeBag()

    var isExpanding = false

    var traceModel: HouseRentTracer?

    lazy var licenceBrowserViewModel: LicenceBrowserViewModel = {
        let re = LicenceBrowserViewModel()
        return re
    }()

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

    lazy var expandAreaBtnView: UIControl = {
        let re = UIControl()
        return re
    }()

    lazy var arrowIcon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "defaultAvatar")
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

    var hasSetupExpendView = false

    weak var photoBrowser: PhotoBrowser?

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
        contentView.addSubview(expandAreaBtnView)
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
        if items.count > 3 && !hasSetupExpendView {
            self.setupExpaneView()
            hasSetupExpendView = true
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

        expandAreaBtnView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(expandBtnView)
            make.left.right.equalToSuperview()
        }
        bindExpandingBtn()
        updateBottomBarState(isExpand: self.isExpanding)
    }

    func bindExpandingBtn() {
        disposeBag = DisposeBag()
        expandAreaBtnView.rx.controlEvent(.touchUpInside)
//        expandBtn.rx.tap
            .bind(onNext: { [unowned self] in
                self.isExpanding = !self.isExpanding
                self.updateBottomBarState(isExpand: self.isExpanding)
                self.refreshCell()
                self.traceRealtorClickMore()
                self.recordAllElementShow()
            })
            .disposed(by: disposeBag)
    }

    func updateByExpandingState() {
        if self.itemCount > 3 {
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

    func openPhotoByContact(contact: FHHouseDetailContact) -> () -> Void {
        return { [weak self] in
            var headers:[FHLicenceImageItem] = []
            if (contact.businessLicense?.isEmpty ?? true) == false,
                let businessLicense = contact.businessLicense {
                let item = FHLicenceImageItem(url: businessLicense, title: "营业执照")
                headers.append(item)
            }
            if (contact.certificate?.isEmpty ?? true) == false,
                let certificate = contact.certificate {
                let item = FHLicenceImageItem(url: certificate, title: "从业人员信息卡")
                headers.append(item)
            }
            self?.licenceBrowserViewModel.setImages(images: headers)
            self?.licenceBrowserViewModel.open()
        }
    }

    fileprivate func traceRealtorClickMore() {
        if let traceModel = traceModel {
            let params = TracerParams.momoid() <|>
                EnvContext.shared.homePageParams <|>
                toTracerParams(traceModel.pageType, key: "page_type") <|>
                toTracerParams(traceModel.rank, key: "rank") <|>
                toTracerParams(traceModel.logPb ?? "be_null", key: "log_pb")
            recordEvent(key: "realtor_click_more", params: params)
        }
    }

    func onAreaDisplay(displayArea: CGRect) {
        expandItemView.subviews
            .map { $0.frame }
            .enumerated()
            .forEach { (e) in
                let (offset, f) = e
                if displayArea.intersects(f) {
                    if let displayRecords = displayRecords {
                        if displayRecords.count > offset {
                            displayRecords[offset]()
                        }
                    }
                }
            }
    }

    func recordAllElementShow() {
        displayRecords?.forEach({ (record) in
            record()
        })
    }

}

func parseAgentListCell(data: ErshouHouseData,
                        traceModel: HouseRentTracer?,
                        followUp:@escaping () -> Void) -> () -> TableSectionNode? {

    if data.recommendedRealtors?.count == 0 {
        return { nil }
    }
    let cellRender = curry(fillAgentListCell)(data)(traceModel)(followUp)
    let params = TracerParams.momoid() <|>
        EnvContext.shared.homePageParams <|>
        toTracerParams(traceModel?.pageType ?? "be_null", key: "page_type") <|>
        toTracerParams("old_detail_related",key: "element_type") <|>
        toTracerParams(traceModel?.rank ?? "be_null", key: "rank") <|>
        toTracerParams(traceModel?.logPb ?? "be_null", key: "log_pb")
    let records = [elementShowOnceRecord(params: params)]
    return {
        return TableSectionNode(
            items: [cellRender],
            selectors: [],
            tracer:  records,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHAgentListCell.identifier))
    }
}

func fillAgentListCell(
    data: ErshouHouseData,
    traceModel: HouseRentTracer?,
    followUpAction:@escaping () -> Void,
    cell: BaseUITableViewCell) {
    guard let theCell = cell as? FHAgentListCell else {
        return
    }
    theCell.phoneCallViewModel.followUpAction = followUpAction
    let items = data.recommendedRealtors?.take(5).enumerated()
        .map({ (e) -> ItemView  in
            let (offset, contact) = e
            let itemView = ItemView(frame: CGRect.zero)
            itemView.name.text = contact.realtorName
            itemView.agency.text = contact.agencyName
            if let avatarUrl = contact.avatarUrl {
                itemView.avator.bd_setImage(with: URL(string: avatarUrl),
                                            placeholder: UIImage(named: "defaultAvatar"))
            }
            itemView.licenceIcon.isHidden = !shouldShowContact(contact: contact)
            //点击电话
            theCell.phoneCallViewModel.bindCallBtn(btn: itemView.callBtn,
                                                   rank: "\(offset)",
                                                   houseId: traceModel?.houseId ?? -1,
                                                   houseType: .secondHandHouse,
                                                   traceModel: traceModel,
                                                   contact: contact,
                                                   disposeBag: theCell.disposeBag)
            //预览营业执照
            itemView.licenceIcon.rx.tap
                .bind(onNext: theCell.openPhotoByContact(contact: contact))
                .disposed(by: theCell.disposeBag)

            let delegate = FHRealtorDetailWebViewControllerDelegateImpl()
            delegate.followUp = followUpAction
            //页面跳转
            itemView.rx.controlEvent(.touchUpInside)
                .bind {
                    traceModel?.elementFrom = "old_detail_related"
                    let reportParams = getRealtorReportParams(traceModel: traceModel)
                    let openUrl = "fschema://realtor_detail"

//                    let jumpUrl = "http://10.1.15.29:8889/f100/client/realtor_detail?realtor_id=\(contact.realtorId ?? "")&report_params=\(reportParams)"
                    let jumpUrl = "\(EnvContext.networkConfig.host)/f100/client/realtor_detail?realtor_id=\(contact.realtorId ?? "")&report_params=\(reportParams)"
                    let info: [String: Any] = ["url": jumpUrl,
                                               "title": "经纪人详情页",
                                               "delegate": delegate,
                                               "realtorId": contact.realtorId ?? "",
                                               "trace": traceModel,
                                               "bounce_disable":"1"]
                    let userInfo = TTRouteUserInfo(info: info)
                    TTRoute.shared()?.openURL(byViewController: URL(string: openUrl), userInfo: userInfo)
                }
                .disposed(by: theCell.disposeBag)
            return itemView
        })

    // 经纪人展现埋点绑定
    if theCell.displayRecords?.isEmpty ?? true {
        if let traceModel = traceModel {
            let records = data.recommendedRealtors?.take(5).enumerated()
                .map({ (e) -> () -> Void in
                    let (offset, contact) = e
                    return getElementRecord(contact: contact, traceModel: traceModel, offset: offset)
                })
            theCell.displayRecords = records
        }
    }
    theCell.traceModel = traceModel
    if let items = items, items.count > 0 {
        theCell.addItems(items: items)
        theCell.updateByExpandingState()
    }
}

func getRealtorReportParams(traceModel: HouseRentTracer?) -> String {
    if let traceModel = traceModel {
        var dict:[String: Any] = [:]
        dict["enter_from"] = traceModel.enterFrom
        dict["element_from"] = traceModel.elementFrom
        dict["origin_from"] = traceModel.originFrom ?? "be_null"
        dict["log_pb"] = traceModel.logPb ?? "be_null"
        dict["search_id"] = traceModel.searchId ?? "be_null"
        dict["group_id"] = traceModel.groupId ?? "be_null"
        if let logPb = traceModel.logPb as? [AnyHashable: Any] {
            dict["impr_id"] = (logPb["impr_id"] as? String) ?? "be_null"
        }

        if let data = try? JSONSerialization.data(withJSONObject: dict) {
            return String(bytes: data, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        } else {
            return ""
        }
    } else {
        return ""
    }
}

func getElementRecord(contact: FHHouseDetailContact, traceModel: HouseRentTracer, offset: Int) -> () -> Void {
    var hasRecord: Bool = false
    return {
        if hasRecord {
            return
        }
        let params:[String: Any] = ["page_type": "old_detail",
                                    "element_type": "old_detail_related",
                                    "rank": traceModel.rank,
                                    "origin_from": traceModel.originFrom ?? "be_null",
                                    "origin_search_id": traceModel.originSearchId ?? "be_null",
                                    "log_pb": traceModel.logPb ?? "be_null",
                                    "realtor_id": contact.realtorId ?? "be_null",
                                    "realtor_rank": offset,
                                    "realtor_position": "detail_related"]
        recordEvent(key: "realtor_show", params: params)
        hasRecord = true
    }
}

func shouldShowContact(contact: FHHouseDetailContact) -> Bool {
    var result = false
    if contact.showRealtorinfo ?? 0 != 0 {
        result = true
    } else {
        if (contact.businessLicense?.isEmpty ?? true) == false {
            result = true
        }
        if (contact.certificate?.isEmpty ?? true) == false {
            result = true
        }
    }
    return result
}
