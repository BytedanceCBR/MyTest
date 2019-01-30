//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import Reachability

class MyFavoriteListVC: BaseViewController, UITableViewDelegate {

    var hasMore: Bool

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        re.removeGradientColor()
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView()
//        re.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 11.0, *) {
//            re.estimatedRowHeight = 105
            re.estimatedRowHeight = 0
            re.estimatedSectionHeaderHeight = 0
            re.estimatedSectionFooterHeight = 0
        }

        re.separatorStyle = .none
        return re
    }()

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()

    private var categoryListVM: CategoryListViewModel?

    private let houseType: HouseType
    
    var tracerParams = TracerParams.momoid()
    
    var isChangeFromFollow: Bool?

    let disposeBag = DisposeBag()

    private var errorVM : NHErrorViewModel?

//    var stayTimeParams: TracerParams?

    init(houseType: HouseType) {
        self.houseType = houseType
        self.hasMore = true
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ttTrackStayEnable = true
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }
        setTitle(houseType: houseType)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }

        view.addSubview(emptyMaskView)
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(tableView)
        }
        

        categoryListVM = CategoryListViewModel(
            tableView: tableView,
            navVC: self.navigationController)

        setUpErrorVM()

        let footer: FHRefreshCustomFooter = FHRefreshCustomFooter { [weak self] in
            self?.loadMore()
        }
        
        tableView.mj_footer = footer
        footer.isHidden = true
        
        self.categoryListVM?.onDataLoaded = { [weak self] (hasMore, count) in
            
            self?.tableView.mj_footer.isHidden = false
            self?.hasMore = hasMore

            if hasMore == false {
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                self?.tableView.mj_footer.endRefreshing()
            }
            
            if count == 0, hasMore == false {
                self?.showEmptyMaskView()
            } else {
                self?.emptyMaskView.isHidden = true
            }
        }
        

        self.errorVM?.onRequestViewDidLoad()
        self.refreshRemoteData()

        NotificationCenter.default.rx.notification(.followUpDidChange)
            .subscribe(onNext: { [weak self] (_) in
                self?.isChangeFromFollow = true
                self?.refreshRemoteData()
            })
            .disposed(by: disposeBag)
        
        self.categoryListVM?.traceParams = self.tracerParams;
    }

    private func refreshRemoteData() { 
        if EnvContext.shared.client.reachability.connection == .none {
            self.emptyMaskView.isHidden = false
            self.emptyMaskView.label.text = "网络异常"
        } else {
            categoryListVM?.requestFavoriteData(houseType: houseType)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams(self.categoryListVM?.originSearchId ?? "be_null", key: "origin_search_id")

        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams(originFromByType(houseType: houseType), key: "origin_from")
        
        self.categoryListVM?.sourceOriginFrom = originFromByType(houseType: houseType);
    }

    fileprivate func originFromByType(houseType: HouseType) -> String {
        switch houseType {
        case .newHouse:
            return "minetab_new"
        case .secondHandHouse:
            return "minetab_old"
        case .neighborhood:
            return "minetab_neighborhood"
        case .rentHouse:
            return "minetab_rent"
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.addStayCategoryLog()
        self.tt_resetStayTime()
    }

    private func setTitle(houseType: HouseType) {
        switch houseType {
            case .newHouse:
                self.navBar.title.text = "我关注的新房"
            case .secondHandHouse:
                self.navBar.title.text = "我关注的二手房"
            case .neighborhood:
                self.navBar.title.text = "我关注的小区"
            case .rentHouse:
                self.navBar.title.text = "我关注的租房"
        }
    }

    private func setUpErrorVM()
    {
        var nilDataText : String? = "暂未关注"
        switch houseType {
        case .newHouse:
            nilDataText = "暂未关注新房"
        case .secondHandHouse:
            nilDataText = "暂未关注二手房"
        case .neighborhood:
            nilDataText = "暂未关注小区"
        case .rentHouse:
            nilDataText = "暂未关注租房"
        }
        
        self.errorVM = NHErrorViewModel(
            errorMask:emptyMaskView,
            requestRetryText:"网络异常",
            requestNilDataText:nilDataText,
            requestNilDataImage:"group-9",
            isUserClickEnable:false,retryAction:{
            [weak self] in
            if let houseType = self?.houseType{
                self?.errorVM?.onRequest()
                self?.categoryListVM?.requestFavoriteData(houseType: houseType)
            }
        })
        
        categoryListVM?.onError = { [weak self] (error) in
            self?.tableView.mj_footer.endRefreshing()
            self?.errorVM?.onRequestError(error: error)
            //恢复滑动位置
            if let tableView = self?.tableView {
                tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
            }

        }
        
        categoryListVM?.onSuccess = {
            [weak self] (isHaveData) in
            
            var categoryName: String? = "be_null"
            if self?.houseType == .newHouse
            {
                categoryName = "new_follow_list"
            }
            if self?.houseType == .secondHandHouse
            {
                categoryName = "old_follow_list"
            }
            if self?.houseType == .neighborhood
            {
                categoryName = "neighborhood_follow_list"
            }
            if self?.houseType == .rentHouse
            {
                categoryName = "rent_follow_list"
            }
            
            self?.tracerParams = (self?.tracerParams ?? TracerParams.momoid()) <|>
                EnvContext.shared.homePageParams <|>
                toTracerParams(categoryName ?? "be_null", key: "category_name") <|>
                toTracerParams("minetab", key: "enter_from") <|>
                toTracerParams("click", key: "enter_type") <|>
                toTracerParams("be_null", key: "element_from") <|>
                toTracerParams(self?.categoryListVM?.originSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(self?.categoryListVM?.originSearchId ?? "be_null", key: "origin_search_id")
            
//            self?.stayTimeParams = (self?.tracerParams ?? TracerParams.momoid()) <|>
//                traceStayTime()
            
            self?.tableView.mj_footer.endRefreshing()
            //增加
            if let tracePram = self?.tracerParams , !(self?.isChangeFromFollow ?? false)
            {
                recordEvent(key: TraceEventName.enter_category, params: tracePram.exclude("log_pb"))
            }

            if(isHaveData)
            {
                self?.errorVM?.onRequestNormalData()
            }else
            {
                self?.errorVM?.onRequestNilData()
            }
        }

    }

    private func showEmptyMaskView() {
        emptyMaskView.icon.image = UIImage(named:"group-9")
        emptyMaskView.isHidden = false
        switch houseType {
        case .newHouse:
            emptyMaskView.label.text = "暂未关注新房"
        case .secondHandHouse:
            emptyMaskView.label.text = "暂未关注二手房"
        case .neighborhood:
            emptyMaskView.label.text = "暂未关注小区"
        case .rentHouse:
            emptyMaskView.label.text = "暂未关注租房"
        }
        
    }

    func loadMore() {
        self.errorVM?.onRequestRefreshData()

        categoryListVM?.pageableLoader?()
        
        tracerParams = tracerParams.exclude("card_type") <|>
            toTracerParams("pre_load_more", key: "refresh_type")
        
        recordEvent(key: TraceEventName.category_refresh, params: tracerParams.exclude("log_pb"))
        
    }
    
    func addStayCategoryLog() {
        
        let trackTime = Int64(self.ttTrackStayTime * 1000)
        let stayTimeParams = self.tracerParams <|> toTracerParams(trackTime, key: "stay_time")
        recordEvent(key: TraceEventName.stay_category, params: stayTimeParams.exclude("log_pb"))
    }

}

// MARK: TTUIViewControllerTrackProtocol
extension MyFavoriteListVC {
    
    override func trackStartedByAppWillEnterForground() {
        
        self.tt_resetStayTime()
        self.ttTrackStartTime = Date().timeIntervalSince1970
    }
    override func trackEndedByAppWillEnterBackground() {
        
        self.addStayCategoryLog()
        self.tt_resetStayTime()
    }
}

