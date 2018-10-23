//
// Created by leo on 2018/7/31.
//

import Foundation
import JXPhotoBrowser
class BDWebImagePhotoLoader: NSObject, PhotoLoader {
    public override init() {}

    open func isImageCached(on imageView: UIImageView, url: URL) -> Bool {
        let key = BDWebImageManager.shared().requestKey(with: url)
        let type = BDImageCache.shared().containsImage(forKey: key)
        return type == BDImageCacheType.all
    }

    open func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, progressBlock: @escaping (Int64, Int64) -> Void, completionHandler: @escaping () -> Void) {
        imageView.bd_setImage(with: url, placeholder: placeholder ?? UIImage(named: "combined-shape"), options: [], progress: { (request, receivedSize, totalSize) in
            progressBlock(Int64(receivedSize), Int64(totalSize))
        }) { (_, _, _, _, _) in
            completionHandler()
        }

    }
}
