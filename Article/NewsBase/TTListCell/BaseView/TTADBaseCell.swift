//
//  TTADBaseCell.swift
//  Article
//
//  Created by Yang Xinyu on 2/4/16.
//
//

import UIKit

// MARK: - TTADBaseCell
/** 广告类型基类 */
class TTADBaseCell: ExploreCellBase {
    /** 功能区控件 */
    lazy var functionView: TTArticleFunctionView = {
        [unowned self] in
        let functionView = TTArticleFunctionView()
        functionView.delegate = self
        self.cellView!.addSubview(functionView)
        return functionView
    }()
    
    /** 更多控件 */
    lazy var moreView: SSThemedButton =  {
        [unowned self] in
        let moreView = SSThemedButton()
        moreView.imageName = "function_icon"
        let side = kMoreViewSide() + kMoreViewExpand() * 2
        moreView.frame = CGRectMake(0, 0, side, side)
        moreView.addTarget(self, action: #selector(self.moreViewClick), forControlEvents: .TouchUpInside)
        self.cellView!.addSubview(moreView)
        return moreView
    }()
    
    /** 标题控件 */
    lazy var titleView: TTLabel = {
        [unowned self] in
        var titleView = TTLabel()
        titleView.textColor = TTUISettingHelper.cellViewTitleColor()
        titleView.backgroundColor = UIColor.clearColor()
        titleView.numberOfLines = kTitleViewLineNumber()
        titleView.lineHeight = kTitleViewLineHeight()
        titleView.font = UIFont.tt_fontOfSize(kTitleViewFontSize())
        titleView.lineBreakMode = .ByTruncatingTail
        self.cellView!.addSubview(titleView)
        return titleView
    }()
    
    /// 图片(视频)控件
    lazy var picView: TTArticlePicView = {
        [unowned self] in
        var picView = TTArticlePicView(style: .None)
        self.cellView!.addSubview(picView)
        return picView
    }()
    
    /** 相关信息 */
    lazy var sourceName: SSThemedLabel = {
        [unowned self] in
        var sourceName = SSThemedLabel()
        sourceName.textColorThemeKey = kColorText9
        sourceName.font = UIFont.tt_fontOfSize(15)
        self.cellView!.addSubview(sourceName)
        return sourceName
    }()
    
//    /** 相关子信息 */
//    lazy var sourceSize: SSThemedLabel = {
//        [unowned self] in
//        var sourceSize = SSThemedLabel()
//        sourceSize.textColorThemeKey = kColorText9
//        sourceSize.font = UIFont.tt_fontOfSize(12)
//        self.cellView!.addSubview(sourceSize)
//        return sourceSize
//    }()
    
    /** 下载按钮 */
    lazy var actionButton: ExploreActionButton = {
        [unowned self] in
        var actionButton = ExploreActionButton()
        actionButton.addTarget(self, action: #selector(self.downloadButtonActionFired(_:)), forControlEvents: .TouchUpInside)
        actionButton.titleLabel!.font = UIFont.tt_fontOfSize(12)
        actionButton.titleLabel!.textColor = UIColor.tt_themedColorForKey(kColorText6)
        actionButton.frame = CGRectMake(0, 0, 72, 30)
        self.cellView!.addSubview(actionButton)
        return actionButton
    }()
    
    /** 信息栏控件 */
    lazy var infoView: TTArticleInfoView = {
        [unowned self] in
        var infoView = TTArticleInfoView()
        infoView.delegate = self
        self.cellView!.addSubview(infoView)
        return infoView
    }()
    
    /** 广告信息栏控件 */
    lazy var ADInfoView: TTADInfoView = {
        [unowned self] in
        var ADInfoView = TTADInfoView()
        self.cellView!.addSubview(ADInfoView)
        return ADInfoView
        }()
    
    /** 创意广告不感兴趣按钮*/
    lazy var accessoryButton: TTAlphaThemedButton = {
        [unowned self] in
        var accessoryButton = TTAlphaThemedButton.init(frame: CGRectMake(0, 0, 30, 25))
        accessoryButton.imageName = "add_textpage"
        accessoryButton.addTarget(self, action: #selector(self.accessoryButtonClicked(_:)), forControlEvents: .TouchUpInside)
        self.cellView!.addSubview(accessoryButton)
        return accessoryButton
        }()
    
    /** 创意广告Action控件 */
    lazy var ADActionView: TTADActionView = {
        [unowned self] in
        var ADActionView = TTADActionView()
        self.cellView!.addSubview(ADActionView)
        return ADActionView
        }()

    
    /// 底部分割线
    lazy var bottomLineView: SSThemedView = {
        [unowned self] in
        var bottomLineView = SSThemedView()
        bottomLineView.backgroundColorThemeKey = kBottomLineViewBackgroundColor()
        self.cellView!.addSubview(bottomLineView)
        return bottomLineView
    }()
    
    /** 视图是否高亮 */
    private var isViewHighlighted: Bool = false {
        didSet {
            if self.isViewHighlighted {
                self.backgroundColor = TTUISettingHelper.cellViewHighlightedBackgroundColor()
            }
            else{
                self.backgroundColor = TTUISettingHelper.cellViewBackgroundColor()
            }
            self.contentView.backgroundColor = self.backgroundColor
        }
    }
    
    let itemActionManager = ExploreItemActionManager()
    
    lazy var activityActionManager = TTActivityShareManager()
    
    var phoneShareView: SSActivityView?
    
    var orderedData: ExploreOrderedData? {
        didSet {
            self.originalData = self.orderedData?.originalData
        }
    }
    
    var originalData: ExploreOriginalData?
    
    var readPersistAD: Bool = false {
        didSet {
            self.titleView.highlighted = self.readPersistAD
            self.functionView.updateReadState(self.readPersistAD)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = TTUISettingHelper.cellViewBackgroundColor()
        self.contentView.backgroundColor = self.backgroundColor
    }
    
    override init(tableView: UITableView?, reuseIdentifier: String?) {
        super.init(tableView: tableView, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        self.orderedData = nil
    }
    
    override func themeChanged(notification: NSNotification?) {
        super.themeChanged(notification)
        if self.isViewHighlighted {
            self.backgroundColor = TTUISettingHelper.cellViewHighlightedBackgroundColor()
        }
        else{
            self.backgroundColor = TTUISettingHelper.cellViewBackgroundColor()
        }
        self.contentView.backgroundColor = self.backgroundColor
        self.titleView.textColor = TTUISettingHelper.cellViewTitleColor()
    }
    
    override func cellData() -> AnyObject? {
        return self.orderedData
    }
    
    lazy var extraDic: [NSObject: AnyObject] = {
        [unowned self] in
        var extraDic = [NSObject: AnyObject]()
        if let orderedData = self.orderedData, originalData = orderedData.originalData {
            if let uniqueID = originalData.uniqueID {
                extraDic["item_id"] = uniqueID
            }
            if let categoryID = orderedData.categoryID {
                extraDic["category_id"] = categoryID
            }
            if let concernID = orderedData.concernID {
                extraDic["concern_id"] = concernID
            }
            extraDic["refer"] = self.refer
            extraDic["gtype"] = 1
        }
        return extraDic
    }()
}

// MARK: 控件更新
extension TTADBaseCell {
    /** 更新功能区 */
    func updateFunctionView() {
        if let orderedData = self.orderedData {
            self.functionView.updateADFunction(orderedData)
        }
    }
    
    
    /** 更新标题 */
    func updateTitleView(fontSize: CGFloat = kTitleViewFontSize(), isAction: Bool = false) {
        if let orderedData = self.orderedData {
            //拨打电话的大标题用title，app下载用description字段
            if isAction {
                if let adModel = orderedData.persistentAD()?.adModel ?? orderedData.article()?.adModel {
                    let call2Action = (adModel.type == "action")
                    if let title = (call2Action ? adModel.title : adModel.descInfo) {
                        self.titleView.font = UIFont.tt_fontOfSize(fontSize)
                        self.titleView.lineHeight = kTitleViewLineHeight()
                        self.titleView.text = title
                        self.titleView.highlighted = orderedData.originalData?.hasRead?.boolValue ?? false
                    } else {
                        self.titleView.text = nil
                    }
                }
            } else if let persistentAD = orderedData.persistentAD(), title = persistentAD.title {
                self.titleView.font = UIFont.tt_fontOfSize(fontSize)
                self.titleView.lineHeight = kTitleViewLineHeight()
                self.titleView.text = title
                self.titleView.highlighted = persistentAD.hasRead?.boolValue ?? false
            } else {
                self.titleView.text = nil
            }
        }
    }
    
    /** 更新图片(视频) */
    func updatePicView() {
        if let orderedData = self.orderedData {
            self.picView.updateADPics(orderedData)
        }
    }
    
    /** 更新相关信息 */
    func updateSourceView() {
        if let orderedData = self.orderedData {
            var adModel: ExploreOrderedADModel? = nil
            if let persistentAD = orderedData.persistentAD(), model = persistentAD.adModel {
                adModel = model
            } else if let article = orderedData.article(), model = article.adModel {
                adModel = model
            }
            if let model = adModel {
                let call2Action = model.type == "action"
                self.sourceName.text = (call2Action ? model.descInfo : model.appName)
//                self.sourceSize.text = (call2Action ? model.appName : model.descInfo)
            }
        }
    }
    
    /** 更新下载按钮 */
    func updateActionView() {
        if let orderedData = self.orderedData {
            self.actionButton.actionModel = orderedData
            var adModel: ExploreOrderedADModel? = nil
            if let persistentAD = orderedData.persistentAD(), model = persistentAD.adModel {
                adModel = model
            } else if let article = orderedData.article(), model = article.adModel {
                adModel = model
            }
            if let model = adModel {
                self.actionButton.adModel = model
                let call2Action = model.type == "action"
                if call2Action {
                    self.actionButton.setIconImageNamed("callicon_ad_textpage")
                } else {
                    self.actionButton.setIconImageNamed(nil)
                }
            }
        }
    }
    
    /** 更新信息栏 */
    func updateInfoView() {
        if let orderedData = self.orderedData {
            self.infoView.updateInfoView(orderedData)
        }
    }
    
    /** 更新广告信息栏 */
    func updateADInfoView() {
        if let orderedData = self.orderedData {
            self.ADInfoView.updateInfoView(orderedData)
        }
    }
    
    /** 更新广告信息栏 */
    func updateADActionView() {
        if let orderedData = self.orderedData {
            self.ADActionView.updateADActionView(orderedData)
        }
    }
    
    /** 更新底部分割线 */
    func updateBottomLineView() {}
    
    /** 布局更多控件 */
    func layoutMoreView() {
        self.moreView.right = self.cellView!.width - kPaddingRight() + kMoreViewExpand()
        self.moreView.centerY = self.functionView.centerY
        if let actionList = self.orderedData?.actionList as? [[NSObject: AnyObject]] where actionList.count > 0 {
            self.moreView.hidden = false
        } else {
            self.moreView.hidden = true
        }
    }
    
    class func preferredContentTextSize() -> CGFloat {
        return kTitleViewFontSize()
    }
}

// MARK: 不感兴趣按钮
extension TTADBaseCell {
    func accessoryButtonClicked(sender: AnyObject!) {
        if let accessoryButton = sender as? UIButton {
            var p = accessoryButton.origin
            p.x += 8
            p.y += 6
            
            let popupView = ExploreDislikeView()
            popupView.delegate = self
            popupView.refreshWithData(self.orderedData)
            
            popupView.showAtPoint(p, fromView: accessoryButton)
        }
    }
}


// MARK: 下载按钮协议
extension TTADBaseCell {
    func downloadButtonActionFired(sender: AnyObject!) {
        if let orderedData = self.orderedData {
            SSADEventTracker.sharedManager().trackEventWithOrderedData(orderedData, label: "click", eventName: "embeded_ad", extra: "2")
            SSADEventTracker.sharedManager().trackEventWithOrderedData(orderedData, label: "click_start", eventName: "feed_download_ad")
            let duration = SSADEventTracker.sharedManager().durationForAdThisTime(orderedData.adID)
            SSADEventTracker.sharedManager().trackEventWithOrderedData(orderedData,  label:"show_over", eventName:"embeded_ad", extra:nil, duration:duration)
            var adModel: ExploreOrderedADModel? = nil
            if let persistentAD = orderedData.persistentAD(), model = persistentAD.adModel {
                adModel = model
            } else if let article = orderedData.article(), model = article.adModel {
                adModel = model
            }
            if let model = adModel {
                if model.adType() == ExploreActionType.Action {
                    SSADEventTracker.sharedManager().trackEventWithOrderedData(orderedData, label: "click_call", eventName: "feed_call", extra: "2")
                }
                self.actionButton.actionButtonClicked(sender, showAlert: sender != nil)
            }
        }
    }
}


// MARK: 更多控件协议
extension TTADBaseCell: TTMoreViewProtocol, TTDislikePopViewDelegate {
    func moreViewClick() {
        self.showMenu()
        SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "click_more", value: tt_lastGroupId?.stringValue, source: nil, extraDic: self.extraDic)
    }
    
    func showMenu() {
        guard let orderedData = self.orderedData else {
            return
        }
        
        guard let actionList = orderedData.actionList as? [[NSObject: AnyObject]] where actionList.count > 0 else {
            return
        }
        
        var actionItem = [TTActionListItem]()
        for action in actionList {
            if let type = action["action"] as? Int {
                switch type {
                    // 不感兴趣
                case 1:
                    var description = "不感兴趣"
                    let iconName = "ugc_icon_not_interested"
                    if let desc = action["desc"] as? String where desc != ""{
                        description = desc
                    }
                    var dislikeWords = [ExploreDislikeWord]()
                    
                    var groupId: NSNumber?
                    if let article = orderedData.article() {
                        groupId = article.uniqueID
                    } else if let persistentAD = orderedData.persistentAD() {
                        groupId = persistentAD.uniqueID
                    }
                    if groupId == nil {
                        break
                    }
                    if let filterWords = orderedData.article()?.filterWords as? [[NSObject: AnyObject]] {
                        for words in filterWords {
                            let word = ExploreDislikeWord(dict: words)
                            dislikeWords.append(word)
                        }
                    } else if let filterWords = orderedData.persistentAD()?.filterWords as? [[NSObject: AnyObject]] {
                        for words in filterWords {
                            let word = ExploreDislikeWord(dict: words)
                            dislikeWords.append(word)
                        }
                    }
                    
                    var extraValueDic = [NSObject: AnyObject]()
                    if let logExtra = orderedData.logExtra {
                        extraValueDic["log_extra"] = logExtra
                    }
                    
                    if dislikeWords.count > 0 {
                        let item = TTActionListItem(description: description, iconName: iconName, hasSub: true) {
                            if let orderedData = self.orderedData {
                                tt_actionPopView?.showDislikeView(orderedData, dislikeWords: dislikeWords, groupID: groupId!)
                            }
                            SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "show_dislike_with_reason", value: tt_lastGroupId?.stringValue, source: nil, extraDic: extraValueDic)
                        }
                        actionItem.append(item)
                    } else {
                        let item = TTActionListItem(description: description, iconName: iconName, hasSub: false) {
                            [unowned self] in
                            if let orderedData = self.orderedData {
                                tt_actionPopView?.showDislikeView(orderedData, dislikeWords: dislikeWords, groupID: groupId!)
                            }
                            self.dislikeButtonClicked([String]())
                        }
                        actionItem.append(item)
                    }
                    // 不喜欢某一项
                case 2:
                    let iconName = "ugc_icon_dislike"
                    if let desc = action["desc"] as? String where desc != "", let filterWord = action["extra"] as? [NSObject: AnyObject], let dislikeId = ExploreDislikeWord(dict: filterWord).ID {
                        let item = TTActionListItem(description: desc, iconName: iconName) {
                            [unowned self] in
                            self.dislikeButtonClicked([dislikeId], onlyOne:  true)
                        }
                        actionItem.append(item)
                    }
                case 7:
                    if orderedData.article() == nil {
                        break
                    }
                    let iconName = "ugc_icon_share"
                    var description = "分享"
                    if let desc = action["desc"] as? String where desc != ""{
                        description = desc
                    }
                    let item = TTActionListItem(description: description, iconName: iconName) {
                        [unowned self] in
                        var adID: NSNumber?
                        if let str = orderedData.article()?.adModel?.adID, num = Int64(str) {
                            adID = NSNumber(longLong: num)
                        }
                        
                        let activityItems = ArticleShareManager.shareActivityManager(self.activityActionManager, setArticleCondition: orderedData.article()!, adID: adID, showReport: false)
                        var group1 = [TTActivity]()
                        for activity  in activityItems {
                            if let acti = activity as? TTActivity {
                                group1.append(acti)
                            }
                        }
                        self.phoneShareView = SSActivityView()
                        self.phoneShareView?.delegate = self
                        self.phoneShareView?.showActivityItems([group1])
                        SSTrackerBridge.ssTrackEventWithCustomKeys("list_share", label: "share_button", value: tt_lastGroupId?.stringValue, source: nil, extraDic: self.extraDic)
                    }
                    actionItem.append(item)
                    // 举报
                case 9:
                    if orderedData.article() == nil {
                        break
                    }
                    let iconName = "ugc_icon_report"
                    var description = "举报"
                    if let desc = action["desc"] as? String where desc != ""{
                        description = desc
                    }
                    let item = TTActionListItem(description: description, iconName: iconName) {
                        [unowned self] in
                        self.triggerReportAction()
                        SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "report", value: self.orderedData?.article()?.uniqueID?.stringValue, source: nil, extraDic: self.extraDic)
                    }
                    actionItem.append(item)
                default:
                    break
                }
            } else {
                continue
            }
        }
        
        guard actionItem.count > 0 else {
            return
        }
        
        let popupView = TTActionPopView(actionItems: actionItem, width: self.cellView!.width)
        popupView.delegate = self
        let p = self.moreView.center
        popupView.showAtPoint(p, fromView: self.moreView)
    }
    
    func dislikeButtonClicked(selectedWords: [String], onlyOne: Bool = false) {
        guard let orderedData = self.orderedData else {
            return
        }
        var userInfo = [NSObject: AnyObject]()
        userInfo[kExploreMixListNotInterestItemKey] = orderedData
        
        var extraValueDic = [NSObject: AnyObject]()
        if let logExtra = orderedData.logExtra {
            extraValueDic["log_extra"] = logExtra
        }
        
        if selectedWords.count > 0 {
            userInfo[kExploreMixListNotInterestWordsKey] = selectedWords
            
            if onlyOne {
                SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "confirm_dislike_only_reason", value: tt_lastGroupId?.stringValue, source: nil, extraDic: extraValueDic)
            } else {
                SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "confirm_dislike_with_reason", value: tt_lastGroupId?.stringValue, source: nil, extraDic: extraValueDic)
            }
        } else {
            SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "confirm_dislike_no_reason", value: tt_lastGroupId?.stringValue, source: nil, extraDic: extraValueDic)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kExploreMixListNotInterestNotification, object: self, userInfo: userInfo)
    }
}

