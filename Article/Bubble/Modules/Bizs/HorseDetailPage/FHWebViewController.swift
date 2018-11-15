//
//  FHWebViewController.swift
//  Article
//
//  Created by 谢飞 on 2018/11/15.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Reachability

class FHWebViewController: BaseViewController, TTRouteInitializeProtocol {

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.backBtn.isHidden = true
        re.rightBtn.isHidden = true
        re.title.text = "消息"
        re.removeGradientColor()
        re.backBtn.isHidden = false
        return re
    }()
    
    private lazy var infoDisplay: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()
    
    var stayTimeParams: TracerParams?
    
    var tracerParams = TracerParams.momoid()
    
    fileprivate var errorVM : NHErrorViewModel?
    
    var disposeBag = DisposeBag()
    
    lazy var webviewContainer: UIWebView = {
        let re = UIWebView(frame: CGRect.zero)
        return re
    }()
    
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)

        self.automaticallyAdjustsScrollViewInsets = false

        navBar.title.text = paramObj?.queryParams["title"] as? String
        
        errorVM = NHErrorViewModel(errorMask: infoDisplay, requestRetryText: "网络异常") { [weak self] in
        }
        
        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
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
        
        // Do any additional setup after loading the view.
        self.view.addSubview(webviewContainer)
        webviewContainer.snp.makeConstraints { (maker) in
            maker.bottom.right.left.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        
        self.view.addSubview(infoDisplay)
        infoDisplay.snp.makeConstraints { (maker) in
            maker.edges.equalTo(webviewContainer)
        }
        
        self.tracerParams = EnvContext.shared.homePageParams <|>
            toTracerParams("official_message_list", key: "category_name") <|>
            toTracerParams("click", key: "enter_type") <|>
            beNull(key: "log_pb") <|>
            toTracerParams("messagetab", key: "enter_from") <|>
            toTracerParams("be_null", key: "search_id")
        self.stayTimeParams =  self.tracerParams  <|> traceStayTime()
        recordEvent(key: "enter_category", params: tracerParams)
        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
