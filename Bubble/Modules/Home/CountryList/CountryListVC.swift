//
//  CountryListVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import YYCache

class CountryListVC: UIViewController {

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "countryListHistory")
    }()

    lazy var navBar: SearchNavBar = {
        let result = SearchNavBar()
        result.searchInput.placeholder = "请输入城市名"
        result.backBtn.rx.tap
                .subscribe({ [unowned self]  void in
                    self.onClose?(self)
                })
                .disposed(by: disposeBag)
        return result
    }()

    lazy var tableView: UITableView = {
        UITableView()
    }()

    lazy var locationBar: LocationBar = {
        let result = LocationBar()
        result.lu.addTopBorder(color: hexStringToUIColor(hex: "#f4f5f6"))
        return result
    }()

    let disposeBag = DisposeBag()

    var onClose: ((UIViewController) -> Void)?
    let onItemSelect = PublishSubject<IndexPath>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(64)
        }

        view.addSubview(locationBar)
        locationBar.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }

        tableView.register(BubbleCell.self, forCellReuseIdentifier: "bubble")
        tableView.register(CityItemCell.self, forCellReuseIdentifier: "item")

        EnvContext.shared.client.generalCacheSubject
                .debug("generalCacheSubject")
                .subscribe(onNext: { data in

                })
                .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CountryListDataSource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }

}

class LocationBar: UIView {

    lazy var countryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var poiIcon: UIImageView = {
        let result = UIImageView()
        result.image = #imageLiteral(resourceName: "group")
        return result
    }()

    lazy var reLocateBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.clear
        result.setTitle("重新定位", for: .normal)
        result.setTitleColor(hexStringToUIColor(hex: "#f85959"), for: .normal)
        return result
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview().offset(-14)
            maker.height.equalTo(22)
        }

        addSubview(poiIcon)
        poiIcon.snp.makeConstraints { maker in
            maker.left.equalTo(countryLabel.snp.right).offset(2)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
            maker.width.equalTo(20)
        }

        addSubview(reLocateBtn)
        reLocateBtn.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-24)
            maker.top.equalTo(14)
            maker.bottom.equalToSuperview().offset(-14)
            maker.height.equalTo(22)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class BubbleCell: UITableViewCell {

    var cityItem: [CountryListNode]?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class CityItemCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class BubbleBtn: UIView {

}

fileprivate struct CountryListNode {
    let label: String
    let type: Int
    let children: [CountryListNode]?
}
