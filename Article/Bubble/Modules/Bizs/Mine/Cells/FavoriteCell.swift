//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
class FavoriteCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "FavoriteCell"
    }

    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.text = "房源关注"
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.textAlignment = .left
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.top.equalTo(6)
            maker.bottom.equalTo(-6)
            maker.left.right.equalToSuperview()
        }

        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.height.equalTo(22)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setItem(items: [FavoriteItemView]) {
        for v in bgView.subviews where v is FavoriteItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            bgView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom)
            maker.bottom.equalToSuperview()
        }
    }
}

fileprivate class FavoriteItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#505050")
        return re
    }()

    lazy var IconView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init(image: UIImage, title: String) {
        super.init(frame: CGRect.zero)

        IconView.image = image
        addSubview(IconView)
        IconView.snp.makeConstraints { maker in
            maker.width.height.equalTo(42)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(15)
        }

        keyLabel.text = title
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(IconView.snp.bottom).offset(9)
            maker.centerX.equalTo(IconView)
            maker.bottom.equalTo(-18)
        }

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseFavoriteNode(disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    let items: [FavoriteItemView] = [
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-ershoufang"), title: "二手房"),
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-xinfang"), title: "新房"),
        //        FavoriteItemView(image: #imageLiteral(resourceName: "icon-zufang"), title: "租房"),
        FavoriteItemView(image: #imageLiteral(resourceName: "icon-xiaoqu"), title: "小区"),
        ]
    let selectors = [HouseType.secondHandHouse,
                     HouseType.newHouse,
                     HouseType.neighborhood].map { (houseType) in
                        return confirmUserAuth(navVC: navVC) { [weak navVC] in
        
                            let vc = MyFavoriteListVC(houseType: houseType)
                            
                            let params = TracerParams.momoid() <|>
                                    toTracerParams("click", key: "enter_type") <|>
                                    beNull(key: "log_pb") <|>
                                    toTracerParams(categoryNameByHouseType(houseType: houseType), key: "category_name")
                            vc.tracerParams = params
                            vc.navBar.backBtn.rx.tap
                                .subscribe(onNext: { void in
                                    navVC?.popViewController(animated: true)
                                })
                                .disposed(by: disposeBag)
                            navVC?.pushViewController(vc, animated: true)
                        }
    }
    zip(items, selectors).forEach { (e) -> Void in
        let (item, selector) = e
        item.tapGesture.rx.event
            .subscribe(onNext: { (_) in
                selector()
            })
            .disposed(by: disposeBag)
    }
    return {
        let cellRender = curry(fillFavoriteCell)(items)
        return TableSectionNode(items: [cellRender], selectors: nil, tracer: nil, label: "", type: .node(identifier: FavoriteCell.identifier))
    }
}

fileprivate func categoryNameByHouseType(houseType: HouseType) -> String {
    switch houseType {
        case .newHouse:
            return "new_follow_list"
        case .secondHandHouse:
            return "old_follow_list"
        case .neighborhood:
            return "neighborhood_follow_list"
        default:
            return "be_null"
    }
}

fileprivate func fillFavoriteCell(_ items: [FavoriteItemView], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FavoriteCell {
        theCell.setItem(items: items)
    }
}

class SpringBroadCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "SpringBroadCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setItem(items: [SpringBroadItemView]) {
        for v in contentView.subviews where v is SpringBroadItemView {
            v.removeFromSuperview()
        }

        items.forEach { view in
            contentView.addSubview(view)
        }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}

