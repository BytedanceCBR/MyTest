//
//  CycleImageCell.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JXPhotoBrowser
import Photos


class HouseNumberPageControlPlugin: PhotoBrowserPlugin {
    
    let currentPageRelay = BehaviorRelay<Int>(value:0)

    open func photoBrowser(_ photoBrowser: PhotoBrowser, scrollViewDidScroll: UIScrollView) {
        
        currentPage = Int(scrollViewDidScroll.contentOffset.x / scrollViewDidScroll.bounds.width)
        layout()

    }
    
    /// 字体
    open var font = UIFont.systemFont(ofSize: 17)
    
    /// 字颜色
    open var textColor = UIColor.white
    
    /// 可指定中心点Y坐标
    /// 若不指定，默认为20
    open var centerY: CGFloat?
    
    var largeTracer:  ((Int,TracerParams?) -> Void)?
    fileprivate var images: [ImageModel] = []

    private var stayParams = TracerParams.momoid()
    private var theThresholdTracer: ((String, TracerParams) -> Void)?
    
    var traceParams: TracerParams?

    /// 数字指示
    open lazy var numberLabel: UILabel = {
        let view = UILabel()
        view.font = font
        view.textColor = textColor
        return view
    }()
    
    /// 总页码
    open var totalPages = 0
    
    /// 当前页码
    open var currentPage = 0
    
    public init() {}
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, numberOfPhotos count: Int) {
        totalPages = count
        layout()
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        currentPage = index

        self.largeTracer?(index,TracerParams.momoid() <|> toTracerParams("large", key: "show_type"))
        
        let offset = CycleImageCell.offsetByIndex(index: index, count: images.count)
        let imageModel = images[offset]
        if let traceParams = self.traceParams {
            
            self.traceParams = traceParams <|> toTracerParams(imageModel.url, key: "picture_id")
        }

        currentPageRelay.accept(currentPage)
        layout()
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidAppear view: UIView, animated: Bool) {
        // 页面出来后，再显示页码指示器
        // 多于一张图才显示
        if totalPages > 1 {
            view.addSubview(numberLabel)
        }
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidLayoutSubviews view: UIView) {
        layout()
        numberLabel.isHidden = totalPages <= 1
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, viewWillAppear view: UIView, animated: Bool) {
        self.theThresholdTracer = thresholdTracer()
        self.stayParams = TracerParams.momoid() <|>
            traceStayTime()
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, viewWillDisappear view: UIView) {
        
        if let traceParams = self.traceParams {
            
            self.theThresholdTracer?(TraceEventName.picture_large_stay, self.stayParams <|> traceParams <|> toTracerParams("large", key: "show_type"))
        }

    }
    
    private func layout() {
        numberLabel.text = "\(currentPage + 1) / \(totalPages)"
        numberLabel.sizeToFit()
        guard let superView = numberLabel.superview else { return }
        numberLabel.center = CGPoint(x: superView.bounds.midX,
                                     y: superView.bounds.minY + pageControlOffsetY)
    }
    
    private var pageControlOffsetY: CGFloat {
        if let centerY = centerY {
            return centerY
        }
        guard let superView = numberLabel.superview else {
            return 0
        }
        var offsetY: CGFloat = 0
        if #available(iOS 11.0, *) {
            offsetY = superView.safeAreaInsets.top
        }
        return 20 + offsetY
    }
}

fileprivate func largeImageTracerGen(images: [ImageModel], traceParams: TracerParams?) -> (Int,TracerParams?) -> Void {
    
    var array: [Int] = []
    return { (index,param) in
        
        if var theTracerParams = traceParams {
            
            if let theParams = param {
                
                theTracerParams = theTracerParams <|> theParams
            }
            
            let offset = CycleImageCell.offsetByIndex(index: index, count: images.count)
            let imageModel = images[offset]
            if !array.contains(offset) {
                
                theTracerParams = theTracerParams <|> toTracerParams(imageModel.url, key: "picture_id")

                recordEvent(key: TraceEventName.picture_show, params: theTracerParams)
                array.append(offset)
            }
        }
    }
}

