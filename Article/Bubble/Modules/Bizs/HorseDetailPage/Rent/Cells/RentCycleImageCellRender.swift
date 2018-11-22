//
//  RentCycleImageCellRender.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation
import RxSwift
import RxCocoa
func parseRentHouseCycleImageNode(_ images: [ImageItem]?,
                                  disposeBag: DisposeBag) -> () -> TableSectionNode? {
    let cellRender = curry(fillRentHouseCycleImageCell)(images ?? [])(disposeBag)
    return {
        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: CycleImageCell.identifier))
    }
}


func fillRentHouseCycleImageCell(_ images: [ImageItem],
                                 disposeBag: DisposeBag,
                                 cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? CycleImageCell {
//        theCell.traceParams = traceParams
        theCell.count = images.count
//        theCell.smallTracer = theCell.smallImageTracerGen(images: images, traceParams: traceParams)
        theCell.headerImages = images.map { item in
            let model = ImageModel(url: item.url ?? "", category: "")
            return model
        }
    }
}
