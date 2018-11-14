//
//  HouseFindHistoryCollectionCell.swift
//  NewsLite
//
//  Created by leo on 2018/9/20.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
class HouseFindHistoryCollectionCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var historyItem = BehaviorRelay<[SearchHistoryResponse.Item]>(value: [])

    var houseType: HouseType = HouseType.secondHandHouse

    private var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()        
        flowLayout.minimumLineSpacing = 13
        flowLayout.scrollDirection = .horizontal
        let re = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        re.showsHorizontalScrollIndicator = false
        re.backgroundColor = UIColor.white
        return re
    }()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
            maker.height.equalTo(60)
        }
        registerCollectionViewComponent()
        bindItemsObv()
    }

    private func bindItemsObv() {
        historyItem.bind { [unowned self] items in
            self.collectionView.reloadData()
        }.disposed(by: disposeBag)


        NotificationCenter.default.rx
            .notification(.findHouseHistoryCellReset)
            .subscribe(onNext: { [unowned self] notification in
                if self.historyItem.value.count > 0 {
                    self.collectionView.scrollToItem(
                        at: IndexPath(item: 0, section: 0),
                        at: .left,
                        animated: false)
                }
            }).disposed(by: disposeBag)
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyItem.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = historyItem.value[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath)
        if let theCell = cell as? HistoryItemCell {
            theCell.titleLabel.text = item.text
            theCell.summaryLabel.text = item.desc
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = historyItem.value[indexPath.row]
        if let openUrl = item.openUrl {
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams("findtab_search", key: "origin_from")
            let tracerParams = TracerParams.momoid() <|>
                EnvContext.shared.homePageParams <|>
                toTracerParams("findtab", key: "enter_from") <|>
                toTracerParams("findtab_search", key: "element_from") <|>
                toTracerParams("click", key: "enter_type")


            let parmasMap = tracerParams.paramsGetter([:])
            let houseSearchParams = ["page_type": self.pageTypeString(),
                                     "query_type": "history",
                                     "enter_query": item.text ?? "be_null",
                                     "search_query": item.text ?? "be_null"]
            var infoParams: [String: Any] = ["tracer": parmasMap,
                              "houseSearch": houseSearchParams]
            if let extInfo = item.extinfo {
                infoParams["suggestion"] = createQueryCondition(extInfo)
            }
            let userInfo = TTRouteUserInfo(info: infoParams)
            var jumpUrl = openUrl

            if let placeholder = item.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                jumpUrl = jumpUrl + "&placeholder=\(placeholder)"
            }
            TTRoute.shared().openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
        }
    }


    fileprivate func pageTypeString() -> String {
        switch self.houseType {
        case .neighborhood:
            return "findtab_neighborhood"
        case .newHouse:
            return "findtab_new"
        default:
            return "findtab_old"
        }
    }

    fileprivate func registerCollectionViewComponent() {
        collectionView.register(
                HistoryItemCell.self,
                forCellWithReuseIdentifier: "item")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if historyItem.value.count > 0 {
            let frame = CGRect(x: 0, y: 0, width: 1000000000, height: 15)
            let item = historyItem.value[indexPath.row]

            let label = UILabel(frame: frame)
            label.font = CommonUIStyle.Font.pingFangSemibold(14)
            label.text = item.text
            let width = label.textRect(forBounds: frame, limitedToNumberOfLines: 1).width

            let label2 = UILabel(frame: frame)
            label2.font = CommonUIStyle.Font.pingFangRegular(12)
            label2.text = item.desc
            let width2 = label2.textRect(forBounds: frame, limitedToNumberOfLines: 1).width
            
            let finalWidth = max(width, width2) + 28
            let result = CGSize(width: finalWidth > 137 ? 137 : finalWidth, height: 60)
            return result
        } else {
            return CGSize(width: 137, height: 60)
        }
    }

}

fileprivate class HistoryItemCell: UICollectionViewCell {

    var titleLabel: UILabel = {
        let re = UILabel()
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangSemibold(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()

    var summaryLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.textAlignment = .left
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        contentView.layer.cornerRadius = 4

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(8)
            maker.left.equalTo(14)
            maker.right.equalTo(-14)
            maker.height.equalTo(24)
        }

        contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom)
            maker.left.equalTo(titleLabel.snp.left)
            maker.right.equalTo(titleLabel.snp.right)
            maker.height.equalTo(20)
            maker.bottom.equalTo(-8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
