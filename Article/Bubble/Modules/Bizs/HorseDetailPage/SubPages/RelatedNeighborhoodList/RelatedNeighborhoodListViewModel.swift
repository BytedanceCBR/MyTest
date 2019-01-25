//
//  RelatedNeighborhoodListViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation

class RelatedNeighborhoodListViewModel: BaseSubPageViewModel, TableViewTracer {
    var onError: ((Error?) -> Void)?
    
    var onSuccess: ((Bool) -> Void)?

    var searchId: String?
    
    var tracerParams = TracerParams.momoid()
    
    func request(neighborhoodId: String) {
        
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.datas.accept([])
            return
        }
        
        let loader = pageRequestRelatedNeighborhoodSearch(
            neighborhoodId: neighborhoodId,
            searchId: searchId,
            count: 15,
            query: "")
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    if let data = response?.data {
                        let params = self.tracerParams <|>
                            toTracerParams("neighborhood_nearby_list", key: "page_type") <|>
                            toTracerParams("neighborhood_nearby_list", key: "enter_from") <|>
                            toTracerParams("neighborhood_nearby", key: "element_type")
                        self.onSuccess?(true)
                        EnvContext.shared.toast.dismissToast()
                        
                        let theDatas = data.items?.map({ (item) -> NeighborhoodInnerItemEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })
                        let datas = parseNeighborhoodRowItemNode(
                            theDatas ?? [],
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            houseSearchParams: nil,
                            navVC: self.navVC)
                        self.datas.accept(self.datas.value + datas)
                        
                    }
                    else {
                        self.onSuccess?(false)
                        EnvContext.shared.toast.dismissToast()
                        
                    }
                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    
                    },
                           onError: { [weak self] error in
                            self?.tableView?.mj_footer.endRefreshing()  
                            self?.onError?(error)
                })
                .disposed(by: self.disposeBag)
        }
        //        cleanData()
        pageableLoader?()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < datas.value.count {
            let params = TracerParams.momoid() <|>
                toTracerParams(indexPath.row, key: "rank")
            callTracer(tracer: datas.value[indexPath.row].tracer, traceParams: params)
        }
        if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == datas.value.count - 1 {
            return 125
        }
        return 105
    }

    
}
