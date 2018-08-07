//
//  PictureCategoryListVC.swift
//  News
//
//  Created by leo on 2018/7/29.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import JXPhotoBrowser
class PictureCategoryListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(backBtnImg: #imageLiteral(resourceName: "icon-return"))
        re.removeGradientColor()
        return re
    }()

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 78, height: 78)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        let result = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        result.backgroundColor = UIColor.clear
        return result
    }()

    let selectIndex = BehaviorRelay<Int?>(value:nil)

    let items = BehaviorRelay<[PictureCategorySection]>(value: [])

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "item")
        collectionView.register(
            PhotoSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = UIColor.white
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.right.left.bottom.equalToSuperview()
        }
        items
                .bind(onNext: { [unowned self] _ in self.collectionView.reloadData() })
                .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - photoBrowser

    func openBrowser(index: Int) {
        // 创建图片浏览器
        let browser = PhotoBrowser(photoLoader: BDWebImagePhotoLoader())
        // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
        // 如果希望`scale`动画不要隐藏关联缩略图，可使用`.scaleNoHiding`。
        browser.animationType = .scale
        // 浏览器协议实现者
        browser.photoBrowserDelegate = self

        let numberPageControlPlugin = NumberPageControlPlugin()
        numberPageControlPlugin.centerY = UIScreen.main.bounds.height - 10
        browser.plugins.append(numberPageControlPlugin)
//        // 装配附加视图插件
//        setupOverlayPlugin(on: browser, index: index)
        // 指定打开图片组中的哪张
        browser.originPageIndex = index
        // 展示
        browser.show()

        
    }

    //MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.value[section].items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath)
        if let theCell = cell as? CollectionCell {
            theCell.imageView.bd_setImage(
                    with: URL(string: items.value[indexPath.section].items[indexPath.row]),
                    placeholder: #imageLiteral(resourceName: "default_image"))
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        if let theHeaderView = headerView as? PhotoSectionHeader {
            theHeaderView.label.text = "\(items.value[indexPath.section].name)(\(items.value[indexPath.section].items.count))"
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = getIndexByIndexPath(sections: items.value, indexPath: indexPath)
        
        self.selectIndex.accept(index)
        self.dismiss(animated: true, completion: nil)

    }
}

fileprivate class CollectionCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
            maker.width.height.equalTo(78)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}


struct PictureCategorySection {
    let name: String
    let items: [String]
}

extension PictureCategoryListVC: PhotoBrowserDelegate {
    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: JXPhotoBrowser.PhotoBrowser) -> Int {
        return items.value.reduce(0) { (result, section) in
            return result + section.items.count
        }
    }

    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        let (sectionIndex, offset) = getSectionOfImageIndex(sections: items.value, index: index)
        let cell = collectionView.cellForItem(at: IndexPath(row: offset, section: sectionIndex))
        if let theCell = cell as? CollectionCell {
            return theCell.imageView.image
        }
        return nil
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        let (sectionIndex, offset) = getSectionOfImageIndex(sections: items.value, index: index)
        return URL(string: items.value[sectionIndex].items[offset])
    }

    func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
//        let (sectionIndex, offset) = getSectionOfImageIndex(sections: items.value, index: index)
//        let cell = collectionView.cellForItem(at: IndexPath(row: offset, section: sectionIndex))
//        if let theCell = cell as? CollectionCell {
//            return theCell.imageView.image
//        }
        return nil
    }

    public func photoBrowser(_ photoBrowser: JXPhotoBrowser.PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        let (sectionIndex, offset) = getSectionOfImageIndex(sections: items.value, index: index)
        return collectionView.cellForItem(at: IndexPath(row: offset, section: sectionIndex))
    }

}

fileprivate func getSectionOfImageIndex(sections: [PictureCategorySection], index: Int) -> (Int, Int) {
    var offset = index
    let sectionIndex = sections.index { section in
        if section.items.count > offset {
            return true
        } else {
            offset = offset - section.items.count
            return false
        }
    }
    return (sectionIndex ?? 0, offset)
}

func getIndexByIndexPath(sections: [PictureCategorySection], indexPath: IndexPath) -> Int {
    return sections
        .enumerated()
        .map({ (e) -> Int in
            let (offset, section) = e
            if offset < indexPath.section {
                return section.items.count
            } else if offset == indexPath.section {
                return indexPath.row
            }
            return 0
        })
        .reduce(0, { (result, count) -> Int in
            result + count
        })
 }


fileprivate class PhotoSectionHeader: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(24)
            maker.bottom.equalTo(-14)
            maker.right.equalTo(-15)
            maker.left.equalTo(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

