//
//  AboutViewController.swift
//  News
//
//  Created by leo on 2018/8/5.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class AboutViewController: BaseViewController, TTRouteInitializeProtocol  {
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        return re
    }()
    
    lazy var logoIcon: UIImageView = {
        let re  = UIImageView()
        re.image = UIImage(named: "about")
        return re
    }()

    lazy var versionLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.textAlignment = .center
        return re
    }()

    let disposeBag = DisposeBag()

    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        self.navBar.backBtn.rx.tap.bind { [unowned self] void in
            if let navVC = self.navigationController {
                navVC.popViewController(animated: true)
            }
        }.disposed(by: disposeBag)
        versionLabel.text = "版本号\(Utils.appVersion)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.title.text = "关于我们"
        navBar.removeGradientColor()

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

        view.addSubview(logoIcon)
        logoIcon.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }

        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(-20)
         }
    }
}
