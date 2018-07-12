//
//  RelatedNeighborhoodListViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation

class RelatedNeighborhoodListViewModel: BaseSubPageViewModel {

    func request(neighborhoodId: String) {
        let loader = pageRequestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId, query: "")
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    if let count = response?.data?.items?.count {
                        self.onDataLoaded?(count > 15)
                    }
                    if let data = response?.data {
                        return parseNeighborhoodRowItemNode(data.items ?? [], disposeBag: self.disposeBag)
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: { [unowned self] (datas) in
                    self.datas.accept(self.datas.value + datas)
                })
                .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }
    
}