// MARK: 功能区协议
extension TTADBaseCell: TTFunctionViewProtocol {
    func functionViewLikeViewClick() {
        if let orderedData = self.orderedData, recommendUrl = orderedData.recommendUrl where recommendUrl != "" {
            SSAppPageManager.sharedManager().openURL(SSCommon.URLWithURLString(recommendUrl))
            SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "click_reason", value: self.orderedData?.article()?.uniqueID?.stringValue, source: nil, extraDic: self.extraDic)
        }
    }
    
    func functionViewPGCClick() {
        if let orderedData = self.orderedData, article = orderedData.article() {
            if let sourceUrl = article.sourceOpenUrl {
                SSAppPageManager.sharedManager().openURL(SSCommon.URLWithURLString(sourceUrl))
                SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "click_source", value: self.orderedData?.article()?.uniqueID?.stringValue, source: nil, extraDic: self.extraDic)
            }
        }
    }
}

// MARK: 信息栏协议
extension TTADBaseCell: TTInfoViewProtocol {
    func digButtonClick(button: TTDiggButton) {
        guard self.originalData != nil else {
            return
        }
        
        if self.originalData!.userDigg?.boolValue == true {
            TTIndicatorView.showWithIndicatorStyle(.Image, indicatorText: SSLocalizedString("您已经赞过", nil), indicatorImage: nil, autoDismiss: true, dismissHandler: nil)
            return
        }
        self.originalData!.userDigg = true
        var diggCount = self.originalData!.diggCount?.integerValue
        if diggCount == nil {
            diggCount = 0
        }
        diggCount! += 1
        self.originalData!.diggCount = diggCount
        button.setDiggCount(Int64(diggCount!))
        let centerY = button.centerY
        button.sizeToFit()
        button.centerY = centerY        
        
        do {
            try SSModelManager.sharedManager().save()
        } catch {
            print("save fail with error")
        }
        
        self.itemActionManager.sendActionForOriginalData(self.originalData, adID: nil, actionType: DetailActionTypeDig, finishBlock: {
            (userInfo: AnyObject?,error: NSError?) in
        })
        
        SSTrackerBridge.ssTrackEventWithCustomKeys("new_list", label: "like", value: self.orderedData?.article()?.uniqueID?.stringValue, source: nil, extraDic: self.extraDic)

    }
}

