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
        re.text = "我的关注"
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.textAlignment = .left
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.left.right.equalToSuperview()
        }

        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(0)
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
            maker.width.height.equalTo(24*(UIScreen.main.bounds.width/320))
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


func parseFavoriteNode(
    disposeBag: DisposeBag,
    userFavoriteCounts: [UserFollowListResponse?],
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    var items: [FavoriteItemView] = []
    if userFavoriteCounts.count == 3 {
        items = [
            FavoriteItemView(
                image: #imageLiteral(resourceName: "icon-ershoufang"),
                title: getFavoriteCategoryLabel(title: "二手房", userFollowListResponse: userFavoriteCounts[0])),
            FavoriteItemView(
                image: #imageLiteral(resourceName: "icon-ershoufang"),
                title: getFavoriteCategoryLabel(title: "新房", userFollowListResponse: userFavoriteCounts[1])),
            FavoriteItemView(
                image: #imageLiteral(resourceName: "icon-ershoufang"),
                title: getFavoriteCategoryLabel(title: "小区", userFollowListResponse: userFavoriteCounts[2])),
            ]
    }

    let selectors = [HouseType.secondHandHouse,
                     HouseType.newHouse,
                     HouseType.neighborhood].map { [weak navVC] (houseType) in
                        return  { [weak navVC] in
        
                            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                                toTracerParams(originFromNameByHouseType(houseType: houseType), key: "origin_from")
                            
                            let vc = MyFavoriteListVC(houseType: houseType)
                            
                            let params = TracerParams.momoid() <|>
                                    toTracerParams("click", key: "enter_type") <|>
                                    beNull(key: "log_pb") <|>
                                    toTracerParams(categoryEnterNameByHouseType(houseType: houseType), key: "category_name")
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

fileprivate func getFavoriteCategoryLabel(
    title: String,
    userFollowListResponse: UserFollowListResponse?) -> String {
    if let count = userFollowListResponse?.data?.totalCount {
        return "\(title) (\(count))"
    } else {
        return title
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
    
    lazy var headView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    var currentItemData: [OpData.Item]?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(headView)
        headView.snp.makeConstraints { maker in
            maker.left.right.bottom.top.equalToSuperview()
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(100) //为了默认图cell的位置偏移
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setItem(items: [SpringBroadItemView],isNeedUpdateBoard: Bool,itemData: [OpData.Item]?) {

        if isNeedUpdateBoard
        {
            
            var isEqualData = true
            // 遍历数组，判断是否需要更新
            if let count = itemData?.count,itemData?.count == currentItemData?.count, count != 0
            {
                for index in 0...count - 1
                {
                        if itemData?[index].openUrl == currentItemData?[index].openUrl, itemData?[index].title == currentItemData?[index].title, itemData?[index].id == currentItemData?[index].id, itemData?[index].image.first?.uri == currentItemData?[index].image.first?.uri
                        {
                            continue
                        }else
                        {
                            isEqualData = false
                        }
                }
            }else
            {
                isEqualData = false
            }
          
            if isEqualData
            {
                return
            }
            
            for v in contentView.subviews where v is SpringBroadItemView {
                v.removeFromSuperview()
            }
            
            for v in headView.subviews where v is SpringBroadItemView {
                v.removeFromSuperview()
            }
            
            items.enumerated().forEach { e in
                let (index, view) = e
                if index > 7
                {
                    return
                }
                headView.addSubview(view)
                if ((index/4) == 0)
                {
                    view.snp.makeConstraints { maker in
                        maker.top.equalToSuperview()//4个一行，计算一共多少行数，纵向排版
                        maker.left.equalTo(Int(index%4) * Int(UIScreen.main.bounds.width/4 + 1)) //计算列数，横向排版
                        maker.width.equalTo(UIScreen.main.bounds.width/4)
                        maker.height.equalTo(100)
                        if items.count < 5
                        {
                            maker.bottom.equalToSuperview()
                        }
                    }
                } else if ((index/4) == 1)
                {
                    view.snp.makeConstraints { maker in
                        maker.top.equalToSuperview().offset(100)
                        maker.left.equalTo(Int(index%4) * Int(UIScreen.main.bounds.width/4)) //计算列数，横向排版
                        maker.width.equalTo(UIScreen.main.bounds.width/4)
                        maker.height.equalTo(100)
                        maker.bottom.equalToSuperview()
                    }
                }
                
            }
            
            headView.snp.updateConstraints{ maker in
                maker.height.equalTo(100 * (items.count > 4 ? 2 : 1) ) //按照行数撑开高度
            }
            
            setNeedsLayout()
            layoutIfNeeded()
            
            currentItemData = itemData
        }
        
    }

}

fileprivate class SpringBroadItemView: UIView {

    lazy var keyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textAlignment = .center
        re.textColor = hexStringToUIColor(hex: "#081f33")
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

    init(image: String, title: String) {
        super.init(frame: CGRect.zero)

        addSubview(IconView)
        IconView.snp.makeConstraints { maker in
            maker.width.height.equalTo(52)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(20)
        }
        IconView.layer.shouldRasterize = true

        keyLabel.text = title
        addSubview(keyLabel)
        keyLabel.snp.makeConstraints { maker in
            maker.centerX.equalTo(IconView)
            maker.height.equalTo(20)
            maker.width.equalToSuperview()
            maker.top.equalTo(IconView.snp.bottom).offset(8)
        }
        IconView.bd_setImage(with: URL(string: image), placeholder:UIImage(named: "spring_borad_default"))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func parseSpringboardNode(_ items: [OpData.Item],isNeedUpdateBoard: Bool, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> TableSectionNode? {
    
    var nedUpdateBoard = true
    if items.count == 0 {
        nedUpdateBoard = false
    }else
    {
        nedUpdateBoard = isNeedUpdateBoard
    }
    
    
    let views = items.map { createFavoriteItemViewByEntryId(item: $0) }

    zip(items, views).forEach { e in
        let (item, view) = e
        view.tapGesture.rx.event
            .map({ (_) -> Void in () })
            .bind(onNext: createSpringBroadItemSelector(item: item, disposeBag: disposeBag, navVC: navVC))
            .disposed(by: disposeBag)
    }
    return {
        let cellRender = curry(fillSpringboardCell)(views)(items)(nedUpdateBoard)
        return TableSectionNode(items: [cellRender], selectors: nil, tracer: nil, label: "", type: .node(identifier: SpringBroadCell.identifier))
    }
}

fileprivate func fillSpringboardCell(_ items: [SpringBroadItemView], itemsData: [OpData.Item]?,isNeedUpdateBoard: Bool, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? SpringBroadCell {
        theCell.setItem(items: items,isNeedUpdateBoard: isNeedUpdateBoard,itemData: itemsData)
    }
}

fileprivate func createSpringBroadItemSelector(item: OpData.Item, disposeBag: DisposeBag, navVC: UINavigationController?) -> () -> Void {
    
    if item.id != ""
    {

        return openTTRouterUrl(
            disposeBag: disposeBag,
            item:item,
            navVC: navVC)
    }else
    {
        return {
            NotificationCenter.default.post(name: .discovery, object: nil)
        }
    }

    
    /*
    switch item.id {
    case "10":
        params = params <|>
                toTracerParams("old", key: "icon_type")
        return openCategoryVC(
            .secondHandHouse,
            disposeBag: disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.old_list.rawValue]) <|> params,
            navVC: navVC)
    case "11":
        params = params <|>
                toTracerParams("new", key: "icon_type")
        return openCategoryVC(
            .newHouse, disposeBag:
            disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.new_list.rawValue]) <|> params,
            navVC: navVC)
    case "12":
        params = params <|>
                toTracerParams("neighborhood", key: "icon_type")
        return openCategoryVC(
            .neighborhood,
            disposeBag: disposeBag,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_list.rawValue]) <|> params,
            navVC: navVC)
    case "13":
        params = params <|>
            toTracerParams("neighborhood", key: "icon_type")
        return openTTRouterUrl(
            .neighborhood,
            disposeBag: disposeBag,
            item:item,
            tracerParams: paramsOfMap([EventKeys.category_name: HouseCategory.neighborhood_list.rawValue]) <|> params,
            navVC: navVC)
    default:
        return {
            NotificationCenter.default.post(name: .discovery, object: nil)
        }
    }
   */
}


fileprivate func createFavoriteItemViewByEntryId(item: OpData.Item) -> SpringBroadItemView {
    
      return SpringBroadItemView(image: item.image.first?.url ?? "", title: item.title ?? "二手房")

//    switch item.entryId {
//    case 1:
//        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-ershoufang"), title: item.name ?? "二手房")
//    case 2:
//        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-xinfang"), title: item.name ?? "新房")
//    case 4:
//        return SpringBroadItemView(image: #imageLiteral(resourceName: "home-icon-xiaoqu"), title: item.name ?? "找小区")
//    default:
//        return SpringBroadItemView(image: #imageLiteral(resourceName: "icon-zixun-1"), title: item.name ?? "资讯")
//    }
}


fileprivate func confirmUserAuth(
    navVC: UINavigationController?,
    callBack: @escaping () -> Void) -> () -> Void {
    return {
        if !TTAccount.shared().isLogin() {

            var tracerParams = TracerParams.momoid()
            tracerParams = tracerParams <|>
                toTracerParams("minetab", key: "enter_from") <|>
                toTracerParams("house_follow", key: "enter_type")
            
            let delegate = NIHLoginVCDelegate()
            delegate.callBack = callBack
            var paramsMap = tracerParams.paramsGetter([:])
            paramsMap["delegate"] = delegate
            let userInfo = TTRouteUserInfo(info: paramsMap)
//            if TTDeviceHelper.isIPhoneXDevice() {
//                TTRoute.shared().openURL(byViewController: URL(string: "fschema://flogin"), userInfo: userInfo)
//            } else {
                TTRoute.shared().openURL(byPresentViewController: URL(string: "fschema://flogin"), userInfo: userInfo)
//            }

        } else {
            callBack()
        }
    }
}

fileprivate func openTTRouterUrl(
    disposeBag: DisposeBag,
    item: OpData.Item,
    navVC: UINavigationController?) -> () -> Void {
    return {
        
        if let logpb = item.logPb as NSDictionary?
        {
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams(logpb["origin_from"] ?? "be_null", key: "origin_from")
        }


        let tracerParams = TracerParams.momoid() <|>
            EnvContext.shared.homePageParams <|>
            toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
            toTracerParams("maintab", key: "enter_from") <|>
            toTracerParams("maintab_icon", key: "element_from") <|>
            toTracerParams("click", key: "enter_type")
        
        
        let parmasMap = tracerParams.paramsGetter([:])
        let userInfo = TTRouteUserInfo(info: ["tracer": parmasMap])
        if let openUrl = item.openUrl
        {
            TTRoute.shared().openURL(byPushViewController: URL(string: openUrl), userInfo: userInfo)
        }
        
//        let vc = CategoryListPageVC(isOpenConditionFilter: true)
//        vc.tracerParams = tracerParams <|> params
//        vc.houseType.accept(houseType)
//        vc.searchAndConditionFilterVM.queryConditionAggregator = ConditionAggregator.monoid()
//        vc.navBar.isShowTypeSelector = false
//        vc.navBar.searchInput.placeholder = searchBarPlaceholder(houseType)
//
//        navVC?.pushViewController(vc, animated: true)
//        vc.navBar.backBtn.rx.tap
//            .subscribe(onNext: { void in
//                EnvContext.shared.toast.dismissToast()
//                navVC?.popViewController(animated: true)
//            })
//            .disposed(by: disposeBag)
    }
}

fileprivate func originFromNameByHouseType(houseType: HouseType) -> String {
    switch houseType {
    case .neighborhood:
        return "minetab_neighborhood"
    case .secondHandHouse:
        return "minetab_old"
    case .newHouse:
        return "minetab_new"
    default:
        return "be_null"
    }
}

