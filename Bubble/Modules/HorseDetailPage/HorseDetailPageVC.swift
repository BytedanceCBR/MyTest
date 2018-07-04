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

    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        if #available(iOS 11.0, *) {
            result.contentInsetAdjustmentBehavior = .never
        }
        return result
    }()


    init(houseId: Int64, houseType: HouseType, provider: @escaping DetailPageViewModelProvider) {
        self.houseId = houseId
        self.houseType = houseType
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
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
        detailPageViewModel = pageViewModelProvider?(tableView)
        detailPageViewModel?.requestData(houseId: houseId)
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