class FHPhotoBrowser: PhotoBrowser
{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - CycleImageCell
@objc
class CycleImageCell: BaseUITableViewCell {

    private var pageableViewModel: PageableViewModel?
    
    var traceParams: TracerParams?
    var smallTracer:  ((Int,TracerParams?) -> Void)?

    private lazy var indexIndicatorContainer: UIView = {
        let re = UIView()
        return re
    }()

    private lazy var indexIndicator: UIView = {
        let re = UIView()
        re.backgroundColor = color(0, 0, 0, 0.3)
        re.layer.cornerRadius = 10
        re.isHidden = true
        return re
    }()

    private lazy var indexLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textAlignment = .center
        re.textColor = UIColor.white
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer()
    }()

    var count = 0

    let disposeBag = DisposeBag()
    
    var pictures: [PictureCategorySection]?
    var navVC: UINavigationController?
    
    open override class var identifier: String {
        return "CycleImage"
    }

    var headerImages: [ImageModel] = [] {
        didSet {
            if let thePageVM = pageableViewModel {
                
                thePageVM.reloadData(currentPageOnly: false)
                thePageVM.pageView.isScrollEnabled = headerImages.count > 1
                
            }
        }
    }
    
    func smallImageTracerGen(images: [ImageModel], traceParams: TracerParams?) -> (Int,TracerParams?) -> Void {
        
        var array: [Int] = []
        return { [unowned self ] (index,param) in
            
            if var theTracerParams = traceParams {
                
                if let theParams = param {
                    
                    theTracerParams = theTracerParams <|> theParams
                }

                let offset = CycleImageCell.offsetByIndex(index: index, count: self.headerImages.count)
                let imageModel = images[offset]
                if !array.contains(offset) {
                    
                    theTracerParams = theTracerParams <|> toTracerParams(imageModel.url, key: "picture_id")
                    recordEvent(key: TraceEventName.picture_show, params: theTracerParams)
                    array.append(offset)
                }
            }
        }
    }
    
    func rentSmallImageTracerGen(images: [FHRentDetailResponseDataHouseImageModel], traceParams: TracerParams?) -> (Int,TracerParams?) -> Void {
        
        var array: [Int] = []
        return { [unowned self ] (index,param) in
            
            if var theTracerParams = traceParams {
                
                if let theParams = param {
                    
                    theTracerParams = theTracerParams <|> theParams
                }
                
                let offset = CycleImageCell.offsetByIndex(index: index, count: self.headerImages.count)
                let imageModel = images[offset]
                if !array.contains(offset) {
                    
                    theTracerParams = theTracerParams <|> toTracerParams(imageModel.url, key: "picture_id")
                    recordEvent(key: TraceEventName.picture_show, params: theTracerParams)
                    array.append(offset)
                }
            }
        }
    }
    
    @objc
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupPageableViewModel { [weak self] i in
            let url = self?.selectHeaderView(index: i)
            return url ?? ""
        }

        contentView.addSubview(indexIndicatorContainer)
        indexIndicatorContainer.snp.makeConstraints { (maker) in
            maker.right.equalTo(-10)
            maker.bottom.equalTo(-10)
            maker.height.equalTo(20)
        }

        indexIndicatorContainer.addSubview(indexIndicator)
        indexIndicator.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        indexIndicatorContainer.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { maker in
            maker.left.equalTo(11)
            maker.right.equalTo(-11)
            maker.top.equalTo(5)
            maker.bottom.equalTo(-5)
        }
        
