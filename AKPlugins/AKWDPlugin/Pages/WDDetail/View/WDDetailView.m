//
//  WDDetailView.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  文章详情页正文部分。对TTWebView进行了封装，并增加文章相关业务逻辑

#import "WDDetailView.h"
#import "WDMonitorManager.h"
#import "WDCommonLogic.h"
#import "WDDefines.h"
#import "WDAnswerEntity.h"
#import "WDDetailViewModel.h"
#import "WDDetailModel.h"
#import "WDSettingHelper.h"
#import "WDAdapterSetting.h"

#import "TTGroupModel.h"
#import "TTDetailWebviewContainer+JSImageVideoLogic.h"
#import "TTOriginalDetailWebviewContainer.h"
#import "SSAppStore.h"
#import "TTFollowManager.h"
#import "SSImpressionManager.h"
#import "PGCAccount.h"
#import "TTNavigationController.h"
#import "NetworkUtilities.h"
#import "NSDictionary+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTIndicatorView.h"
#import "TTPhotoScrollViewController.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import <TTAccountBusiness.h>
#import <TTInteractExitHelper.h>
#import "WDDefines.h"
#import <TTBaseLib/TTURLUtils.h>

typedef NS_ENUM(NSInteger, SSWebViewStayStat) {
    SSWebViewStayStatCancel,
    SSWebViewStayStatLoadFinish,
    SSWebViewStayStatLoadFail,
};

#pragma mark - WDDetailWebViewFooter
//给浮层包一层，相当于重构前的superNatantview
@interface WDDetailWebViewFooter : SSThemedView <TTDetailFooterViewProtocol>
@end

@implementation WDDetailWebViewFooter
@synthesize footerScrollView;
@end

#pragma mark - WDDetailTracker

@interface WDDetailTracker : NSObject

@property(nonatomic, strong) WDDetailModel *detailModel;
@property(nonatomic, strong) TTDetailWebviewContainer *detailWebView;

@property(nonatomic, strong) NSDate *startLoadDate;
@property(nonatomic, strong) NSMutableArray *jumpLinks;
@property(nonatomic, assign) BOOL userHasClickLink;

@end

@implementation WDDetailTracker

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel
                      detailWebView:(TTDetailWebviewContainer *)detailWebView
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
        _detailWebView = detailWebView;
        
        //有ADID的需要统计webview的加载时间,从进入就开始计时
        _startLoadDate = [NSDate date];
        _jumpLinks = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)tt_resetStartLoadDate
{
    self.startLoadDate = nil;
}

- (void)tt_sendStartLoadDateTrackIfNeeded
{
    if (self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
        [dict setValue:@"domReady" forKey:@"tag"];
        
        if (!isEmptyString(self.detailModel.answerEntity.logExtra)) {
            [dict setValue:self.detailModel.answerEntity.logExtra forKey:@"log_extra"];
        } else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        //加载时间 等扩展字段
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startLoadDate];
        [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"item_id"];
        [TTTracker eventData:dict];
    }
}

- (void)tt_sendStatStayEventTrack:(SSWebViewStayStat)stat error:(NSError *)error
{
    /// 这里的顺序与 _SSWebViewStat 定义的顺序一致
    NSArray *tags = @[@"load", @"load_finish", @"load_fail"];
    if (stat >= tags.count) {
        return;
    }
    //之前是针对ad的 现在扩展到所有详情页-- add 5.1 nick
    if (!_detailWebView.webView.canGoBack && self.startLoadDate) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
        [dict setValue:tags[stat] forKey:@"tag"];
        // 这里的加载时间是指从一开始LoadRequest就开始记时，到加载结束
        if (stat == SSWebViewStayStatLoadFail && error) {
            [dict setValue:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"error"];
        } else {
            /// 需要减去后台停留时间
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
            [dict setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"load_time"];
        }
        if (_userHasClickLink) {
            [dict setValue:@(YES) forKey:@"hasClickLink"];
        }
        if (!isEmptyString(_detailModel.answerEntity.logExtra)) {
            [dict setValue:_detailModel.answerEntity.logExtra forKey:@"log_extra"];
        }
        //以后如果有了广告
        //        else if (!isEmptyString(_detailModel.article.adModel.logExtra)) {
        //            [dict setValue:_detailModel.article.adModel.logExtra forKey:@"log_extra"];
        //        }
        else {
            [dict setValue:@"" forKey:@"log_extra"];
        }
        [TTTracker eventData:dict];
        // 这里要把这个变成空的，下次如果看到时间是空的，则不重新发送统计。
        [self tt_resetStartLoadDate];
    }
}

