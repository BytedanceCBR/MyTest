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
class CycleImageCell: BaseUITableViewCell {

    private var pageableViewModel: PageableViewModel?

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
                pageableViewModel.pageView.isUserInteractionEnabled = headerImages.count > 1
                pictureDisposeBag = DisposeBag()
                tapGesture.rx.event
                        .withLatestFrom(pageableViewModel.currentPage.asObservable())
                        .bind(onNext: { [unowned self] in
                            self.openPictureBrowser?($0, self)
                        })
                        .disposed(by: pictureDisposeBag!)
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupPageableViewModel { [weak self] i in
            return self?.selectHeaderView(index: i) ?? ""
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
        pageableViewModel = PageableViewModel(cacheViewCount: 5) {
            let re = BDImageViewProvider(imageSelector: cycleImageSelector)
            return re
        }
        if let pageableViewModel = pageableViewModel {
            pageableViewModel.pageView.isUserInteractionEnabled = true

            contentView.addSubview(pageableViewModel.pageView)
            pageableViewModel.pageView.snp.makeConstraints { maker in
                maker.left.right.top.bottom.equalToSuperview()
                maker.height.equalTo(247)
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

fileprivate func openPictureBrowser(pictures: [PictureCategorySection], disposeBag: DisposeBag, selectedIndex: Int) {
    let vc = PictureCategoryListVC()
    vc.navBar.title.text = "楼盘相册"
    vc.items.accept(pictures)
    vc.navBar.backBtn.rx.tap
        .subscribe(onNext: { void in
            EnvContext.shared.rootNavController.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
    EnvContext.shared.rootNavController.pushViewController(vc, animated: true)
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
    // 光点型页码指示器
//    browser.plugins.append(DefaultPageControlPlugin())
    // 数字型页码指示器
    let numberPageControlPlugin = NumberPageControlPlugin()
    numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 30
    browser.plugins.append(numberPageControlPlugin)
//        // 装配附加视图插件
//        setupOverlayPlugin(on: browser, index: index)
    // 指定打开图片组中的哪张
    browser.originPageIndex = selectedIndex
    // 展示
    browser.show()
}

fileprivate struct ImageModel {
    let url: String
    let category: String
}

func parseNewHouseCycleImageNode(_ newHouseData: NewHouseData, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {

        let cellRender = curry(fillCycleImageCell)(newHouseData.imageGroup)(disposeBag)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseErshouHouseCycleImageNode(_ ershouHouseData: ErshouHouseData, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let imageItems = ershouHouseData.houseImage?.map({ (image) -> ImageModel in
            if let url = image.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
        })
        let cellRender = curry(fillErshouHouseCycleImageCell)(imageItems ?? [])(disposeBag)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseCycleImageNode(_ images: [ImageItem]?, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let imageItems = images?.map { (item) -> ImageModel in
            if let url = item.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
         }
        let cellRender = curry(fillErshouHouseCycleImageCell)(imageItems ?? [])(disposeBag)
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

fileprivate func fillErshouHouseCycleImageCell(_ images: [ImageModel], disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        theCell.headerImages = images
        theCell.count = images.count
        var dataSource: PictureBrowserDataSource?
        theCell.openPictureBrowser = { (index, view) in
            let theDataSource = PictureBrowserDataSource(pictures: images.map { $0.url }, target: view)
            dataSource = theDataSource
            openPictureBrowser(dataSource: theDataSource, disposeBag: disposeBag, selectedIndex: index)
        }
    }
}

fileprivate func fillCycleImageCell(_ imageGroups: [ImageGroup]?, disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        let imageItems = imageGroups?.map({ (group) -> ImageModel in
            if let name = group.name, let url = group.images?.first?.url {
                return ImageModel(url: url, category: name)
            } else {
                return ImageModel(url: "", category: "")
            }
        })


        theCell.headerImages = imageItems ?? []
        theCell.count = imageItems?.count ?? 0
        theCell.openPictureBrowser = { (index, view) in
            let pictures = imageGroups?.map { (group) -> PictureCategorySection in
                let urls = group.images?.filter { $0.url != nil }.map { $0.url! }
                return PictureCategorySection(name: group.name ?? "", items: urls ?? [])
            }
            openPictureBrowser(pictures: pictures ?? [], disposeBag: disposeBag, selectedIndex: index)
        }
    }
}

fileprivate class PictureBrowserDataSource: NSObject, PhotoBrowserDelegate {

    let pictures: [String]

    let target: UIView

    init(pictures: [String], target: UIView) {
        self.pictures = pictures
        self.target = target
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
        return BDImageCache.shared().image(forKey: key)
    }

    public func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return target
    }
}
