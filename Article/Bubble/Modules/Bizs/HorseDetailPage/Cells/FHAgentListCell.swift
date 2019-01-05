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

    var displayRecords:[() -> Void]?

    var refreshCallback: CellRefreshCallback?

    var disposeBag = DisposeBag()

    var isExpanding = false

    var traceModel: HouseRentTracer?

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

    fileprivate var headerImages: [FHImageItem] = []
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


    fileprivate func openPhoto() {
        if self.headerImages.count > 0 {
            // 创建图片浏览器
            let browser = FHPhotoBrowser(photoLoader: BDWebImagePhotoLoader())
            // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
            // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleNoHiding`。
            browser.animationType = .fade

            // 浏览器协议实现者
            browser.photoBrowserDelegate = self
            // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
            // 光点型页码指示器
            //    browser.plugins.append(DefaultPageControlPlugin())
            // 数字型页码指示器cccc
            let numberPageControlPlugin = FHHouseNumberPageControlPlugin()
            //            numberPageControlPlugin.images = self.headerImages

            //            numberPageControlPlugin.largeTracer = largeImageTracerGen(images: self.headerImages, traceParams: traceParams)
            numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
            browser.plugins.append(numberPageControlPlugin)
            browser.cellPlugins = [RawImageButtonPlugin()]
            let plugin = FHPhotoBrowserShowAllPlugin(titles: headerImages.map { $0.title ?? "" } )
            plugin.overlayView.imageNameLabel.isHidden = false
            browser.plugins.append(plugin)

            let originWindowLevel: UIWindowLevel? = UIApplication.shared.keyWindow?.windowLevel
            plugin.didTouchBackButton = { [weak browser] in

                browser?.dismiss(animated: true, completion: nil)
                if let window = UIApplication.shared.keyWindow, let originLevel = originWindowLevel {
                    window.windowLevel = originLevel
                }
            }
            plugin.overlayView.showBtn.isHidden = true
            browser.show()
        }
    }

    func openPhotoByContact(contact: FHHouseDetailContact) -> () -> Void {
        return { [weak self] in
            var headers:[FHImageItem] = []
            if (contact.businessLicense?.isEmpty ?? true) == false,
                let businessLicense = contact.businessLicense {
                let item = FHImageItem(url: businessLicense, title: "营业执照")
                headers.append(item)
            }
            if (contact.certificate?.isEmpty ?? true) == false,
                let certificate = contact.certificate {
                let item = FHImageItem(url: certificate, title: "从业人员信息卡")
                headers.append(item)
            }
            self?.headerImages = headers
            self?.openPhoto()
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

fileprivate class FHImageItem {
    var url: String
    var title: String
    init(url: String, title: String) {
        self.url = url
        self.title = title
    }
}

func parseAgentListCell(data: ErshouHouseData, traceModel: HouseRentTracer?) -> () -> TableSectionNode? {

    if data.recommendedRealtors?.count == 0 {
        return { nil }
    }
    let cellRender = curry(fillAgentListCell)(data)(traceModel)
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
    cell: BaseUITableViewCell) {
    guard let theCell = cell as? FHAgentListCell else {
        return
    }

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
            //页面跳转
            itemView.rx.controlEvent(.touchUpInside)
                .debug()
                .bind {
                    //TODO openUrl
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

fileprivate class FHHouseNumberPageControlPlugin: HouseNumberPageControlPlugin {
    open override func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        currentPageRelay.accept(index)
    }

    open override func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidLayoutSubviews view: UIView) {
        super.photoBrowser(photoBrowser, viewDidLayoutSubviews: view)
        numberLabel.isHidden = false
    }

    open override func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidAppear view: UIView, animated: Bool) {
        view.addSubview(numberLabel)
    }
}

fileprivate class FHPhotoBrowserShowAllPlugin: PhotoBrowserShowAllPlugin {
    private var titles: [String]
    init(titles: [String]) {
        self.titles = titles
        super.init()
        self.overlayView.backgroundColor = color(0, 0, 0, 0.2)
    }

    override func photoBrowser(_ photoBrowser: PhotoBrowser,
                               didChangedPageIndex index: Int) {
        if titles.count > index {
            self.overlayView.imageNameLabel.text = titles[index]
        }
    }

    open override func photoBrowser(_ photoBrowser: PhotoBrowser,
                                    viewDidLayoutSubviews view: UIView) {
        super.photoBrowser(photoBrowser, viewDidLayoutSubviews: view)
        overlayView.isHidden = false
        let frame = overlayView.frame
        guard let superView = overlayView.superview else { return }

        overlayView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        overlayView.center = CGPoint(x: superView.bounds.midX,
                                     y: bottomOffsetY)
    }

    open override func photoBrowser(_ photoBrowser: PhotoBrowser,
                                    viewDidAppear view: UIView,
                                    animated: Bool) {
        view.addSubview(overlayView)
    }

}


extension FHAgentListCell: PhotoBrowserDelegate {
    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: JXPhotoBrowser.PhotoBrowser) -> Int {
        return headerImages.count
    }

    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      thumbnailImageForIndex index: Int) -> UIImage? {

        if index >= headerImages.count { return nil}
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        let key = BDWebImageManager.shared().requestKey(with: url)
        return BDImageCache.shared().image(forKey: key)
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      highQualityUrlForIndex index: Int) -> URL? {
        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        return url
    }

    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      localImageForIndex index: Int) -> UIImage? {

        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        let key = BDWebImageManager.shared().requestKey(with: url)

        return BDImageCache.shared().image(forKey: key)
    }

    public func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return self
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser,
                      didLongPressForIndex index: Int,
                      image: UIImage) {
        if index >= headerImages.count { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)

    }

    @objc func image(image: UIImage,
                     didFinishSavingWithError error: NSError?,
                     contextInfo:UnsafeRawPointer) {

        if let _ = error as NSError? {
            let errorTip:String = "保存失败"
            let status:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            if status != .authorized {

                let alert = TTThemedAlertController(title: "无照片访问权限", message: "请在手机的「设置-隐私-照片」选项中，允许好多房访问您的照片", preferredType: .alert)
                alert.addAction(withTitle: "取消", actionType: .cancel) {
                }
                alert.addAction(withTitle: "立刻前往", actionType: .normal, actionBlock: {

                    if let url = URL(string: UIApplicationOpenSettingsURLString),UIApplication.shared.canOpenURL(url) {

                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }

                })
                if let topVC = TTUIResponderHelper.topmostViewController() {
                    alert.show(from: topVC, animated: true)
                }
                return
            }
            TTIndicatorView.show(withIndicatorStyle: .image, indicatorText: errorTip, indicatorImage: UIImage(named: "close_popup_textpage")!, autoDismiss: true, dismissHandler: nil)        }
        else {
            TTIndicatorView.show(withIndicatorStyle: .image, indicatorText: "保存成功", indicatorImage: UIImage(named: "doneicon_popup_textpage")!, autoDismiss: true, dismissHandler: nil)
        }
    }
}
