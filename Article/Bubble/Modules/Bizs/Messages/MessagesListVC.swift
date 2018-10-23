//
// Created by leo on 2018/8/20.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MessagesListVC: BaseViewController, UITableViewDelegate {



    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.rightBtn.isHidden = true
        re.removeGradientColor()
        re.title.text = "消息"
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .grouped)
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
//        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return re
    }()

    private var tableListViewModel: ChatDetailListTableViewModel?

    var traceParams = TracerParams.momoid()

    var messageId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableListViewModel = ChatDetailListTableViewModel()
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

        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.bottom.right.left.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        tableView.dataSource = tableListViewModel
    }

}


fileprivate  class ChatDetailListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    var datas: [UserListMsgItem] = []

    let disposeBag = DisposeBag()

    weak var navVC: UINavigationController?

    var traceParams = TracerParams.momoid()

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "item")

        return cell
    }


}