extension TTADBaseCell: SSActivityViewDelegate {
    func activityView(view: SSActivityView?, didCompleteByItemType itemType: TTActivityType) {
        if view == self.phoneShareView {
            let uniqueID = self.orderedData?.article()?.uniqueID?.stringValue
            let hasVideo = self.orderedData?.article()?.hasVideo?.boolValue == true || self.orderedData?.article()?.isVideoSubject() == true
            self.activityActionManager.performActivityActionByType(itemType, inViewController: SSCommonAppExtension.topViewControllerFor(self)!, sourceObjectType: hasVideo ? TTShareSourceObjectType.VideoList : TTShareSourceObjectType.UGCFeed, uniqueId: uniqueID, adID: nil, platform: TTSharePlatformType.OfMain, groupFlags: self.orderedData?.article()?.groupFlags)
            self.phoneShareView = nil
            
            if let label = TTActivityShareManager.labelNameForShareActivityType(itemType) {
                SSTrackerBridge.ssTrackEventWithCustomKeys("list_share", label: label, value: tt_lastGroupId?.stringValue, source: nil, extraDic: self.extraDic)
            }
        }
    }
    
    func triggerReportAction() {
        guard let article = self.orderedData?.article() else {
            return
        }
        let reportViewController: ArticleReportViewController
        if article.hasVideo?.boolValue == true {
            reportViewController = ArticleReportViewController(groupModel: article.groupModel(), videoID: article.videoID, viewStyle: ArticleReportViewStyle.NormalStyle, reportType: ArticleReportType.Video, source: "cell")
        } else {
            reportViewController = ArticleReportViewController(groupModel: article.groupModel(), videoID: nil, viewStyle: ArticleReportViewStyle.NormalStyle, reportType: ArticleReportType.Article, source: "cell")
            reportViewController.adId = self.orderedData?.adID?.stringValue
        }
        let nav = TTNavigationController(rootViewController: reportViewController)
        if SSCommon.isPadDevice() {
            nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        }
        SSCommonAppExtension.topViewControllerFor(self)?.presentViewController(nav, animated: true, completion: nil)
    }
}

