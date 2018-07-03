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

    fileprivate var headerImages: [ImageGroup] = [] {
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
            if let url = headerImages[offset].images?.first?.url {
                return url
            } else {
                return ""
            }
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

func parseNewHouseCycleImageNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode? {
    return {
        let cellRender = curry(fillCycleImageCell)(newHouseData.imageGroup ?? [])
        return TableSectionNode(items: [cellRender], label: "", type: .node(identifier: CycleImageCell.identifier))
    }
}

func fillCycleImageCell(_ images: [ImageGroup], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
        theCell.headerImages = images
    }
}