        if let thePageVM = pageableViewModel {

            thePageVM.currentPage
                .observeOn(MainScheduler.asyncInstance)
                .map { [weak self] _ in self?.count ?? 0 == 0 }
                .bind(to: indexIndicator.rx.isHidden)
                .disposed(by: disposeBag)
            
            thePageVM.currentPage
                .observeOn(MainScheduler.asyncInstance)
                .filter { [weak self] _ in self?.count ?? 0 != 0 }
                .map { [unowned self] (index) in CycleImageCell.offsetByIndex(index: index, count: self.count) }
                .map { [unowned self] (index) in "\(index + 1)/\(self.count)" }
                .bind(to: indexLabel.rx.text)
                .disposed(by: disposeBag)
            
            thePageVM.currentPage
//                .debug()
                .subscribe(onNext: { [weak self] (index) in
                    if self?.headerImages.count != 0 {
                        self?.smallTracer?(index,TracerParams.momoid() <|> toTracerParams("small", key: "show_type"))
                    }
                })
                .disposed(by: disposeBag)
            
            thePageVM.pageView.addGestureRecognizer(tapGesture)
            tapGesture.rx.event
                .withLatestFrom(thePageVM.currentPage.asObservable())
                .bind(onNext: { [unowned self] in
                    
                    if self.headerImages.count > 0 {
                        let offset = CycleImageCell.offsetByIndex(index: $0, count: self.headerImages.count)
                        if let count = self.pictures?.count, count > 0 {
                            self.openNewHousePictureBrowser(pictures: self.pictures!, navVC: self.navVC, selectedIndex: offset)
                        }else {
                            self.openPictureBrowser(selectedIndex: offset)
                            
                        }
                    }
                })
                .disposed(by: disposeBag)
            
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPageableViewModel(cycleImageSelector: @escaping ((Int) -> String)) {
        pageableViewModel = PageableViewModel(cacheViewCount: 5) {
            let re = BDImageViewProvider(imageSelector: cycleImageSelector)
            return re
        }
        let imageHeight = 300 * CommonUIStyle.Screen.widthScale // UIScreen.main.bounds.height / 5 * 2
        if let thePageVM = pageableViewModel {

            thePageVM.pageView.isUserInteractionEnabled = true
            
            contentView.addSubview(thePageVM.pageView)
            thePageVM.pageView.snp.makeConstraints { maker in
                maker.left.right.top.bottom.equalToSuperview()
                maker.height.equalTo(imageHeight)
            }
        }

    }

    func selectHeaderView(index: Int) -> String {
        if headerImages.count != 0 {
            let offset = CycleImageCell.offsetByIndex(index: index, count: headerImages.count)
            return headerImages[offset].url
        } else {
            return ""
        }
    }

    static func offsetByIndex(index: Int, count: Int) -> Int {
        var offset = index % count
        if offset < 0 {
            offset = count - abs(offset)
        }
        return offset
    }
    
    fileprivate func openNewHousePictureBrowser(pictures: [PictureCategorySection],
                                                navVC: UINavigationController?,
                                                selectedIndex: Int) {
        // 创建图片浏览器
        let browser = FHPhotoBrowser(photoLoader: BDWebImagePhotoLoader())
        // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
        // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleccccNoHiding`。
        browser.animationType = .scale
        // 浏览器协议实现者
        browser.photoBrowserDelegate = self
        // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
        // 光点型页码指示器
        //    browser.plugins.append(DefaultPageControlPlugin())
        // 数字型页码指示器cccc
        let numberPageControlPlugin = HouseNumberPageControlPlugin()
        numberPageControlPlugin.traceParams = traceParams
        numberPageControlPlugin.images = self.headerImages

        numberPageControlPlugin.largeTracer = largeImageTracerGen(images: self.headerImages, traceParams: traceParams)
        numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
        browser.plugins.append(numberPageControlPlugin)
        browser.cellPlugins = [RawImageButtonPlugin()]

        numberPageControlPlugin.currentPageRelay.subscribe({ [unowned self] (index) in
            if let pageVM = self.pageableViewModel {

                pageVM.currentPage.accept(index.element ?? 0)
                pageVM.onPageLayout()

            }
        })
        .disposed(by: self.disposeBag)
        
        let plugin = PhotoBrowserShowAllPlugin()
        browser.plugins.append(plugin)
        
        let originWindowLevel: UIWindowLevel? = UIApplication.shared.keyWindow?.windowLevel
        plugin.didTouchBackButton = { [weak browser] in
            
            browser?.dismiss(animated: true, completion: nil)
            if let window = UIApplication.shared.keyWindow, let originLevel = originWindowLevel {
                window.windowLevel = originLevel
            }
        }
        
        plugin.didTouchShowAllButton = { [weak browser] in
            
            let vc = PictureCategoryListVC()
            vc.navBar.title.text = "楼盘相册"
            vc.items.accept(pictures)
            vc.navBar.backBtn.rx.tap
                .subscribe(onNext: {[weak vc] () in
                    vc?.dismiss(animated: true, completion: nil)
                })
                .disposed(by: self.disposeBag)
            
            vc.selectIndex.filter { $0 != nil }
                .subscribe(onNext: { [weak browser] (index) in
                    browser?.scrollToItem(index ?? 0, at: .centeredHorizontally, animated: false)
                })
                .disposed(by: self.disposeBag)
            
            if var theTraceParams = self.traceParams,selectedIndex < self.headerImages.count {
                let imageModel = self.headerImages[selectedIndex]
                let key = imageModel.url
                theTraceParams = theTraceParams <|> toTracerParams(key, key: "picture_id")
                recordEvent(key: TraceEventName.picture_gallery, params: theTraceParams)
                
                vc.traceParams = theTraceParams
            }
            
            let topVC = TopMostViewControllerGetter.topMost(of: navVC)
            topVC?.present(vc, animated: true, completion: nil)
            
            if let window = UIApplication.shared.keyWindow, let originLevel = originWindowLevel {
                window.windowLevel = originLevel
            }
        }
        // 指定打开图片组中的哪张
        browser.originPageIndex = selectedIndex
        // 展示
        
        let topVC = TopMostViewControllerGetter.topMost(of: navVC)
        browser.show(from: topVC)
        
        
    }
    
    fileprivate func openPictureBrowser(selectedIndex: Int) {
        // 创建图片浏览器
        let browser = FHPhotoBrowser(photoLoader: BDWebImagePhotoLoader())
        // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
        // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleNoHiding`。
        browser.animationType = .scale
        // 浏览器协议实现者
        browser.photoBrowserDelegate = self
        // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
        
        // 数字型页码指示器
        let numberPageControlPlugin = HouseNumberPageControlPlugin()
        numberPageControlPlugin.traceParams = traceParams
        numberPageControlPlugin.images = self.headerImages

        numberPageControlPlugin.largeTracer = largeImageTracerGen(images: self.headerImages, traceParams: traceParams)
        browser.cellPlugins = [RawImageButtonPlugin()]

        numberPageControlPlugin.currentPageRelay
//            .debug()
            .subscribe({ [unowned self] (index) in
            if let pageVM = self.pageableViewModel {

                pageVM.currentPage.accept(index.element ?? 0)
                pageVM.onPageLayout()
                
            }
        })
        .disposed(by: self.disposeBag)
        numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
        browser.plugins.append(numberPageControlPlugin)
        
        // 指定打开图片组中的哪张
        browser.originPageIndex = selectedIndex
        // 展示
        browser.show()
    }

    @objc
    func setImageObjs(images: [ImageItemObj]) {
        self.headerImages = images.map {
            ImageModel(url: $0.url, category: $0.category)
        }
    }

}

fileprivate func convertToPictureSection(_ models: [ImageModel]) -> [PictureCategorySection] {
    return models
        .reduce([:]) { (result, model) -> [String: [ImageModel]] in
            var result = result
            if var items = result[model.category] {
                items.append(model)
                result[model.category] = items
            } else {
                result[model.category] = [model]
            }
            return result
        }
        .map({ (e) -> PictureCategorySection in
            let (key, value) = e
            let urls = value.map { $0.url }
            return PictureCategorySection(name: key, items: urls)
        })
}

class ImageItemObj: NSObject {
    var url: String
    var category: String