- (void)tt_sendReadTrackWithPCT:(CGFloat)pct
                      pageCount:(NSInteger)pageCount
{
    NSInteger percent = 0;        //百分比
    percent = (NSInteger)(pct * 100);
    if (percent <= 0) {
        percent = 0;
    }
    if (percent >= 100) {
        percent = 100;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    
//    [dict setValue:@"article" forKey:@"category"];
//    [dict setValue:@"read_pct" forKey:@"tag"];
//    [dict setValue:self.detailModel.enterFrom forKey:@"label"];
//    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    [dict setValue:@(percent) forKey:@"pct"];
    [dict setValue:@(pageCount) forKey:@"page_count"];
    if (!isEmptyString(self.detailModel.answerEntity.ansid)) {
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"item_id"];
    }
    [dict removeObjectForKey:@"origin_source"];
//    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//        [TTTracker eventData:dict];
//    }
    
    //Wenda_V3_DoubleSending
    NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [v3Dic setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
    [v3Dic setValue:@(percent) forKey:@"percent"];
    [v3Dic setValue:@(pageCount) forKey:@"page_count"];
    if ([self.detailModel.gdExtJsonDict[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
        [v3Dic setValue:self.detailModel.gdExtJsonDict[@"log_pb"][@"impr_id"] forKey:@"impr_id"];
    }
    [v3Dic setValue:@"house_app2c_v2" forKey:@"event_type"];
    [v3Dic setValue:[self.detailModel.gdExtJsonDict tt_stringValueForKey:@"category_name"] forKey:@"category_name"];
    [v3Dic removeObjectForKey:@"origin_source"];
    [v3Dic removeObjectForKey:@"author_id"];
    [v3Dic removeObjectForKey:@"article_type"];
    [v3Dic removeObjectForKey:@"pct"];
    v3Dic[@"event_type"] = @"house_app2c_v2";

    [TTTracker eventV3:@"read_pct" params:v3Dic isDoubleSending:NO];
}

- (void)tt_sendStayTimeImpresssion
{
    // record UnitStayTime
    if ([SSImpressionManager fetchImpressionPolicy] & 0x20) {
        NSMutableDictionary * impressionGroup = [_detailWebView readUnitStayTimeImpressionGroup];
        // key_name与android格式保持一致<groupid>_<index>_<url>，index和url目前用不到，暂时为0，后台有需求时再加
        NSString *keyName = self.detailModel.answerEntity.ansid;
        [impressionGroup setValue:keyName forKey:@"key_name"];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:self.detailModel.answerEntity.ansid forKey:@"item_id"];
        [impressionGroup setValue:extra forKey:@"extra"];
        
        [[SSImpressionManager shareInstance] addImpressionGroupFromDictionary:impressionGroup];
    }
}
@end

#pragma mark - WDDetailMonitor

@interface WDDetailMonitor : NSObject

@property (nonatomic, assign) CFTimeInterval webRequestStartTime;
@property (nonatomic, strong) NSMutableDictionary *serverRequestStartTimeDict;

- (void)initializeWebRequestTimeMonitor;
- (void)initializeServerRequestTimeMonitorWithName:(NSString *)apiName;
- (NSString *)intervalFromWebRequestStartTime;
- (NSString *)intervalFromServerRequestStartTimeWithName:(NSString *)apiName;

@end

@implementation WDDetailMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverRequestStartTimeDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initializeWebRequestTimeMonitor
{
    _webRequestStartTime = CACurrentMediaTime();
}

- (void)initializeServerRequestTimeMonitorWithName:(NSString *)apiName
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [_serverRequestStartTimeDict setValue:@(startTime) forKey:apiName];
}

- (NSString *)intervalFromWebRequestStartTime
{
    CFTimeInterval interval = _webRequestStartTime ? (CACurrentMediaTime() - _webRequestStartTime) * 1000.f : 0;
    //过滤异常数据：非正数或大于100s则过滤
    if (interval <= 0 || interval > 100.f * 1000.f) {
        return nil;
    }
    else {
        return [NSString stringWithFormat:@"%.1f", interval];
    }
}

- (NSString *)intervalFromServerRequestStartTimeWithName:(NSString *)apiName
{
    CFTimeInterval startTime = (CFTimeInterval)[_serverRequestStartTimeDict floatValueForKey:apiName defaultValue:0];
    CFTimeInterval interval = startTime ? (CACurrentMediaTime() - startTime) * 1000.f : 0;
    return [NSString stringWithFormat:@"%.1f", interval];
}

@end

#pragma mark - WDDetailView

@interface WDDetailView () </*YSWebViewDelegate,*/ TTDetailWebviewDelegate, TTDetailWebViewRequestProcessorDelegate, UIScrollViewDelegate>
{
    BOOL _didDisAppear;
    BOOL _isWebViewLoading;
    BOOL _webViewHasError;
    BOOL _webviewHasInsertedInformationJS;
    BOOL _webViewHasInsertedContextJS;
    NSString *_latestWebViewRequestURLString;
}

@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, strong) WDDetailTracker *tracker;
@property (nonatomic, strong) WDDetailMonitor *monitor;
@property (nonatomic, strong) WDDetailWebViewFooter *detailWebViewDivFooter;

@property (nonatomic, copy) TTRJSBResponse callback;

@property (nonatomic, weak) TTPhotoScrollViewController *photoScrollViewController;

@end

@implementation WDDetailView

- (nonnull instancetype)initWithFrame:(CGRect)frame
                          detailModel:(WDDetailModel *)detailModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _detailModel = detailModel;
        [self p_initMonitor];
        [self p_initViewModel];
        [self p_detailCommonInit];
        [self p_buildDetailWebView];
        [self p_initTracker];
        [self reloadThemeUI];
        [self addKVO];
    }
    return self;
}

#pragma mark - life cycle

