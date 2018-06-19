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

class CountryListVC: UIViewController {

    let disposeBag = DisposeBag()

    var onClose: ((UIViewController) -> Void)?
    let onItemSelect = PublishSubject<IndexPath>()

    lazy var navBar: SimpleNavBar = {
        let bar = SimpleNavBar()
        bar.title.text = "选择城市"
        bar.backBtn.rx.tap
            .subscribe({ [unowned self]  void in
                self.onClose?(self)
            })
            .disposed(by: disposeBag)
        return bar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(64)
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CountryListDataSource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
