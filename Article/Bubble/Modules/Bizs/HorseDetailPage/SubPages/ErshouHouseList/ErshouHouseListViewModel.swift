//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum ErshouHouseResult : Int {
    case Success
    case NoData
    case BadData  //数据错误
}

class ErshouHouseListViewModel: BaseSubPageViewModel, TableViewTracer {
    
    var title = BehaviorRelay<String>(value: "")
    var onSuccess: ((ErshouHouseResult) -> Void)?
    var oneTimeToast: ((String?) -> Void)?
    
    var onError: ((Error?) -> Void)?

    var searchId: String?
    
    var sameNeighborhoodFollowUp: BehaviorRelay<Result<Bool>>?

    var traceParams = TracerParams.momoid()
    
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

    func displayDefaultPlaceholder() {
        self.datas.accept(parseHousePlaceholderRowNode(nodeCount: 10)())
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView?.reloadData()
        }
    }

    func request(neightborhoodId: String? = nil, houseId: String? = nil) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestHouseInSameNeighborhoodSearch(
            neighborhoodId: neightborhoodId,
            houseId: houseId,
            searchId: searchId,
            count: 15)
        var isFirstLoad = true
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    if isFirstLoad {
                        isFirstLoad = false
                        self.cleanData()
                    }
                    var result = ErshouHouseResult.Success
                    if response == nil {
                        result = ErshouHouseResult.BadData
                    }
                    
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
                    
                    if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                        result = ErshouHouseResult.NoData
                    }

                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    self.onSuccess?(result)
                    // self.oneTimeToast?(response?.data?.refreshTip)
                    
                    },
                    onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()
    }

    
    func requestErshouHouseList(query: String, condition: String?) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }

        var isFirstLoad = true
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestErshouHouseSearch(query: query, searchId: searchId , suggestionParams: condition ?? "")
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(
                    onNext: { [unowned self] (response) in
                        if isFirstLoad {
                            isFirstLoad = false
                            self.cleanData()
                        }
                        var result = ErshouHouseResult.Success
                        if response == nil {
                            result = ErshouHouseResult.BadData
                        }
                        
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
                            
                            self.searchId = data.searchId
                            
                        }
                        else {
                            
                        }
                        
                        if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                            result = ErshouHouseResult.NoData
                        }
                        
                        self.title.accept("(\(response?.data?.total ?? 0))")
                        self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                        self.onSuccess?(result)
                        // self.oneTimeToast?(response?.data?.refreshTip)
                    },
                    onError: { [weak self] in
                        self?.processError()
                        
                        }())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()
    }

    //这个接口被两个问题调用，因此不能添加enter_from买点
    func requestRent(neightborhoodId: String? = nil, houseId: String? = nil) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        var isFirstload = true
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestRentInSameNeighborhoodSearch(neighborhoodId: neightborhoodId,houseId: houseId, searchId: searchId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    if isFirstload {
                       isFirstload = false
                        self.cleanData()
                    }
                    var result = ErshouHouseResult.Success
                    if response == nil {
                        result = ErshouHouseResult.BadData
                    }
                    
                    if let data = response?.data {
                        let items = data.items?.map({ (item) -> RentInnerItemEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })

                        let params = TracerParams.momoid() <|>
                            toTracerParams("be_null", key: "element_type") <|>
                            self.traceParams
                        let datas = parseRentHouseListRowItemNode(
                            items,
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            sameNeighborhoodFollowUp: self.sameNeighborhoodFollowUp,
                            houseSearchParams: nil,
                            navVC: self.navVC)
                        self.datas.accept(self.datas.value + datas)
                        
                        self.searchId = data.searchId
                    }
                    
                    if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                        result = ErshouHouseResult.NoData
                    }
                    
                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    self.onSuccess?(result)
                    // self.oneTimeToast?(response?.data?.refreshTip)
                    
                    },
                           onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()
        
    }

    //这个接口被两个问题调用，因此不能添加enter_from买点
    // 租房周边房源
    func requestRelatedRent(query: String? = "", neightborhoodId: String? = nil, houseId: String? = nil) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        var isFirstload = true
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestRelatedRent(query: query, neighborhoodId: neightborhoodId, houseId: houseId, searchId: searchId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in

                    if isFirstload {
                        isFirstload = false
                        self.cleanData()
                    }
                    var result = ErshouHouseResult.Success
                    if response == nil {
                        result = ErshouHouseResult.BadData
                    }

                    if let data = response?.data {
                        let items = data.items?.map({ (item) -> RentInnerItemEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            return newItem
                        })

                        let params = TracerParams.momoid() <|>
                            toTracerParams("be_null", key: "element_type") <|>
                            self.traceParams <|>
                            toTracerParams("rent_detail", key: "enter_from") <|>
                            toTracerParams("related", key: "element_from") <|>
                            toTracerParams("related_list", key: "page_type")
                        let datas = parseRentHouseListRowItemNode(
                            items,
                            traceParams: params,
                            disposeBag: self.disposeBag,
                            sameNeighborhoodFollowUp: self.sameNeighborhoodFollowUp,
                            houseSearchParams: nil,
                            navVC: self.navVC)
                        self.datas.accept(self.datas.value + datas)

                        self.searchId = data.searchId
                    }

                    if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                        result = ErshouHouseResult.NoData
                    }

                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    self.onSuccess?(result)
                    // self.oneTimeToast?(response?.data?.refreshTip)

                    },
                           onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()

    }
    
    func requestRentHouseList(query: String, condition: String?) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        oneTimeToast = createOneTimeToast()
        var isFirstLoad = true
        let loader = pageRequestRentInSameNeighborhoodSearch(query: query, neighborhoodId: nil, houseId: nil, searchId: nil, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(
                    onNext: { [unowned self] (response) in
                        if isFirstLoad {
                            isFirstLoad = false
                            self.cleanData()
                        }
                        var result = ErshouHouseResult.Success
                        if response == nil {
                            result = ErshouHouseResult.BadData
                        }
                        
                        if let data = response?.data {
                            let items = data.items?.map({ (item) -> RentInnerItemEntity in
                                var newItem = item
                                newItem.fhSearchId = data.searchId
                                return newItem
                            })
                            let params = TracerParams.momoid() <|>
                                toTracerParams("be_null", key: "element_type") <|>
                                toTracerParams("rent_detail", key: "enter_from") <|>
                                toTracerParams("related_list", key: "page_type") <|>
                                toTracerParams("rent", key: "house_type")
                            
                            let datas = parseRentHouseListRowItemNode(
                                items,
                                traceParams: params,
                                disposeBag: self.disposeBag,
                                sameNeighborhoodFollowUp: self.sameNeighborhoodFollowUp,
                                houseSearchParams: nil,
                                navVC: self.navVC)
                            self.datas.accept(self.datas.value + datas)
                            
                            self.searchId = data.searchId
                        } else {
                            
                        }
                        
                        if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                            result = ErshouHouseResult.NoData
                        }
                        
                        self.title.accept("(\(response?.data?.total ?? 0))")
                        self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                        self.onSuccess?(result)
                        // self.oneTimeToast?(response?.data?.refreshTip)
                    },
                    onError: { [weak self] in
                        self?.processError()
                        
                        }())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()
    }
    
    
    func requestRelatedHouse( houseId: String? = nil) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        var isFirstLoad = true
        oneTimeToast = createOneTimeToast()
        let loader = pageRequestRelatedHouse(query: nil, houseId: houseId, searchId: self.searchId, condition: nil, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (response) in
                    if isFirstLoad {
                        isFirstLoad = false
                        self.cleanData()
                    }
                    var result = ErshouHouseResult.Success
                    if response == nil && self.datas.value.count == 0 {
                        result = ErshouHouseResult.BadData
                    }
                    
                    if let data = response?.data {
                        var ht : HouseType?
                        let items = data.items?.map({ (item) -> HouseItemInnerEntity in
                            var newItem = item
                            newItem.fhSearchId = data.searchId
                            ht = HouseType(rawValue: item.houseType ?? 0)
                            return newItem
                        })
                        
                        if ht == nil {
                            ht = HouseType.secondHandHouse
                        }
                        
                        var htName : String? = nil
                        if ht == HouseType.rentHouse {
                            htName = "rent"
                        }

                        var pageType: String?
                        if ht == HouseType.rentHouse {
                            pageType = "rent_deta"
                        } else {
                            //修复买点错误，35二手房周边房源列表
                            pageType = "related_list"
                        }
                        let params = TracerParams.momoid() <|>
                            toTracerParams("be_null", key: "element_type") <|>
                            toTracerParams("related_list", key: "enter_from") <|>
                            toTracerParams(pageType ?? "be_null", key: "page_type") <|>
                            toTracerParams(htName ?? "old", key: "house_type")
                        
                        //           parseErshouRelatedHouseListItemNode
                        let datas = parseRelatedHouseListItemNode(
                            items,
                            disposeBag: self.disposeBag,
                            tracerParams: params ,
                            navVC: self.navVC)
                        
                        self.datas.accept(self.datas.value + datas)
                        
                        self.searchId = data.searchId
                    }
                    
                    /*
                     func parseFHHomeErshouHouseListItemNode(
                     _ data: [HouseItemInnerEntity]?,
                     traceExtension: TracerParams = TracerParams.momoid(),
                     disposeBag: DisposeBag,
                     tracerParams: TracerParams,
                     navVC: UINavigationController?) -> () -> TableSectionNode? {
                     */
                    
                    if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                        result = ErshouHouseResult.NoData
                    }
                    
                    self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                    self.onSuccess?(result)
                    // self.oneTimeToast?(response?.data?.refreshTip)
                    
                    },
                           onError: self.processError())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
        pageableLoader?()
        
    }
    
    func requestRelatedHouseList(query: String,houseId: String, condition: String?) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            self.processError()(nil)
            return
        }
        oneTimeToast = createOneTimeToast()
        var isFirstLoad = true
        let loader = pageRequestRelatedHouse(query: query, houseId: houseId, searchId: self.searchId, count: 20)
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(
                    onNext: { [unowned self] (response) in
                        if isFirstLoad {
                            isFirstLoad = false
                            self.cleanData()
                        }
                        var result = ErshouHouseResult.Success
                        if response == nil {
                            result = ErshouHouseResult.BadData
                        }
                        
                        if let data = response?.data {
                            let items = data.items?.map({ (item) -> HouseItemInnerEntity in
                                var newItem = item
                                newItem.fhSearchId = data.searchId
                                return newItem
                            })
                            let params = TracerParams.momoid()
                            let datas = parseErshouRelatedHouseListItemNode(
                                items,
                                disposeBag: self.disposeBag,
                                tracerParams: params ,
                                navVC: self.navVC)
                            
                            self.datas.accept(self.datas.value + datas)
                            
                            self.searchId = data.searchId
                        }
                        
                        if(self.datas.value.count == 0 && result != ErshouHouseResult.BadData){
                            result = ErshouHouseResult.NoData
                        }
                        
                        self.title.accept("(\(response?.data?.total ?? 0))")
                        self.onDataLoaded?(response?.data?.hasMore ?? false, self.datas.value.count)
                        self.onSuccess?(result)
                        // self.oneTimeToast?(response?.data?.refreshTip)
                    },
                    onError: { [weak self] in
                        self?.processError()
                        
                        }())
                .disposed(by: self.disposeBag)
        }
        displayDefaultPlaceholder()
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


func parseRelatedHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    traceExtension: TracerParams = TracerParams.momoid(),
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) ->  [TableRowNode] {
    
    var traceParmas = tracerParams.paramsGetter([:])
    var elementFrom: String = "related"
    if let elementFromV = (traceParmas["element_from"] ?? elementFrom) as? String
    {
        elementFrom = elementFromV
    }
    
    let selectors = data?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> (TracerParams) -> Void in
            let (offset, item) = e
            return openErshouHouseDetailPage(
                houseId: Int64(item.id ?? "")!,
                logPB: item.logPB,
                disposeBag: disposeBag,
                tracerParams: tracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams("be_null", key: "element_from") <|>
                    toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                    toTracerParams("related_list",key: "enter_from"),
                navVC: navVC)
    }
    
    let paramsElement = TracerParams.momoid() <|>
        toTracerParams("related", key: "element_type") <|>
        toTracerParams("related_list", key: "page_type") <|>
    traceExtension
    
    var records = data?
        .filter {
            $0.id != nil
        }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (offset, item) = e
            let theParams = tracerParams <|>
                toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.cellstyle == 1 ? "three_pic" : "left_pic", key: "card_type") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb")
            let finalParams = theParams
                .exclude("element_from")
                .exclude("enter_from")
            
            return onceRecord(key: TraceEventName.house_show, params: finalParams)
    }
    records?.insert(elementShowOnceRecord(params:paramsElement), at: 0)
    
    let count = data?.count ?? 0
    
    if let renders = data?.enumerated().map( { (index, item) in
        data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
        //        curry(fillErshouHouseListitemCell)(item)(index == count - 1)
    }),
        let selectors = selectors,
        let records = records {
        let items = zip(selectors, records)
        
        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                tracer: item.1,
                type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier),
                editor: nil)
        }
    } else {
        return []
    }
    
    //    if let renders = data?.enumerated().map({ (index, item) in
    //        data?.first?.cellstyle == 1 ? curry(fillMultiHouseItemCell)(item)(index == count - 1)(false) : curry(fillErshouHouseListitemCell)(item)(index == count - 1)
    //    }), let selectors = selectors ,count != 0 {
    //        return TableSectionNode(
    //            items: renders,
    //            selectors: selectors,
    //            tracer: records,
    //            sectionTracer: nil,
    //            label: "",
    //            type: .node(identifier:data?.first?.cellstyle == 1 ? FHMultiImagesInfoCell.identifier : SingleImageInfoCell.identifier)) //to do，ABTest命中整个section，暂时分开,默认单图模式
    //    } else {
    //        return []
    //    }
    
}