    init(url: String, category: String) {
        self.url = url
        self.category = category
        super.init()
    }
}

struct ImageModel {
    let url: String
    let category: String
}

func parseNewHouseCycleImageNode(
    _ newHouseData: NewHouseData,
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {

        let cellRender = curry(fillCycleImageCell)(newHouseData.imageGroup)(traceParams)(disposeBag)(navVC)
        return TableSectionNode(
                items: [oneTimeRender(cellRender)],
                selectors: nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseErshouHouseCycleImageNode(
    _ ershouHouseData: ErshouHouseData,
    traceParams: TracerParams,
    disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let imageItems = ershouHouseData.houseImage?.map({ (image) -> ImageModel in
            if let url = image.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
        })
        let cellRender = curry(fillErshouHouseCycleImageCell)(imageItems ?? [])(traceParams)(disposeBag)
        return TableSectionNode(
                items: [oneTimeRender(cellRender)],
                selectors: nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseCycleImageNode(_ images: [ImageItem]?,
                         traceParams: TracerParams,
                         disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let imageItems = images?.map { (item) -> ImageModel in
            if let url = item.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
         }
        let cellRender = curry(fillErshouHouseCycleImageCell)(imageItems ?? [])(traceParams)(disposeBag)
        return TableSectionNode(
                items: [oneTimeRender(cellRender)],
                selectors: nil,
                tracer: nil,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

fileprivate func fillErshouHouseCycleImageCell(
    _ images: [ImageModel],
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        theCell.traceParams = traceParams
        theCell.count = images.count
        theCell.smallTracer = theCell.smallImageTracerGen(images: images, traceParams: traceParams)
        theCell.headerImages = images

    }
}

fileprivate func fillCycleImageCell(_ imageGroups: [ImageGroup]?,
                                    traceParams: TracerParams?,
                                    disposeBag: DisposeBag,
                                    navVC: UINavigationController?,
                                    cell: BaseUITableViewCell) -> Void {
    
    if let theCell = cell as? CycleImageCell {
        
        theCell.traceParams = traceParams
        let imageItems = imageGroups?.map({ (group) -> [ImageModel] in
            
            if let name = group.name, let images = group.images {
                let urls = images.filter { $0.url != nil }.map { $0.url! }
                let imageItems = urls.map({ (url) -> ImageModel in
                    return ImageModel(url: url, category: name)
                    
                })
                return imageItems
                
            } else {
                return []
            }
            
        }).flatMap{ $0 }
        
        theCell.count = imageItems?.count ?? 0
        theCell.smallTracer = theCell.smallImageTracerGen(images: imageItems ?? [], traceParams: traceParams)
        let pictures = imageGroups?.map { (group) -> PictureCategorySection in
            let urls = group.images?.filter { $0.url != nil }.map { $0.url! }
            return PictureCategorySection(name: group.name ?? "", items: urls ?? [])
        }
        theCell.pictures = pictures ?? []
        theCell.navVC = navVC
        theCell.headerImages = imageItems ?? []


    }
    
}

// MARK: PictureBrowserDataSource
extension CycleImageCell: PhotoBrowserDelegate {

    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: JXPhotoBrowser.PhotoBrowser) -> Int {
        return headerImages.count
    }

    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        
        if index >= headerImages.count { return nil}
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        let key = BDWebImageManager.shared().requestKey(with: url)
        return BDImageCache.shared().image(forKey: key)
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        return url
    }

    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, localImageForIndex index: Int) -> UIImage? {

        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url)
        let key = BDWebImageManager.shared().requestKey(with: url)
        
        return BDImageCache.shared().image(forKey: key)
    }

    public func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return self
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        
        if index >= headerImages.count { return }
        let imageModel = headerImages[index]
        
        if var tracerParams = self.traceParams {

            tracerParams = tracerParams <|> toTracerParams(imageModel.url, key: "picture_id")
            recordEvent(key: TraceEventName.picture_save, params: tracerParams)
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        
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
