//
//  FHRentDisclaimerCell.swift
//  Article
//
//  Created by leo on 2018/11/21.
//

import Foundation
import RxSwift
import SnapKit
import RxCocoa
import JXPhotoBrowser
import Photos

class FHRentDisclaimerCell: BaseUITableViewCell {

    lazy var ownerLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "3d6e99")
        return re
    }()

    lazy var tapButton: UIButton = {
        let re = UIButton()
        return re
    }()
    
    lazy var contactIcon: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "contact"), for: .normal)
        return re
    }()

    lazy var disclaimerContent: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "a2abb4")
        re.numberOfLines = 0
        return re
    }()

    var onContactIconClick: (() -> Void)?
    
    var traceParam: TracerParams = TracerParams.momoid()

    let disposeBag = DisposeBag()

    weak var photoBrowser: PhotoBrowser?

    var headerImages: [FHRentDetailResponseDataHouseImageModel] = []

    open override class var identifier: String {
        return "rentDisclaimerCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.backgroundColor = hexStringToUIColor(hex: "f2f4f5")
        contentView.addSubview(tapButton)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(contactIcon)
        ownerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(14)
            make.height.equalTo(20)
            make.right.equalTo(contactIcon.snp.left).offset(-10)
        }

        contactIcon.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualTo(-20)
            make.centerY.equalTo(ownerLabel)
            make.width.equalTo(20)
            make.height.equalTo(13)
        }
        contactIcon.isUserInteractionEnabled = false
        tapButton.snp.makeConstraints { (maker) in
            maker.top.left.equalTo(ownerLabel)
            maker.bottom.right.equalTo(contactIcon)
        }

        contentView.addSubview(disclaimerContent)
        disclaimerContent.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(ownerLabel.snp.bottom).offset(3)
            make.bottom.equalTo(-14)
        }

        tapButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.openPhoto()
            })
            .disposed(by: disposeBag)
    }

    func hiddenOwnerLabel() {
        ownerLabel.isHidden = true
        contactIcon.isHidden = true
        disclaimerContent.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(14)
            make.bottom.equalTo(-14)
        }
    }

    func displayOwnerLabel() {
        ownerLabel.isHidden = false
        contactIcon.isHidden = false
        disclaimerContent.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(ownerLabel.snp.bottom).offset(3)
            make.bottom.equalTo(-14)
        }
    }

    fileprivate func openPhoto() {
        if self.headerImages.count > 0 {
            // 创建图片浏览器
            let browser = FHPhotoBrowser(photoLoader: BDWebImagePhotoLoader())
            // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
            // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleccccNoHiding`。
            browser.animationType = .scaleNoHiding
            // 浏览器协议实现者
            browser.photoBrowserDelegate = self
            // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
            // 光点型页码指示器
            //    browser.plugins.append(DefaultPageControlPlugin())
            // 数字型页码指示器cccc
            let numberPageControlPlugin = RentHouseNumberPageControlPlugin()
            numberPageControlPlugin.traceParams = self.traceParam
//            numberPageControlPlugin.images = self.headerImages

//            numberPageControlPlugin.largeTracer = largeImageTracerGen(images: self.headerImages, traceParams: traceParams)
            numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
            browser.plugins.append(numberPageControlPlugin)
            browser.cellPlugins = [RawImageButtonPlugin()]
            let plugin = RentPhotoBrowserShowAllPlugin(titles: headerImages.map { $0.name ?? "" } )
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
}

fileprivate class RentHouseNumberPageControlPlugin: HouseNumberPageControlPlugin {
    open override func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        currentPageRelay.accept(index)
    }
}

fileprivate class RentPhotoBrowserShowAllPlugin: PhotoBrowserShowAllPlugin {
    private var titles: [String]
    init(titles: [String]) {
        self.titles = titles
    }

    override func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        if titles.count > index {
            self.overlayView.imageNameLabel.text = titles[index]
        }
    }

}


extension FHRentDisclaimerCell: PhotoBrowserDelegate {
    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: JXPhotoBrowser.PhotoBrowser) -> Int {
        return headerImages.count
    }

    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      thumbnailImageForIndex index: Int) -> UIImage? {

        if index >= headerImages.count { return nil}
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url ?? "")
        let key = BDWebImageManager.shared().requestKey(with: url)
        return BDImageCache.shared().image(forKey: key)
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      highQualityUrlForIndex index: Int) -> URL? {
        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url ?? "")
        return url
    }

    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser,
                      localImageForIndex index: Int) -> UIImage? {

        if index >= headerImages.count { return nil }
        let imageModel = headerImages[index]
        let url = URL(string: imageModel.url ?? "")
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

func parseRentDisclaimerCellNode(model: FHRentDetailResponseDataModel?) -> () -> TableSectionNode? {
    let render = curry(fillRentDisclaimerCell)(model)
    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHRentDisclaimerCell.identifier))
    }
}

func fillRentDisclaimerCell(model: FHRentDetailResponseDataModel?, cell: BaseUITableViewCell) {
    if let theCell = cell as? FHRentDisclaimerCell {
        theCell.disclaimerContent.text = model?.disclaimer?.text
        if let contact = model?.contact,
            let realtorName = contact.realtorName,
            !realtorName.isEmpty {
            theCell.displayOwnerLabel()
            theCell.ownerLabel.text = "房屋负责人：\(realtorName)"
            var headerImages = [FHRentDetailResponseDataHouseImageModel]()
            if let businessLicense = model?.contact?.businessLicense,
                !businessLicense.isEmpty {
                let imageModel = FHRentDetailResponseDataHouseImageModel()
                imageModel.url = businessLicense
                imageModel.name = "营业执照"
                headerImages.append(imageModel)
            }
            if let certificate = model?.contact?.certificate,
                !certificate.isEmpty {
                let imageModel = FHRentDetailResponseDataHouseImageModel()
                imageModel.url = certificate
                imageModel.name = "从业人员信息卡"
                headerImages.append(imageModel)
            }
            if headerImages.count > 0 {
                theCell.headerImages = headerImages
                theCell.contactIcon.isHidden = false
            } else {
                //隐藏经济负责人营业执照
                theCell.contactIcon.isHidden = true
            }
        } else {
            theCell.hiddenOwnerLabel()
        }
    }
}
