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

class FHWebViewController: BaseViewController,TTRouteInitializeProtocol,UIWebViewDelegate {
    
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
    
    
    var readPct: Int64?
    
    var urlString: String?
    
    var stayPageTraceName: String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(url: String, title: String, traceParam: TracerParams) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = url
        navBar.title.text = title
        tracerParams = traceParam
        
        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                if let navVC = self?.navigationController, navVC.viewControllers.count > 1 {
                    self?.view.endEditing(true)
                    navVC.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true, completion: {
                    })
                }
            }.disposed(by: disposeBag)
    }
    
    @objc
    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        errorVM = NHErrorViewModel(errorMask: infoDisplay, requestRetryText: "网络异常") { [weak self] in
            if let urlV = self?.urlString
            {
                let url = URL(string: urlV)
                if let urlV = url
                {
                    self?.webviewContainer.loadRequest(URLRequest(url: urlV))
                }
            }
        }
        
        //埋点参数
        if let userInfo = paramObj?.userInfo,let params = userInfo.allInfo["tracer"]{
            self.tracerParams = paramsOfMap(params as? [String : Any] ?? [:])
            
        }
        //title
        if let userInfo = paramObj?.userInfo,let params = userInfo.allInfo["title"]{
            navBar.title.text = params as? String
        }
        
        //加载URL
        if let userInfo = paramObj?.userInfo,let params = userInfo.allInfo["url"]{
            urlString = params as? String
        }
        
        //event,不传不上报
        if let userInfo = paramObj?.userInfo,let params = userInfo.allInfo["event"]{
            stayPageTraceName = params as? String
        }
        
        
        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
                self?.dismiss(animated: true, completion: nil)
                if let navVC = self?.navigationController, navVC.viewControllers.count > 1 {
                    self?.view.endEditing(true)
                    navVC.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true, completion: {
                    })
                }
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
        webviewContainer.delegate = self
        webviewContainer.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        
        self.view.addSubview(infoDisplay)
        infoDisplay.snp.makeConstraints { (maker) in
            maker.edges.equalTo(webviewContainer)
        }
        
        if let urlV = urlString
        {
            let url = URL(string: urlV)
            if let urlV = url
            {
                EnvContext.shared.toast.showLoadingToast("加载中")
                webviewContainer.loadRequest(URLRequest(url: urlV))
            }
        }
        
        stayTimeParams = tracerParams <|> traceStayTime()
        
        
        view.addSubview(infoDisplay)
        infoDisplay.icon.image = UIImage(named: "group-4")
        infoDisplay.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(webviewContainer)
        }
        
        self.errorVM = NHErrorViewModel(
            errorMask: infoDisplay,
            requestRetryText: "网络异常",
            requestNilDataText: "啊哦～您还没收到相关消息",
            requestNilDataImage: "empty_message",
            requestErrorText: "网络异常",
            isUserClickEnable: false)
        
        self.errorVM?.onRequestViewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        EnvContext.shared.toast.dismissToast()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        EnvContext.shared.toast.dismissToast()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webviewContainer.scrollView.contentSize.height != 0
        {
            readPct = Int64((webviewContainer.scrollView.contentOffset.y + self.view.frame.size.height) / webviewContainer.scrollView.contentSize.height * 100)
            if let pct = readPct, pct > Int64(100)
            {
                readPct = Int64(100)
            }
        }
        
        //如果不传event，则不上报
        if let stayTimeParams = stayTimeParams, let eventName = stayPageTraceName {
            let reportTraceParam = TracerParams.momoid() <|>
                stayTimeParams <|>
                toTracerParams(readPct ?? 0, key: "read_pct")
            recordEvent(key: eventName, params: reportTraceParam)
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