- (void)dealloc
{
    [self p_uploadArticlePositionIfNeed];

    if (self.tracker.startLoadDate) {
        [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        [self.tracker tt_resetStartLoadDate];
    }
    
    [self p_registerArticleDetailCloseCallback];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAppear
{
    [super willAppear];
    [_detailWebView didAppear];
}

- (void)didAppear
{
    [super didAppear];
    _didDisAppear = NO;
}

- (void)didDisappear
{
    [super didDisappear];
    [self.detailWebView didDisappear];
    
    //added 5.7.*:disappear也发送read_pct事件
    if (self.detailWebView) {
        [self.tracker tt_sendReadTrackWithPCT:[self.detailWebView readPCTValue] pageCount:[self.detailWebView pageCount]];
        [self.tracker tt_sendStayTimeImpresssion];
    }
    
    _didDisAppear = YES;
}

#pragma mark - public

- (void)setIsNewVersion:(BOOL)isNewVersion {
    _isNewVersion = isNewVersion;

    if (_isNewVersion) {
        _detailWebView.containerScrollView.backgroundColor = [UIColor clearColor];
    }
}

- (void)tt_startLoadWebViewContent
{
    [self p_registerWebViewUserAgent];
    [self p_registerArticleWebViewJSCallback];
    
    if (_detailModel.answerEntity.answerDeleted) {
        [self p_deleteArticleIfNeeded];
    }
    else {
        [self p_startLoadArticleContent];
    }
}


- (void)tt_loadInformationContent
{
    if (self.domReady) {
        [self p_insertJSContext:self.detailModel.insertedContextJS];
    }
}

- (void)tt_deleteArticleByInfoFetchedIfNeeded
{
    [self p_deleteArticleIfNeeded];
}

- (void)tt_setNatantWithFooterView:(UIView *)footerView
         includingFooterScrollView:(UIScrollView *)footerScrollView
{
    self.detailWebViewDivFooter = [[WDDetailWebViewFooter alloc] initWithFrame:self.bounds];
    [self.detailWebViewDivFooter addSubview:footerView];
    [self.detailWebViewDivFooter setFooterScrollView:footerScrollView];
    TTDetailNatantStyle style = TTDetailNatantStyleAppend;
    if ([[WDSettingHelper sharedInstance_tt] wdDetailShowMode]) {
        style = TTDetailNatantStyleOnlyClick;
    }
    [self.detailWebView addFooterView:self.detailWebViewDivFooter detailFooterAddType:style];
}

- (nonnull UIScrollView *)scrollView
{
    return [self.detailWebView.webView scrollView];
}

- (void)tt_initializeServerRequestMonitorWithName:(NSString *)apiName
{
    [self.monitor initializeServerRequestTimeMonitorWithName:apiName];
}

- (void)tt_serverRequestTimeMonitorWithName:(NSString *)apiName error:(NSError *)error
{
    NSString *intervalStr = [self.monitor intervalFromServerRequestStartTimeWithName:apiName];
    [[TTMonitor shareManager] trackService:apiName value:intervalStr extra:[WDMonitorManager extraDicWithAnswerId:self.detailModel.answerEntity.ansid error:error]];
}

#pragma mark - private

- (void)p_initTracker
{
    _tracker = [[WDDetailTracker alloc] initWithDetailModel:_detailModel
                                              detailWebView:_detailWebView];
}

- (void)p_initMonitor
{
    _monitor = [[WDDetailMonitor alloc] init];
}

- (void)p_initViewModel
{
    // 这点代码真NC
    _detailViewModel = [[WDDetailViewModel alloc] initWithDetailModel:self.detailModel];
}

- (void)p_detailCommonInit
{
    [self reloadThemeUI];
    [self p_addNotiCenterObservers];
}

- (void)p_buildDetailWebView
{
    if ([TTDeviceHelper OSVersionNumber] >= 9.0  || [WDCommonLogic isWDDetailNatantNewStyleEnable]) {
        _detailWebView = [[TTDetailWebviewContainer alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)
                                                        disableWKWebView:YES hiddenWebView:nil webViewDelegate:nil];
    } else {
        _detailWebView = [[TTOriginalDetailWebviewContainer alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)
                                                                disableWKWebView:YES hiddenWebView:nil webViewDelegate:nil];
    }
    
    _detailWebView.delegate = self;
    _detailWebView.natantStyle = TTDetailNatantStyleAppend; // 这里还不能改动？
    if ([[WDSettingHelper sharedInstance_tt] wdDetailShowMode]) {
        _detailWebView.natantStyle = TTDetailNatantStyleOnlyClick;
    }
    _detailWebView.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _detailWebView.webView.opaque = NO;
    _detailWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_detailWebView];
    
    [self tt_startLoadWebViewContent];
}

- (void)addKVO
{
    [self.KVOController observe:self.detailModel.answerEntity keyPath:@"isDigg" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSNumber *newDigg = change[NSKeyValueChangeNewKey];
        NSNumber *oldDigg = change[NSKeyValueChangeOldKey];
        if (![oldDigg isEqual:newDigg]) {
            WDDetailView *detailView = observer;
            WDAnswerEntity *entity = object;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setValue:entity.ansid forKey:@"id"];
            [param setValue:newDigg  forKey:@"status"];
            [param setValue:@"wenda_digg" forKey:@"type"];
            [detailView.detailWebView.webView ttr_fireEvent:@"page_state_change" data:param];
        }
        
    }];
}

