//
//  HorseDetailPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import Charts
import RxSwift
import RxCocoa

typealias DetailPageViewModelProvider = (UITableView) -> DetailPageViewModel

class HorseDetailPageVC: BaseViewController {

    private let houseId: Int64
    private let houseType: HouseType

    private let disposeBag = DisposeBag()

    private var detailPageViewModel: DetailPageViewModel?

    private var pageViewModelProvider: DetailPageViewModelProvider?

    var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        return re
    }()

    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()

    private lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()

    var isShowBottomBar: Bool

    init(houseId: Int64,
         houseType: HouseType,
         isShowBottomBar: Bool = false,
         provider: @escaping DetailPageViewModelProvider) {
        self.houseId = houseId
        self.houseType = houseType
        self.isShowBottomBar = isShowBottomBar
        self.pageViewModelProvider = provider
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        detailPageViewModel = pageViewModelProvider?(tableView)

        setupNavBar()

        if isShowBottomBar {
            view.addSubview(bottomBar)
            bottomBar.snp.makeConstraints { maker in
                maker.left.right.bottom.equalToSuperview()
            }
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            if isShowBottomBar {
                maker.top.right.left.equalToSuperview()
                maker.bottom.equalTo(bottomBar.snp.top)
            } else {
                maker.top.bottom.left.right.equalToSuperview()
            }
        }
        detailPageViewModel?.requestData(houseId: houseId)

        view.bringSubview(toFront: navBar)

        let stateControl = HomeHeaderStateControl()
        stateControl.onStateChanged = { [weak self] (state) in
            switch state {
            case .suspend:
                    self?.navBar.setGradientColor()
                    UIApplication.shared.statusBarStyle = .lightContent
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
                    self?.navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-icon"), for: .normal)
            default:
                    self?.navBar.removeGradientColor()
                    UIApplication.shared.statusBarStyle = .default
                    self?.navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
                    self?.navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-alt-simple-line-icons"), for: .normal)
            }
        }
        stateControl.onContentOffsetChanged = { [weak self] (state, offset) in
            if state == .normal {
                let alpha = (1 - (139 - offset.y) / 139) * 2
                self?.navBar.alpha = alpha
            } else {
                self?.navBar.alpha = 1
            }
        }

        tableView.rx.contentOffset
            .subscribe(onNext: stateControl.scrollViewContentYOffsetObserve)
            .disposed(by: disposeBag)
    }

    private func setupNavBar() {
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
        }
        navBar.backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return-white"), for: .normal)
        navBar.rightBtn.setBackgroundImage(#imageLiteral(resourceName: "share-icon"), for: .normal)
        self.detailPageViewModel?.titleValue
                .debug()
                .subscribe(onNext: { [unowned self] title in
                    self.navBar.title.text = title
                })
                .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.view.bringSubview(toFront: navigationController.navigationBar)
        }
    }


}

