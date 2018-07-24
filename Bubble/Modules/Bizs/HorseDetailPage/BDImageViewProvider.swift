//
// Created by linlin on 2018/6/29.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

class BDImageViewProvider: PageViewProvider {

    var isActivite: Bool = false

    var index: Int = 0

    weak var pageableViewModel: PageableViewModel?

    var imageSelector: ((Int) -> String)?

    var imageRequest: BDWebImageRequest?

    lazy private var imageView: UIImageView = {
        UIImageView()
    }()

    init(imageSelector: ((Int) -> String)? = nil) {
        self.imageSelector = imageSelector
    }

    func pageView(pageableView: UIScrollView, pageableViewModel: PageableViewModel) -> UIView {
        self.pageableViewModel = pageableViewModel
        return imageView
    }

    func reloadData(by index: Int, forceUpdate: Bool) {
        if self.index != index {
            self.index = index
            reloadData()
        }
    }

    func reloadData() {
        if let urlStr = imageSelector?(index) {
            imageView.tag = index
            imageRequest = imageView.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        }
    }

    func activate() {

    }

    func deActivate() {

    }

}