- (void)p_deleteArticleIfNeeded
{
    if (_detailModel.answerEntity.answerDeleted) {
        _detailModel.answerEntity.content = NSLocalizedString(@"该内容已删除", nil);
        [_detailModel.answerEntity save];
        
        //5.4：文章删除后改为显示native页面
        [self p_startLoadForArticleDeleted];
        
        [WDAnswerEntity deleteObjectsWhere:@"WHERE uniqueID = ?" arguments:@[_detailModel.answerEntity.ansid]];
    }
}

- (void)p_startLoadForArticleDeleted
{
    _isWebViewLoading = NO;
    [self.detailWebView removeFromSuperview];
}

- (void)p_startLoadArticleContent
{
    [self.monitor initializeWebRequestTimeMonitor];
    [self p_startLoadNativeTypeArticle];
    
    [_detailViewModel tt_setArticleHasRead];
}

- (void)p_startLoadNativeTypeArticle
{
    [_detailWebView.webView stopLoading];
    _detailWebView.webView.disableThemedMask = YES;
    NSString * html = [_detailViewModel tt_nativeContentHTMLForWebView:_detailWebView.webView];
    NSURL * baseURL = [_detailViewModel tt_nativeContentFilePath];
    [_detailWebView.webView loadHTMLString:html baseURL:baseURL];
    //    [self p_webViewUpdateFontSize];
    _detailWebView.webView.scalesPageToFit = NO;
}

- (void)p_registerWebViewUserAgent
{
    //换到SSWebview的初始化方法了,这里不用调用
//    [SSWebViewUtil registerUserAgent:YES];
}

- (void)p_registerArticleDetailCloseCallback
{
    [self.detailWebView.webView ttr_fireEvent:@"close" data:nil];

    // 延时释放，确保close事件调用成功
    TTDetailWebviewContainer *detailWebViewContainer = self.detailWebView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这里随便写了一条语句，避免编译器把这个block优化没了
        detailWebViewContainer.natantStyle = 0;
    });
}

- (void)p_registerArticleWebViewJSCallback
{
    [self p_registerFollowCallBack];
    [self p_registerOpposeCallback];
    [self p_registerReportCallback];
    [self p_registerOpenCommentCallback];
    [self p_registerCommentDiggCallback];
    [self p_registerArticleWebViewImageCallback];
}

- (void)p_registerFollowCallBack
{
    __weak typeof(self) wself = self;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __strong typeof(wself) self = wself;
        NSString * userID = [result stringValueForKey:@"id" defaultValue:nil];
        NSString * action = [result stringValueForKey:@"action" defaultValue:nil];
        NSString * source = [result stringValueForKey:@"source" defaultValue:nil];
        FriendActionType type = FriendActionTypeFollow;
        if ([action isEqualToString:@"dofollow"]) {
            type = FriendActionTypeFollow;
        } else {
            type = FriendActionTypeUnfollow;
        }
        NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
        [followDic setValue:userID forKey:@"id"];
        [followDic setValue:@(32) forKey:@"new_reason"];//FriendFollowNewReasonUnknown
        if (!isEmptyString(source)) {
            [followDic setValue:source forKey:@"new_source"];
        } else {
            [followDic setValue:@(28) forKey:@"new_source"]; //FriendFollowNewSourceWendaDetail
        }
        [followDic setValue:kWDDetailViewControllerUMEventName forKey:@"from"];
        
        NSString * from = [result tt_stringValueForKey:@"from"];
        if (isEmptyString(from)) {
            from = @"detail";
        }
        
        void (^followBlock)(void) = ^() {
            self.callback = callback;
            if (type == FriendActionTypeFollow) {
                [[TTFollowManager sharedManager] follow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
                    if (!error) {
                        if (self.detailModel.redPack) {
                            NSMutableDictionary *extraDict = @{}.mutableCopy;
                            [extraDict setValue:self.detailModel.answerEntity.user.userID forKey:@"user_id"];
                            [extraDict setValue:[self.detailModel.gdExtJsonDict tt_stringValueForKey:@"category_name"] forKey:@"category"];
                            [extraDict setValue:from forKey:@"source"];
                            [extraDict setValue:@"detail" forKey:@"position"];
                            [extraDict setValue:self.detailModel.gdExtJsonDict forKey:@"gd_ext_json"];
                            
                            [[WDAdapterSetting sharedInstance] showRedPackViewWithRedPackModel:self.detailModel.redPack extraDict:[extraDict copy] viewController:[TTUIResponderHelper topViewControllerFor:self]];
                            self.detailModel.redPack = nil;
                        }
                    }
                    [self finishActionType:FriendActionTypeFollow error:error result:result];
                }];
            } else {
                [[TTFollowManager sharedManager] unfollow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
                    [self finishActionType:FriendActionTypeUnfollow error:error result:result];
                }];
            }
        };
        
        followBlock();
    } forMethodName:@"user_follow_action"];
    
    
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __strong typeof(wself) self = wself;
        
        if ([self.delegate respondsToSelector:@selector(tt_WDDetailWebViewNextPageFailed)]) {
            [self.delegate tt_WDDetailWebViewNextPageFailed];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"tellClientRetryPrefetch"];
}

