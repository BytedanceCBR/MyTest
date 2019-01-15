//
//  LicenceBrowserViewModel.swift
//  Article
//
//  Created by leo on 2019/1/8.
//

import Foundation
import JXPhotoBrowser
import Photos

class FHLicenceImageItem {
    var url: String
    var title: String
    init(url: String, title: String) {
        self.url = url
        self.title = title
    }
}

class LicenceBrowserViewModel {
    fileprivate var headerImages: [FHLicenceImageItem] = []

    func open() {
        if headerImages.isEmpty {
            return
        }
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
        // 数字型页码指示器
        let numberPageControlPlugin = FHHouseNumberPageControlPlugin()
        //            numberPageControlPlugin.images = self.headerImages

        //            numberPageControlPlugin.largeTracer = largeImageTracerGen(images: self.headerImages, traceParams: traceParams)
        numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
        browser.plugins.append(numberPageControlPlugin)
        browser.cellPlugins = [RawImageButtonPlugin()]
        let plugin = FHPhotoBrowserShowAllPlugin(titles: headerImages.map { $0.title } )
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

    func setImages(images: [FHLicenceImageItem]) {
        headerImages = images
    }
}

extension LicenceBrowserViewModel: PhotoBrowserDelegate {
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
        return nil
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