extension TTADBaseCell: ExploreDislikeViewDelegate {
    func exploreDislikeViewOKBtnClicked(dislikeView:ExploreDislikeView) {
        
        if (SSMenuController.shareMenuController().menuVisible()) {
            SSMenuController.shareMenuController().setMenuVisible(false, animated: true)
        }
        
        if (self.orderedData == nil) {
            return;
        }
        
        var userInfo = [NSObject: AnyObject]()
        userInfo[kExploreMixListNotInterestItemKey] = orderedData
        
        let filterWords = dislikeView.selectedWords()
        if (filterWords.count > 0) {
            userInfo[kExploreMixListNotInterestWordsKey] = filterWords
        }
        if (SSMenuController.shareMenuController().menuVisible()) {
            SSMenuController.shareMenuController().setMenuVisible(false, animated: true)
        }
        
        //打点统计
//        if ([self.orderedData.cellType intValue] == ExploreOrderedDataCellTypeLoginGuide) {
//            if ([[AccountManager sharedManager] isLogin]) {
//                ssTrackEvent(@"login_register", @"feed_login_dislike_1");
//            } else {
//                ssTrackEvent(@"login_register", @"feed_login_dislike");
//            }
//        } else if (self.orderedData.cellType.integerValue == ExploreOrderedDataCellTypeAction) {
//            /// celltype=Action的广告需要统计不感兴趣
//            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"dislike" eventName:@"feed_call"];
//        } else if ([self.orderedData.article.adModel.type isEqualToString:@"call"]) {
//            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.orderedData label:@"dislike" eventName:@"feed_call"];
//        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kExploreMixListNotInterestNotification, object: self, userInfo: userInfo)
    }
}