fileprivate class SpringBroadItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#505050")
        return re
    }()

    lazy var IconView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init(image: UIImage, title: String) {
        super.init(frame: CGRect.zero)

        IconView.image = image
        addSubview(IconView)
        IconView.snp.makeConstraints { maker in
            maker.width.height.equalTo(66)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(16)
        }

        keyLabel.text = title
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(76)
            maker.centerX.equalTo(IconView)
            maker.bottom.equalTo(-20)
        }

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseSpringboardNode(_ items: [EntryItem], disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    let views = items.map { createFavoriteItemViewByEntryId(item: $0) }
    zip(items, views).forEach { e in
        let (item, view) = e
        view.tapGesture.rx.event
            .map({ (_) -> Void in () })
            .bind(onNext: createSpringBroadItemSelector(item: item, disposeBag: disposeBag, navVC: navVC))
            .disposed(by: disposeBag)
    }
    return {
        let cellRender = curry(fillSpringboardCell)(views)
        return TableSectionNode(items: [cellRender], selectors: nil, tracer: nil, label: "", type: .node(identifier: SpringBroadCell.identifier))
    }
}

fileprivate func fillSpringboardCell(_ items: [SpringBroadItemView], cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? SpringBroadCell {
        theCell.setItem(items: items)
    }
}

fileprivate func createSpringBroadItemSelector(item: EntryItem, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    var params = TracerParams.momoid()
    switch item.entryId {
    case 1:
        params = params <|>
                toTracerParams("old", key: "icon_type")
        return openCategoryVC(
            .secondHandHouse,
            disposeBag: disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.old_list.rawValue]) <|> params,
            navVC: navVC)
    case 2:
        params = params <|>
                toTracerParams("new", key: "icon_type")
        return openCategoryVC(
            .newHouse, disposeBag:
            disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.new_list.rawValue]) <|> params,
            navVC: navVC)
    case 4:
        params = params <|>
                toTracerParams("neighborhood", key: "icon_type")
        return openCategoryVC(
            .neighborhood,
            disposeBag: disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_list.rawValue]) <|> params,
            navVC: navVC)
    default:
        return {
            NotificationCenter.default.post(name: .discovery, object: nil)
        }
    }
}


fileprivate func createFavoriteItemViewByEntryId(item: EntryItem) -> SpringBroadItemView {
    switch item.entryId {
    case 1:
        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-ershoufang"), title: item.name ?? "二手房")
    case 2:
        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-xinfang"), title: item.name ?? "新房")
    case 4:
        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-xiaoqu"), title: item.name ?? "找小区")
    default:
        return SpringBroadItemView(image: #imageLiteral(resourceName: "icon-zixun-1"), title: item.name ?? "资讯")
    }
}


fileprivate func confirmUserAuth(
    navVC: UINavigationController?,
    callBack: @escaping () -> Void) -> () -> Void {
    return {
        if !BDAccount.shared().isLogin() {
            let vc = QuickLoginVC(complete: { (result) in
                
                if result {
                    callBack()
                }
            })
            
            var tracerParams = TracerParams.momoid()
            tracerParams = tracerParams <|>
                toTracerParams("minetab", key: "enter_from") <|>
                toTracerParams("house_follow", key: "enter_type")
            vc.tracerParams = tracerParams
            
            navVC?.present(vc, animated: true, completion: nil)
        } else {
            callBack()
        }
    }
}

fileprivate func openCategoryVC(
    _ houseType: HouseType,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> Void {
    return {
        var params = EnvContext.shared.homePageParams <|>
                toTracerParams("maintab", key: "enter_from") <|>
                toTracerParams("maintab_icon", key: "element_from") <|>
                toTracerParams("icon", key: "maintab_entrance") <|>
                toTracerParams("click", key: "enter_type") <|>
                toTracerParams("left_pic", key: "card_type") <|>
                beNull(key: "log_pb") <|>
                tracerParams

        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                params

        let vc = CategoryListPageVC(isOpenConditionFilter: true)
        vc.tracerParams = tracerParams <|> params
        vc.houseType.accept(houseType)
        vc.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator.monoid()
        vc.navBar.isShowTypeSelector = false
        vc.navBar.searchInput.placeholder = searchBarPlaceholder(houseType)

        navVC?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
                .subscribe(onNext: { void in
                    navVC?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
    }
}