- (void)p_registerOpposeCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        BOOL allowBury = self.detailModel.answerEntity.isDigg;
        if ([self.delegate respondsToSelector:@selector(tt_wdDetailViewWillShowOppose:)]) {
            [self.delegate tt_wdDetailViewWillShowOppose:result];
        }
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"err_no" :  @(allowBury)});
        }
    } forMethodName:@"dislike"];
}

- (void)p_registerReportCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(tt_wdDetailViewWillShowReport:)]) {
            [self.delegate tt_wdDetailViewWillShowReport:result];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"report"];
}

- (void)p_registerOpenCommentCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(tt_wdDetailViewWillShowComment:)]) {
            [self.delegate tt_wdDetailViewWillShowComment:result[@"commentId"]];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"openComment"];
}

- (void)p_registerCommentDiggCallback {
    WeakSelf;
    [self.detailWebView.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(tt_wdDetailViewCommentDigg:)]) {
            [self.delegate tt_wdDetailViewCommentDigg:result[@"commentId"]];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"commentDigg"];
}

- (void)p_registerArticleWebViewImageCallback
{
    __weak typeof(self) weakSelf = self;
    //显示webView正文图片
    //问答接口，没有控制imageMode的字段，保留原来默认
    [_detailWebView tt_registerWebImageWithLargeImageModels:[_detailModel.answerEntity detailLargeImageModels] thumbImageModels:[_detailModel.answerEntity detailThumbImageModels] loadImageMode:_detailModel.answerEntity.imageMode showOriginForThumbIfCached:YES evaluateJsCallbackBlock:^(NSString *jsMethod) {
        [weakSelf p_detailWebView:weakSelf.detailWebView.webView stringByEvaluatingJavaScriptFromString:jsMethod];
    }];
    
    [_detailWebView tt_registerCarouselBackUpdateWithCallback:^(NSInteger index, CGRect updatedFrame) {
        NSMutableArray *frames = [weakSelf.photoScrollViewController.placeholderSourceViewFrames mutableCopy];
        updatedFrame = [weakSelf.detailWebView.webView.scrollView convertRect:updatedFrame toView:nil];
        [frames setObject:[NSValue valueWithCGRect:updatedFrame] atIndexedSubscript:index];
        weakSelf.photoScrollViewController.placeholderSourceViewFrames = frames;
    }];
}

- (BOOL)p_checkArticleReliable
{
    return self.detailModel.isArticleReliable;
}

- (void)p_webViewUpdateFontSize
{
    NSString *fontSizeType = [self settedFontShortString];
    NSString *updateFontJS = [NSString stringWithFormat:@"window.TouTiao && TouTiao.setFontSize(\"%@\")", fontSizeType];
    [self p_detailWebView:_detailWebView.webView stringByEvaluatingJavaScriptFromString:updateFontJS];
}

- (NSString*)settedFontShortString
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    NSString *result = @"m";
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            result = @"s";
            break;
        case TTFontSizeSettingTypeNormal:
            result = @"m";
            break;
        case TTFontSizeSettingTypeBig:
            result = @"l";
            break;
        case TTFontSizeSettingTypeLarge:
            result = @"xl";
            break;
        default:
            break;
    }
    
    return result;
}

- (void)p_refreshDetailTheme
{
    if(![TTDeviceHelper isPadDevice] && self.detailModel.answerEntity)
    {
        if (self.domReady) {
            NSString *js = [NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay];
            [self p_detailWebView:self.detailWebView.webView stringByEvaluatingJavaScriptFromString:js];
        }
    }
}

- (NSString *)p_detailWebView:(YSWebView *)wView stringByEvaluatingJavaScriptFromString:(NSString *)jsStr
{
    if (isEmptyString(jsStr)) {
        return nil;
    }
    return [wView stringByEvaluatingJavaScriptFromString:jsStr completionHandler:nil];
}

//调fe方法，下发的字段作为参数
- (void)p_insertJSContext:(NSString *)contextStr
{
    if (isEmptyString(contextStr) || _webViewHasInsertedContextJS) {
        return;
    }
    
    NSString * insertStr = [NSString stringWithFormat:@"insertDiv(%@)", contextStr];
    [_detailWebView.webView stringByEvaluatingJavaScriptFromString:insertStr completionHandler:nil];
    _webViewHasInsertedContextJS = YES;
}

- (void)p_addNotiCenterObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_fontChanged)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
}

- (void)p_updateTitleViewAnimationTriggerPos
{
    __weak typeof(self) weakSelf = self;
    NSString *objectYOffset = @";window.getElementPosition && getElementPosition(\"#profile\");";
    [self.detailWebView.webView stringByEvaluatingJavaScriptFromString:objectYOffset completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (!isEmptyString(result)) {
            CGRect frame = CGRectFromString(result);
            if (!CGRectIsEmpty(frame)) {
                weakSelf.titleViewAnimationTriggerPosY = frame.origin.y + frame.size.height;
            } else {
                weakSelf.titleViewAnimationTriggerPosY = 100; // 默认
            }
        } else {
            weakSelf.titleViewAnimationTriggerPosY = 100;
        }
    }];
}

