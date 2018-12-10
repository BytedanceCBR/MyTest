//
//  SystemMessageListVC.swift
//  Article
//
//  Created by leo on 2018/9/17.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
class SystemMessageListVC: BaseViewController, TTRouteInitializeProtocol, UIViewControllerErrorHandler {


    fileprivate var tableViewDelegate: FHListDataSourceDelegate?

    var disposeBag = DisposeBag()
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.backBtn.isHidden = true
        re.rightBtn.isHidden = true
        re.title.text = "消息"
        re.removeGradientColor()
        re.backBtn.isHidden = false
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .grouped)
        re.separatorStyle = .none
        re.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.1)) //to do:设置header0.1，防止系统自动设置高度
        re.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.1)) //to do:设置header0.1，防止系统自动设置高度
        return re
    }()

    fileprivate var maxCoursor: Int64 = 0

    var listId: String?

    fileprivate var errorVM : NHErrorViewModel?

    private lazy var infoDisplay: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()

    fileprivate var minCoursor: String = "0"

    var stayTimeParams: TracerParams?
    
    var tracerParams = TracerParams.momoid()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        self.automaticallyAdjustsScrollViewInsets = false

        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams("be_null", key: "origin_from") <|>
            toTracerParams("be_null", key: "origin_search_id")
        
        navBar.title.text = paramObj?.queryParams["title"] as? String
        listId = paramObj?.queryParams["list_id"] as? String
        errorVM = NHErrorViewModel(errorMask: infoDisplay, requestRetryText: "网络异常") { [weak self] in
            self?.requestSystemMessage()
        }

        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)

        self.tableView.register(SystemItemCell.self, forCellReuseIdentifier: "item")
        bindLoadMore()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindLoadMore() {
        // 上拉刷新，请求上拉接口数据
        tableView.hasMore = false //设置上拉状态
        tableView.tt_addDefaultPullUpLoadMore{ [weak self] in
            self?.requestSystemMessage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorVM?.onRequestViewDidLoad()
        self.tableViewDelegate = TableViewDelegate(tableView: tableView)

        self.automaticallyAdjustsScrollViewInsets = false

        self.view.backgroundColor = UIColor.white

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

        self.view.addSubview(infoDisplay)
        infoDisplay.snp.makeConstraints { (maker) in
            maker.edges.equalTo(tableView)
        }
        self.tracerParams = EnvContext.shared.homePageParams <|>
            toTracerParams("official_message_list", key: "category_name") <|>
            toTracerParams("click", key: "enter_type") <|>
            beNull(key: "log_pb") <|>
            toTracerParams("messagetab", key: "enter_from") <|>
            toTracerParams("be_null", key: "search_id")
        self.stayTimeParams =  self.tracerParams  <|> traceStayTime()
        recordEvent(key: "enter_category", params: tracerParams)
        requestSystemMessage()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
        stayTimeParams = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.ttStatusBarStyle = UIStatusBarStyle.default.rawValue
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }

    fileprivate func requestSystemMessage() {
        if let listId = listId {
            self.tt_startUpdate()
            if self.maxCoursor != 0 { // category_refresh埋点
                recordEvent(key: "category_refresh", params: self.tracerParams <|>
                        toTracerParams("pre_load_more", key: "refresh_type"))
            }
            errorVM?.onRequest()
            requestSystemNotification(listId: listId, maxCoursor: minCoursor)
                .subscribe(onNext: { [weak self] response in
                    let models: [ItemModel]? = response?.data?.items?.map {
                        ItemModel(data: $0)
                    }
                    self?.tableView.hasMore = response?.data?.hasMore ?? false
                    self?.minCoursor = response?.data?.minCoursor ?? "0"
                    var fhSections = self?.tableViewDelegate?.fhSections ?? [[]]
                    if let models = models {
                        fhSections.append(models)
                    }
                    if fhSections.count == 0 {
                        self?.errorVM?.onRequestNilData()
                    } else {
                        self?.tableViewDelegate?.fhSections = fhSections
                        self?.tableView.reloadData()
                        self?.errorVM?.onRequestNormalData()
                    }
                    self?.tt_endUpdataData()
                }, onError: { [weak self] error in
                    self?.errorVM?.onRequestError(error: error)
                    self?.tt_endUpdataData()
                })
                .disposed(by: disposeBag)
        } else {
            self.errorVM?.onRequestNilData()
        }

    }

    func tt_hasValidateData() -> Bool {
        return self.tableViewDelegate?.fhSections.count ?? 0 > 0
    }

}

