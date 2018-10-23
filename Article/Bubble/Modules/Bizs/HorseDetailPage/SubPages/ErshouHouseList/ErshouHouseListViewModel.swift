//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ErshouHouseListViewModel: BaseSubPageViewModel, TableViewTracer {
    
    var title = BehaviorRelay<String>(value: "")
    var onSuccess: ((Bool) -> Void)?
    var oneTimeToast: ((String?) -> Void)?
    
    var onError: ((Error?) -> Void)?

    var searchId: String?
    
    var sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>?

    func createOneTimeToast() -> (String?) -> Void {
        var hasToast = false
        return { (message) in
            EnvContext.shared.toast.dismissToast()
            if !hasToast, let message = message {
                EnvContext.shared.toast.showToast(message)
                hasToast = true
            }
        }
    }
    
    func request(neightborhoodId: String? = nil, houseId: String? = nil) {
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestHouseInSameNeighborhoodSearch(
            neighborhoodId: neightborhoodId,
            houseId: houseId,
            searchId: searchId,
            count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    
                    if let data = response?.data {
                        
                        let items = data.items.map({ (item) -> HouseItemInnerEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })
                        let params = TracerParams.momoid()
                        let datas = parseErshouHouseListRowItemNode(
                            items,
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            sameNeighborhoodFollowUp: self.sameNeighborhoodFollowUp,
                            houseSearchParams: nil,
                            navVC: self.navVC)
                        self.datas.accept(self.datas.value + datas)
                    }

                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    self.oneTimeToast?(response?.data?.refreshTip)
                    
                    },
                    onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    
    func requestErshouHouseList(query: String, condition: String?) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        EnvContext.shared.toast.showLoadingToast("正在加载")
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestErshouHouseSearch(query: query, searchId: searchId , suggestionParams: condition ?? "")
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(
                    onNext: { [unowned self] (response) in
                        if let data = response?.data {
                            
                            let theDatas = data.items?.map({ (item) -> HouseItemInnerEntity in
                                var newItem = item
                                newItem.fhSearchId = data.searchId
                                return newItem
                            })
                            
                            let params = TracerParams.momoid() <|>
                                toTracerParams("same_neighborhood", key: "element_type") <|>
                                toTracerParams("same_neighborhood_list", key: "enter_from") <|>
                                toTracerParams("same_neighborhood_list", key: "page_type")
                            let datas = parseErshouHouseListRowItemNode(
                                theDatas,
                                traceParams: params,
                                disposeBag: self.disposeBag,
                                sameNeighborhoodFollowUp: self.sameNeighborhoodFollowUp,
                                houseSearchParams: nil,
                                navVC: self.navVC)
                            self.datas.accept(self.datas.value + datas)
                        }
                        else {
                            
                        }
                        self.title.accept("(\(response?.data?.total ?? 0))")
                        self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                        self.onSuccess?(self.datas.value.count != 0)
                        self.oneTimeToast?(response?.data?.refreshTip)
                    },
                    onError: { [weak self] in
                        self?.processError()
                        
                        }())
                .disposed(by: self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < datas.value.count {
            let params = EnvContext.shared.homePageParams <|>
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
