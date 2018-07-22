//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class MyFavoriteListVC: BaseViewController {
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        re.removeGradientColor()
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        return re
    }()

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        return re
    }()

    private var categoryListVM: CategoryListViewModel?

    private let houseType: HouseType

    init(houseType: HouseType) {
        self.houseType = houseType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
        }
        setTitle(houseType: houseType)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        categoryListVM = CategoryListViewModel(tableView: tableView)

        categoryListVM?.requestFavoriteData(houseType: houseType)
        self.categoryListVM?.onDataLoaded = { [weak self] count in
            if count == 0 {
                self?.showEmptyMaskView()
            }
        }
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
        view.addSubview(emptyMaskView)
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(tableView)
        }
        emptyMaskView.label.text = "啊哦～你还没有关注的新房"
    }

}
