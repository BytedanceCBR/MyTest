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

class CycleImageCell: BaseUITableViewCell {

    private var pageableViewModel: PageableViewModel?
    
    var traceParams: TracerParams?
    
    private lazy var indexIndicator: UIView = {
        let re = UIView()
        re.backgroundColor = color(0, 0, 0, 0.3)
        re.layer.cornerRadius = 10
        re.isHidden = true
        return re
    }()

    private lazy var indexLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        re.textAlignment = .center
        re.textColor = UIColor.white
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer()
    }()

    var count = 0

    let disposeBag = DisposeBag()
    
    var pictureDisposeBag: DisposeBag?

    var openPictureBrowser: ((Int, UIView) -> Void)?

    open override class var identifier: String {
        return "CycleImage"
    }

    fileprivate var headerImages: [ImageModel] = [] {
        didSet {
            if let pageableViewModel = pageableViewModel {
                pageableViewModel.reloadData(currentPageOnly: false)
                pageableViewModel.pageView.isScrollEnabled = headerImages.count > 1
                pictureDisposeBag = DisposeBag()
                tapGesture.rx.event
                        .withLatestFrom(pageableViewModel.currentPage.asObservable())
                        .bind(onNext: { [unowned self] in
                            if self.headerImages.count != 0 {
                                self.openPictureBrowser?($0, self)
                            }
                        })
                        .disposed(by: pictureDisposeBag!)
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupPageableViewModel { [weak self] i in
            let url = self?.selectHeaderView(index: i)
            
            if var tracerParams = self?.traceParams, let picture_id = url, picture_id.count > 0 {
                
                tracerParams = tracerParams <|> toTracerParams(picture_id, key: "picture_id") <|>
                    toTracerParams("small", key: "show_type")
                recordEvent(key: TraceEventName.picture_show, params: tracerParams)
                
            }
            
            return url ?? ""
        }

        contentView.addSubview(indexIndicator)
        indexIndicator.snp.makeConstraints { maker in
            maker.right.equalTo(-10)
            maker.bottom.equalTo(-10)
            maker.height.equalTo(20)
        }

        indexIndicator.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { maker in
            maker.left.equalTo(11)
            maker.right.equalTo(-11)
            maker.top.equalTo(5)
            maker.bottom.equalTo(-5)

        }
        pageableViewModel?.currentPage
                .observeOn(MainScheduler.asyncInstance)
                .map { [unowned self] _ in self.count == 0 }
                .bind(to: indexIndicator.rx.isHidden)
                .disposed(by: disposeBag)
        pageableViewModel?.currentPage
                .observeOn(MainScheduler.asyncInstance)
                .filter { [unowned self] _ in self.count != 0 }
                .map { [unowned self] (index) in CycleImageCell.offsetByIndex(index: index, count: self.count) }
                .map { [unowned self] (index) in "\(index + 1)/\(self.count)" }
                .bind(to: indexLabel.rx.text)
                .disposed(by: disposeBag)

        pageableViewModel?.pageView.addGestureRecognizer(tapGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPageableViewModel(cycleImageSelector: @escaping ((Int) -> String)) {
        pageableViewModel = PageableViewModel(cacheViewCount: 5) { [weak self] in
            let re = BDImageViewProvider(imageSelector: cycleImageSelector)
            return re
        }
        if let pageableViewModel = pageableViewModel {
            let imageHeight = UIScreen.main.bounds.height / 5 * 2
            pageableViewModel.pageView.isUserInteractionEnabled = true

            contentView.addSubview(pageableViewModel.pageView)
            pageableViewModel.pageView.snp.makeConstraints { maker in
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


fileprivate func openNewHousePictureBrowser(dataSource: PictureBrowserDataSource,
                                            pictures: [PictureCategorySection],
                                            traceParams: TracerParams?,
                                            disposeBag: DisposeBag,
                                            navVC: UINavigationController?,
                                            selectedIndex: Int) {
    // 创建图片浏览器
    let browser = PhotoBrowser(photoLoader: BDWebImagePhotoLoader())
    // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
    // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleccccNoHiding`。
    browser.animationType = .scale
    // 浏览器协议实现者
    browser.photoBrowserDelegate = dataSource
    // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
    // 光点型页码指示器
    //    browser.plugins.append(DefaultPageControlPlugin())
    // 数字型页码指示器cccc
    let numberPageControlPlugin = HouseNumberPageControlPlugin()
    numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
    browser.plugins.append(numberPageControlPlugin)
    let plugin = PhotoBrowserShowAllPlugin()
    browser.plugins.append(plugin)

    plugin.didTouchBackButton = { [weak browser] in
        
        browser?.dismiss(animated: true, completion: nil)
    }
    
    plugin.didTouchShowAllButton = { [weak browser] in
        
        let vc = PictureCategoryListVC()
        vc.navBar.title.text = "楼盘相册"
        vc.items.accept(pictures)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: {[weak vc] () in
                
                vc?.dismiss(animated: true, completion: nil)

            })
            .disposed(by: disposeBag)
        
        vc.selectIndex.filter { $0 != nil }
            .subscribe(onNext: { [weak browser] (index) in
                
            browser?.scrollToItem(index ?? 0, at: .centeredHorizontally, animated: false)

        })
        .disposed(by: disposeBag)
        
        let topVC = TopMostViewControllerGetter.topMost(of: navVC)
        topVC?.present(vc, animated: true, completion: nil)
        
        if var theTraceParams = traceParams {
            
            let key = dataSource.pictures[selectedIndex]
            theTraceParams = theTraceParams <|> toTracerParams(key, key: "picture_id") <|>
                toTracerParams("large", key: "show_type")
            recordEvent(key: TraceEventName.picture_gallery, params: theTraceParams)
        }
        
    }
    // 指定打开图片组中的哪张
    browser.originPageIndex = selectedIndex
    // 展示
    
    let topVC = TopMostViewControllerGetter.topMost(of: navVC)
    browser.show(from: topVC)
    
    
}

fileprivate func openPictureBrowser(dataSource: PictureBrowserDataSource, disposeBag: DisposeBag, selectedIndex: Int) {
    // 创建图片浏览器
    let browser = PhotoBrowser(photoLoader: BDWebImagePhotoLoader())
    // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
    // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleNoHiding`。
    browser.animationType = .scale
    // 浏览器协议实现者
    browser.photoBrowserDelegate = dataSource
    // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制

    // 数字型页码指示器
    let numberPageControlPlugin = HouseNumberPageControlPlugin()

    numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
    browser.plugins.append(numberPageControlPlugin)

    // 指定打开图片组中的哪张
    browser.originPageIndex = selectedIndex
    // 展示
    browser.show()
}

fileprivate struct ImageModel {
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
                items: [cellRender],
                selectors: nil,
                tracer: nil,
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
                items: [cellRender],
                selectors: nil,
                tracer: nil,
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
                items: [cellRender],
                selectors: nil,
                tracer: nil,
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
        theCell.headerImages = images
        theCell.count = images.count
        theCell.traceParams = traceParams
        var dataSource: PictureBrowserDataSource?
        theCell.openPictureBrowser = { (index, view) in
            let theDataSource = PictureBrowserDataSource(pictures: images.map { $0.url }, target: view, traceParams: traceParams)
            dataSource = theDataSource
            openPictureBrowser(dataSource: theDataSource, disposeBag: disposeBag, selectedIndex: index)
        }
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
        
        theCell.headerImages = imageItems ?? []
        theCell.count = imageItems?.count ?? 0
        var dataSource: PictureBrowserDataSource?
        
        let pictures = imageGroups?.map { (group) -> PictureCategorySection in
            let urls = group.images?.filter { $0.url != nil }.map { $0.url! }
            return PictureCategorySection(name: group.name ?? "", items: urls ?? [])
        }
        
        theCell.openPictureBrowser = { [unowned theCell] (index, view) in
            let theDataSource = PictureBrowserDataSource(pictures: theCell.headerImages.map { $0.url }, target: view, traceParams: traceParams)
            dataSource = theDataSource
            openNewHousePictureBrowser(
                dataSource: theDataSource,
                pictures: pictures ?? [],
                traceParams: traceParams,
                disposeBag: disposeBag,
                navVC: navVC,
                selectedIndex: index)
        }
    }
    
}

// MARK: PictureBrowserDataSource
fileprivate class PictureBrowserDataSource: NSObject, PhotoBrowserDelegate {

    let pictures: [String]

    let target: UIView
    
    var traceParams: TracerParams?


    init(pictures: [String], target: UIView, traceParams: TracerParams?) {
        self.pictures = pictures
        self.target = target
        self.traceParams = traceParams
    }

    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: JXPhotoBrowser.PhotoBrowser) -> Int {
        return pictures.count
    }

    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        let url = URL(string: pictures[index])
        let key = BDWebImageManager.shared().requestKey(with: url)
        return BDImageCache.shared().image(forKey: key)
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        let url = URL(string: pictures[index])
        return url
    }

    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
        let url = URL(string: pictures[index])
        let key = BDWebImageManager.shared().requestKey(with: url)
        
        if var tracerParams = self.traceParams {
            
            tracerParams = tracerParams <|> toTracerParams(key ?? "be_null", key: "picture_id") <|>
                toTracerParams("large", key: "show_type")
            recordEvent(key: TraceEventName.picture_show, params: tracerParams)
            
        }
        
        return BDImageCache.shared().image(forKey: key)
    }

    public func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return target
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        
        if var tracerParams = self.traceParams {
            
            let key = pictures[index]
            tracerParams = tracerParams <|> toTracerParams(key, key: "picture_id") <|>
                toTracerParams("large", key: "show_type")
            recordEvent(key: TraceEventName.picture_save, params: tracerParams)
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        
        if let _ = error as NSError? {
        
            var errorTip:String = "保存失败"
            
            let status:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            if status != .authorized {
                
                errorTip = "无照片访问权限"
            }
            TTIndicatorView.show(withIndicatorStyle: .image, indicatorText: errorTip, indicatorImage: UIImage(named: "close_popup_textpage")!, autoDismiss: true, dismissHandler: nil)        }
        else {
            
            TTIndicatorView.show(withIndicatorStyle: .image, indicatorText: "保存成功", indicatorImage: UIImage(named: "doneicon_popup_textpage")!, autoDismiss: true, dismissHandler: nil)
            
        }
        
        
    }
    
}
