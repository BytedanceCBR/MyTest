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

        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.datas.accept([])
            return
        }

        let loader = pageRequestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId, count: 15, query: "")
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    if let hasMore = response?.data?.hasMore {
                        self.onDataLoaded?(hasMore, response?.data?.items?.count ?? 0)
                    }
                    if let data = response?.data {
                        return parseNeighborhoodRowItemNode(data.items ?? [], disposeBag: self.disposeBag, navVC: self.navVC)
                    } else {
                        return []
                    }
                }
                .subscribe(onNext: { [unowned self] (datas) in
                    self.datas.accept(self.datas.value + datas)
                })
                .disposed(by: self.disposeBag)
        }
//        cleanData()
        pageableLoader?()
    }
    
}