- (void)p_sendDetailTimeIntervalMonitorForService:(NSString *)serviceName
{
    NSString *intervalString = [_monitor intervalFromWebRequestStartTime];
    if (!isEmptyString(intervalString)) {
        [[TTMonitor shareManager] trackService:serviceName value:intervalString extra:[WDMonitorManager extraDicWithAnswerId:self.detailModel.answerEntity.ansid error:nil]];
    }
}

- (void)p_skipReadPartIfNeed
{
    if (![WDCommonLogic answerReadPositionEnable]) {
        return;
    }
    
    if (self.detailWebView.webView.isWKWebView) {
        return;
    }
    
    //用户滚动了就不再跳转
    if (!CGPointEqualToPoint(self.detailWebView.webView.scrollView.contentOffset, CGPointZero)) {
        return;
    }
    
    [self.detailWebView setWebContentOffset:CGPointMake(0, [self.detailViewModel tt_getLastContentOffsetY])];
    //原地滚动一下, 猜测是前端监听了scroll时间来懒加载图片
    [self.detailWebView.webView evaluateJavaScriptFromString:@"window.scrollBy(0, 0)" completionBlock:nil];
}

- (void)p_uploadArticlePositionIfNeed {
    CGFloat offset = self.detailWebView.webView.scrollView.contentOffset.y;
    SSJSBridgeWebView *webView = self.detailWebView.webView;
    CGFloat contentHeight = [self.detailWebView webViewContentHeight];
    if (webView.scrollView.contentOffset.y + webView.height > contentHeight) {
        offset = contentHeight - webView.height;
    }
    offset = offset > 0? offset: 0;
    [self.detailViewModel tt_setContentOffsetY:offset];
}

#pragma mark - Notifications

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self p_refreshDetailTheme];
    if (_isNewVersion) {
        _detailWebView.containerScrollView.backgroundColor = [UIColor clearColor];
    }
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

- (void)followNotification:(NSNotification *)notify
{
    NSString *userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    NSString *userIDOfSelf = self.detailModel.answerEntity.user.userID;
    if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        BOOL isFollowedState = self.detailModel.answerEntity.user.isFollowing;
        if (actionType == FriendActionTypeFollow) {
            isFollowedState = YES;
        }else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        
        if (isFollowedState) {
            self.detailModel.redPack = nil;
        }
        if (self.detailModel.answerEntity.user.isFollowing == isFollowedState) {
            return;
        }
        
        self.detailModel.answerEntity.user.isFollowing = isFollowedState;
      
        [self.detailModel.answerEntity save];
    }
}

- (void)pn_fontChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewWillChangeFontSize)]) {
        [_delegate tt_articleDetailViewWillChangeFontSize];
    }
    
    [self p_webViewUpdateFontSize];
    
    [self p_updateTitleViewAnimationTriggerPos];
    
    if (_delegate && [_delegate respondsToSelector:@selector(tt_articleDetailViewDidChangeFontSize)]) {
        [_delegate tt_articleDetailViewDidChangeFontSize];
    }
    TTUserSettingsFontSize selectedFontType = [TTUserSettingsManager settingFontSize];
    NSString *setFontEvent;
    switch (selectedFontType) {
        case TTFontSizeSettingTypeMin:
            setFontEvent = @"set_font_small";
            break;
        case TTFontSizeSettingTypeNormal:
            setFontEvent = @"set_font_middle";
            break;
        case TTFontSizeSettingTypeBig:
            setFontEvent = @"set_font_big";
            break;
        case TTFontSizeSettingTypeLarge:
            setFontEvent = @"set_font_ultra_big";
            break;
        default:
            setFontEvent = @"set_font_middle";
            break;
    }
}

- (void)pn_didEnterBackground {
    // 如果加载期间切换到后台，则放弃这一次统计
    [_tracker tt_resetStartLoadDate];
    
    //added 5.7.*:退到后台也发送read_pct事件
    if (self.detailWebView && !_didDisAppear) {
        [self.tracker tt_sendReadTrackWithPCT:[self.detailWebView readPCTValue] pageCount:[self.detailWebView pageCount]];
        [self.tracker tt_sendStayTimeImpresssion];
    }
}


#pragma mark - FollowManagerBlock
- (void)finishActionType:(FriendActionType)type error:(nullable NSError*)error result:(nullable NSDictionary*)result
{
    NSDictionary *resultDic = result[@"result"];
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *userDic = resultDic[@"data"][@"user"];
    NSNumber *status = userDic[@"is_following"];
    if (error && ![resultDic[@"message"] isEqualToString:@"success"]) {
        params[@"code"] = @(0);
    } else {
        params[@"code"] = @(1);
        params[@"status"] = status;
    }
    if (self.callback) {
        self.callback(TTRJSBMsgSuccess, params);
        self.callback = nil;
    }
    
    if (error) {
        NSString *tips = error.userInfo[@"description"];
        if (!TTNetworkConnected()) {
            tips = @"网络不给力，请稍后重试";
        }
        if (isEmptyString(tips)) {
            tips = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    else {
        if (type == FriendActionTypeFollow) {
            self.detailModel.answerEntity.isFollowed = YES;
            self.detailModel.answerEntity.user.isFollowing = YES;
            self.detailModel.answerEntity.userLike = [status boolValue];
            [self.detailModel.answerEntity save];
        } else if (type == FriendActionTypeUnfollow) {
            self.detailModel.answerEntity.user.isFollowing = NO;
            [self.detailModel.answerEntity save];
        }
    }
    
}

#pragma mark - TTDetailWebViewDelegate

- (BOOL)webViewContentIsNativeType
{
    return YES;
}

- (void)webViewDidChangeContentSize
{
}


- (void)webViewContainerWillShowFirstCommentCellByScrolling
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_WDDetailViewWillShowFirstCommentCell)]) {
        [_delegate tt_WDDetailViewWillShowFirstCommentCell];
    }
}

