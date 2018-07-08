//
//  CycleImageCell.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class CycleImageCell: BaseUITableViewCell {

    private var pageableViewModel: PageableViewModel?

    open override class var identifier: String {
        return "CycleImage"
    }

    fileprivate var headerImages: [ImageModel] = [] {
        didSet {
            pageableViewModel?.reloadData(currentPageOnly: false)
        }
    }




    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupPageableViewModel { [weak self] i in
            return self?.selectHeaderView(index: i) ?? ""
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPageableViewModel(cycleImageSelector: @escaping ((Int) -> String)) {
        pageableViewModel = PageableViewModel(cacheViewCount: 5) {
            return BDImageViewProvider(imageSelector: cycleImageSelector)
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

fileprivate struct ImageModel {
    let url: String
    let category: String
}

func parseNewHouseCycleImageNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        let imageItems = newHouseData.imageGroup?.map({ (group) -> ImageModel in
            if let name = group.name, let url = group.images?.first?.url {
                return ImageModel(url: url, category: name)
            } else {
                return ImageModel(url: "", category: "")
            }
        })

        let cellRender = curry(fillCycleImageCell)(imageItems ?? [])
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseErshouHouseCycleImageNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        let imageItems = ershouHouseData.houseImage?.map({ (image) -> ImageModel in
            if let url = image.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
        })
        let cellRender = curry(fillCycleImageCell)(imageItems ?? [])
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

func parseCycleImageNode(_ images: [ImageItem]?) -> () -> TableSectionNode? {
    return {
        let imageItems = images?.map { (item) -> ImageModel in
            if let url = item.url {
                return ImageModel(url: url, category: "")
            } else {
                return ImageModel(url: "", category: "")
            }
         }
        if imageItems == nil || imageItems?.count == 0 {
            return nil
        }
        let cellRender = curry(fillCycleImageCell)(imageItems ?? [])
        return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                label: "",
                type: .node(identifier: CycleImageCell.identifier))
    }
}

fileprivate func fillCycleImageCell(_ images: [ImageModel], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        theCell.headerImages = images
    }
}
