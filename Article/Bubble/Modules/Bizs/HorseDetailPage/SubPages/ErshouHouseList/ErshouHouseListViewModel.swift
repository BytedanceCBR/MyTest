//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation


class ErshouHouseListViewModel: BaseSubPageViewModel {
//    func request(neightborhoodId: String) {
//        let loader = pageRequestRelatedNeighborhoodSearch(neighborhoodId: neighborhoodId, query: "")
//        pageableLoader = { [unowned self] in
//            loader()
//                    .map { [unowned self] response -> [TableRowNode] in
//                        if let count = response?.data?.items?.count {
//                            self.onDataLoaded?(count >= 15)
//                        }
//                        if let data = response?.data {
//                            return parseNeighborhoodRowItemNode(data.items ?? [], disposeBag: self.disposeBag)
//                        } else {
//                            return []
//                        }
//                    }
//                    .subscribe(onNext: { [unowned self] (datas) in
//                        self.datas.accept(self.datas.value + datas)
//                    })
//                    .disposed(by: self.disposeBag)
//        }
//        cleanData()
//        pageableLoader?()
//    }

    func request(neightborhoodId: String? = nil, houseId: String? = nil) {
        let loader = pageRequestHouseInSameNeighborhoodSearch(neighborhoodId: neightborhoodId, houseId: houseId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let count = response?.data?.items.count {
                            self.onDataLoaded?(count >= 15)
                        }
                        if let data = response?.data {
                            return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
//                            return parseNeighborhoodRowItemNode(data.items ?? [], disposeBag: self.disposeBag)
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

    func requestErshouHouseList(query: String, condition: String?) {
        let loader = pageRequestErshouHouseSearch(query: query, suggestionParams: condition ?? "")
        pageableLoader = { [unowned self] in
            loader()
                .map { [unowned self] response -> [TableRowNode] in
                    if let data = response?.data {
                        return parseErshouHouseListRowItemNode(data.items, disposeBag: self.disposeBag, navVC: self.navVC)
                    } else {
                        return []
                    }
                }
                .subscribe(
                    onNext: { [unowned self] (datas) in
                        self.datas.accept(self.datas.value + datas)
                    },
                    onError: { error in
                        print(error)
                })
                .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

}