- (void)webViewContainerInFooterHalfShowStatusWithScrollOffset:(CGFloat)rOffset
{
    if (_delegate && [_delegate respondsToSelector:@selector(tt_WDDetailViewFooterHalfStatusOffset:)]) {
        [_delegate tt_WDDetailViewFooterHalfStatusOffset:rOffset];
    }
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.tracker.userHasClickLink = YES;
    }
    
    //统计跳转到某个URL
    if (!isEmptyString(request.URL.absoluteString)) {
        [self.tracker.jumpLinks addObject:request.URL.absoluteString];
    }
    
    return YES;
}

- (void)webView:(nullable YSWebView *)webView scrollViewDidScroll:(nullable UIScrollView *)scrollView{
    //1.do something in this class if needed
    //2. call to upper
    if (_delegate && [_delegate respondsToSelector:@selector(webView:scrollViewDidScroll:)]) {
        [_delegate webView:self.detailWebView scrollViewDidScroll:scrollView];
    }
}

- (void)webViewDidStartLoad:(YSWebView *)webView
{
    if (!isEmptyString(_latestWebViewRequestURLString)) {
        BOOL isHTTP = [webView.request.URL.scheme isEqualToString:@"http"] || [webView.request.URL.scheme isEqualToString:@"https"];
        if (![webView.request.URL.absoluteString isEqualToString:_latestWebViewRequestURLString] && isHTTP) {
            // 页面发生跳转，发送取消事件(里面会判断是否已经发送过其他事件，如果发送过，则不会重复发送)
            [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatCancel error:nil];
        }
    }
    _isWebViewLoading = YES;
    _latestWebViewRequestURLString = webView.request.URL.absoluteString;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFinish error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_webViewUpdateFontSize];
        if (!webView.opaque) {
            webView.opaque = YES;
        }
        _webViewHasError = NO;
    });
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.domReady = YES;
    
    __weak typeof(self) wself = self;
    [webView evaluateJavaScriptFromString:@"document.body.childElementCount;" completionBlock:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(wself) sself = wself;
        if ([result isEqualToString:@"0"]) {
            if (sself) {
                sself->_webViewHasError = YES;
            }
        }
    }];
    
    [self.tracker tt_sendStatStayEventTrack:SSWebViewStayStatLoadFail error:nil];
}

#pragma mark - TTDetailWebViewRequestProcessorDelegate

- (void)processRequestReceiveDomReady
{
    self.domReady = YES;
    
    //转码页的context在此注入
    if (self.detailModel.insertedContextJS) {
        [self p_insertJSContext:self.detailModel.insertedContextJS];
    }
    
    // titleView 位置
    [self p_updateTitleViewAnimationTriggerPos];
    [self p_skipReadPartIfNeed];

    //做统计
    [self.tracker tt_sendStartLoadDateTrackIfNeeded];
    
    //监控DomReady时间
    [self p_sendDetailTimeIntervalMonitorForService:WDDetailDomReadyTimeService];
}

- (void)processRequestUpdateArticleImageMode:(NSNumber *)mode
{
    @try {
        self.detailModel.answerEntity.imageMode = mode;
        [self.detailModel.answerEntity save];
    }
    @catch (NSException *exception) {
    }
}

- (void)processRequestOpenWebViewUseURL:(NSURL *)url supportRotate:(BOOL)support
{
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:url.absoluteString forKey:@"url"];
        url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    }
    if ([url.scheme isEqualToString:@"sslocal"]) {
        NSMutableDictionary *conditions = [[NSMutableDictionary alloc] init];
        [conditions setValue:@(support) forKey:@"supportRotate"];
        [conditions setValue:@"网页浏览" forKey:@"title"];
        [conditions setValue:@(YES) forKey:@"nightbackground_disable"];

        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:conditions];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:info];
    } 
}

