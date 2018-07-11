//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit

class HouseCommentVC: BaseSubPageViewController, PageableVC {


    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()


    init(courtId: Int64) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func loadMore() {

    }
}
