//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class MyFavoriteListVC: BaseViewController, UITableViewDelegate {
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
        categoryListVM = CategoryListViewModel(
            tableView: tableView,
            navVC: self.navigationController)

        categoryListVM?.requestFavoriteData(houseType: houseType)
        tableView.delegate = self
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