- (void)processRequestShowImgInPhotoScrollViewAtIndex:(NSUInteger)index withFrameValue:(NSValue *)frameValue
{
    // show photo scroll view
    ttTrackEvent(@"image", @"enter_detail");
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
    self.photoScrollViewController = showImageViewController;
    showImageViewController.targetView = self.detailWebView.webView.scrollView;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    WeakSelf;
    showImageViewController.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
        StrongSelf;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:self.detailModel.answerEntity.ansid forKey:@"id"];
        [param setValue:@(currentIndex) forKey:@"status"];
        [param setValue:@"carousel_image_switch" forKey:@"type"];
        [self.detailWebView.webView ttr_fireEvent:@"page_state_change" data:param];

        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
        [params setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
        [params setValue:@"detail" forKey:@"position"];
        [TTTrackerWrapper eventV3:@"slide_pic" params:params];
    };
    NSArray *infoModels = [self.detailModel.answerEntity detailLargeImageModels];
    showImageViewController.imageInfosModels = infoModels;
    [showImageViewController setStartWithIndex:index];
    if (frameValue) {
        CGRect frame;
        frame = [self.detailWebView.webView.scrollView convertRect:[frameValue CGRectValue] toView:nil];
        NSMutableArray * frames = [NSMutableArray arrayWithCapacity:index + 1];
        NSMutableArray * animateFrames = [NSMutableArray arrayWithCapacity:index + 1];
        for (NSUInteger i = 0; i < index; ++i) {
            [frames addObject:[NSNull null]];
            [animateFrames addObject:[NSNull null]];
        }
        [frames addObject:[NSValue valueWithCGRect:frame]];
        [animateFrames addObject:frameValue];
        showImageViewController.placeholderSourceViewFrames = frames;
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
        CGFloat topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + nav.navigationBar.height;
        CGFloat bottomBarHeight = [self detailGetToolbarHeight];
        showImageViewController.dismissMaskInsets = UIEdgeInsetsMake(topBarHeight, 0, bottomBarHeight, 0);
    }
    [showImageViewController presentPhotoScrollView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_WDDetailViewWillShowLargeImage)]) {
        [self.delegate tt_WDDetailViewWillShowLargeImage];
    }
}

- (CGFloat)detailGetToolbarHeight{
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

- (void)processRequestShowTipMsg:(NSString *)tipMsg icon:(UIImage *)image
{
    if (!isEmptyString(tipMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
    }
}

- (void)processRequestShowUserProfileForUserID:(NSString *)userID
{
    
    // add by zjing 去掉个人主页跳转
    return;
    
    NSString *schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@&enter_from=com",userID];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schema]];
}

- (void)processRequestShowPGCProfileWithParams:(NSDictionary *)paramsDict
{
    NSString *itemID = self.detailModel.answerEntity.ansid;
    NSString *mediaID = [NSString stringWithFormat:@"%@", paramsDict[@"media_id"]];
    NSString *source = [paramsDict[@"loc"] boolValue] ? @"article_bottom_author" : @"article_top_author";
    
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?media_id=%@", mediaID];
    if (!isEmptyString(source)) {
        [linkURLString appendFormat:@"&source=%@", source];
    }
    if (!isEmptyString(itemID)) {
        [linkURLString appendFormat:@"&item_id=%@", itemID];
    }
    NSURL *url = [TTStringHelper URLWithURLString:linkURLString];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (void)processRequestOpenAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID
{
    [[SSAppStore shareInstance] openAppStoreByActionURL:actionURL itunesID:appleID presentController:[TTUIResponderHelper topViewControllerFor: self]];
}

- (void)processRequestShowSearchViewWithQuery:(NSString *)query fromType:(NSInteger)type index:(NSUInteger)index
{
    if (isEmptyString(query)) {
        return;
    }
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:query forKey:@"keyword"];
    [extra setValue:@(1) forKey:@"nav"];
    [extra setValue:@(1) forKey:@"backBtn"];
    [extra setValue:@(index) forKey:@"tabType"];
    [extra setValue:@(self.detailModel.answerEntity.ansid.longLongValue) forKey:@"groupID"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:extra];
    NSString *schema = [NSString stringWithFormat:@"sslocal://search"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schema] userInfo:userInfo];
    
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
    
    //ListDataSearchFromTypeContent:3
    if (type == 3) {
        [self trackEventCategory:@"umeng" tag:kWDDetailViewControllerUMEventName label:[NSString stringWithFormat:@"click_tag_%lu", (unsigned long)index] value:self.detailModel.answerEntity.ansid extValue:nil fromGID:nil adID:nil params:nil groupModel:groupModel];
    }
    //ListDataSearchFromTypeContent:4
    else if (type == 4) {
        [self trackEventCategory:@"umeng" tag:kWDDetailViewControllerUMEventName label:[NSString stringWithFormat:@"click_keyword_%lu", (unsigned long)index] value:self.detailModel.answerEntity.ansid extValue:nil fromGID:nil adID:nil params:nil groupModel:groupModel];
    }
}

- (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue fromGID:(NSNumber *)fromGID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel {
    NSMutableDictionary * dict;
    if ([params isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    [dict setValue:c forKey:@"category"];
    [dict setValue:t forKey:@"tag"];
    [dict setValue:l forKey:@"label"];
    if (!isEmptyString(groupModel.itemID)) {
        [dict setValue:groupModel.itemID forKey:@"item_id"];
        [dict setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    }
    [dict setValue:v forKey:@"value"];
    [dict setValue:eValue forKey:@"ext_value"];
    [dict setValue:fromGID forKey:@"from_gid"];
    if (adID.longLongValue > 0) {
        [dict setValue:adID forKey:@"ad_id"];
    }
    [TTTracker eventData:dict];
}
@end