fileprivate class TableViewDelegate: FHListDataSourceDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.fhSections[indexPath.section][indexPath.row] as? ItemModel,
            let openUrl = item.data.openUrl {
            let tracerParams = TracerParams.momoid() <|>
                    toTracerParams("official_message_list", key: "category_name") <|>
                    toTracerParams(item.data.id ?? "be_null", key: "official_message_id")
            recordEvent(key: "click_official_message", params: tracerParams)
            TTRoute.shared().openURL(byPushViewController: URL(string: "\(openUrl)&hide_more=1"))
        }
    }

}

fileprivate class ItemModel: FHCellModel {
    var data: SystemNotificationResponse.Item

    init(data: SystemNotificationResponse.Item) {
        self.data = data
        super.init()
        self.fhCellID = "item"
    }
}

fileprivate class SystemItemCell: BaseUITableViewCell {

    var timeLabelBGView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 4
        re.backgroundColor = color(0, 0, 0, 0.1)
        return re
    }()

    var timeLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = UIColor.white
        return re
    }()

    var bubbleBGView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        re.layer.cornerRadius = 4
        return re
    }()

    var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(16)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()

    var majorImageView: UIImageView = {
        let re = UIImageView()
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
//        re.contentMode = .scaleAspectFit
        return re
    }()

    var summarylabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#737a80")
        re.numberOfLines = 2
        return re
    }()

    var lineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()

    var buttonLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        return re
    }()

    var arrowIcon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-feed")
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")


        self.contentView.addSubview(timeLabelBGView)
        timeLabelBGView.snp.makeConstraints { maker in
            maker.top.equalTo(20)
//            maker.bottom.equalTo(-14)
            maker.centerX.equalToSuperview()
        }

        timeLabelBGView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { maker in
            maker.top.equalTo(0)
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.bottom.equalTo(0)
            maker.height.equalTo(20)
         }

        self.contentView.addSubview(bubbleBGView)
        bubbleBGView.snp.makeConstraints { maker in
            maker.top.equalTo(timeLabelBGView.snp.bottom).offset(10)
            maker.bottom.equalToSuperview()
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
         }

        bubbleBGView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.centerY.equalTo(20)
        }

        bubbleBGView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(10)
            maker.left.equalTo(titleLabel.snp.left)
            maker.right.equalTo(titleLabel.snp.right)
            maker.height.equalTo(166 * CommonUIStyle.Screen.widthScale)
        }

        bubbleBGView.addSubview(summarylabel)
        summarylabel.snp.makeConstraints { maker in
            maker.left.equalTo(titleLabel.snp.left)
            maker.right.equalTo(titleLabel.snp.right)
            maker.top.equalTo(majorImageView.snp.bottom).offset(10)
        }

        bubbleBGView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(0.5)
            maker.top.equalTo(summarylabel.snp.bottom).offset(10)
        }

        bubbleBGView.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { maker in
            maker.right.equalTo(titleLabel.snp.right)
            maker.height.width.equalTo(18)
            maker.top.equalTo(lineView.snp.bottom).offset(11)
            maker.bottom.equalTo(-11)
         }

        bubbleBGView.addSubview(buttonLabel)
        buttonLabel.snp.makeConstraints { maker in
            maker.left.equalTo(titleLabel.snp.left)
            maker.top.equalTo(lineView.snp.bottom).offset(9)
            maker.bottom.equalTo(-9)
            maker.right.equalTo(arrowIcon.snp.left).offset(10)
         }


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    override func fillData(_ cellModel: FHCellModel) {
        if let data = cellModel as? ItemModel {
            timeLabel.text = data.data.dateStr
            titleLabel.text = data.data.title
            majorImageView.bd_setImage(
                    with: URL(string: data.data.images?.url ?? ""),
                    placeholder: UIImage(named: "default_image"))
            summarylabel.text = data.data.content
            buttonLabel.text = data.data.bottonName
        }
    }
}
