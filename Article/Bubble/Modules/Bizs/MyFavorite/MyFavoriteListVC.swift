//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import Reachability

class MyFavoriteListVC: BaseViewController, PageableVC, UITableViewDelegate {

    var hasMore: Bool

    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        re.removeGradientColor()
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.rowHeight = UITableViewAutomaticDimension
        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
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

    let disposeBag = DisposeBag()

    var stayTimeParams: TracerParams?

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

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)

        if EnvContext.shared.client.reachability.connection == .none {
            self.emptyMaskView.isHidden = false
            self.emptyMaskView.label.text = "网络异常"
        } else {
            categoryListVM?.requestFavoriteData(houseType: houseType)
        }

        emptyMaskView.tapGesture.rx.event
            .bind { [unowned self] (_) in
                self.categoryListVM?.requestFavoriteData(houseType: self.houseType)
            }
            .disposed(by: disposeBag)

        tableView.delegate = self


        let onDataLoaded = self.onDataLoaded()
        self.categoryListVM?.onDataLoaded = { [weak self] (hasMore, count) in
            onDataLoaded(hasMore, count)
            if count == 0, hasMore == false {
                self?.showEmptyMaskView()
            } else {
                self?.emptyMaskView.isHidden = true
            }
        }

        tableView.rx.didScroll
            .throttle(0.3, latest: false, scheduler: MainScheduler.instance)
            .filter { [unowned self] _ in self.hasMore }
            .debug("setupLoadmoreIndicatorView")
            .subscribe(onNext: { [unowned self, unowned tableView] void in
                if tableView.contentOffset.y > 0 &&
                    tableView.contentSize.height - tableView.frame.height - tableView.contentOffset.y <= 0 &&
                    self.footIndicatorView?.isAnimating ?? true == false {
                    self.footIndicatorView?.startAnimating()
                    self.loadMore()
                }
            })
            .disposed(by: disposeBag)
        tracerParams = tracerParams <|>
            beNull(key: "card_type")
        stayTimeParams = tracerParams <|> traceStayTime()

        recordEvent(key: TraceEventName.enter_category, params: tracerParams)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
        stayTimeParams = nil
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


    private func showEmptyMaskView() {
        emptyMaskView.isHidden = false
        switch houseType {
        case .newHouse:
            emptyMaskView.label.text = "啊哦～你还没有关注的新房"
        case .secondHandHouse:
            emptyMaskView.label.text = "啊哦～你还没有关注的二手房"
        case .neighborhood:
            emptyMaskView.label.text = "啊哦～你还没有关注的小区"
        case .rentHouse:
            emptyMaskView.label.text = "啊哦～你还没有关注的租房"
        }
    }

    func loadMore() {
        print("loadMore")
        categoryListVM?.pageableLoader?()
        
        tracerParams = tracerParams <|>
            toTracerParams("pre_load_more", key: "refresh_type")
        
        recordEvent(key: TraceEventName.category_refresh, params: tracerParams)
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let datas = categoryListVM?.dataSource.datas {
            if datas.value.count > indexPath.row {
                datas.value[indexPath.row].selector?()
            }
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消关注"
    }
}


class NavGestureDelegateWrapper: NSObject, UIGestureRecognizerDelegate {
    
    weak var ttNav: UIGestureRecognizerDelegate?
    
    init(ttNav: TTNavigationController) {
        self.ttNav = ttNav as? UIGestureRecognizerDelegate
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return ttNav?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return ttNav?.gestureRecognizer?(gestureRecognizer, shouldReceive:touch) ?? false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return ttNav?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
    }
    
}
