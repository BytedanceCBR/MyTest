//
//  TTAdCanvasManager.m
//  Article
//
//  Created by yin on 2016/12/13.
//
//

#import "TTAdCanvasManager.h"

#import "NSStringAdditions.h"
#import "SSWebViewController.h"
#import "TTAdAnimationCell.h"
#import "TTAdCanvasDefine.h"
#import "TTAdCanvasDownloadManager.h"
#import "TTAdCanvasProjectModel+Resource.h"
#import "TTAdCanvasTracker.h"
#import "TTAdCanvasUtils.h"
#import "TTAdCanvasVC.h"
#import "TTAdCanvasViewController.h"
#import "TTAdConstant.h"
#import "TTAdFeedModel.h"
#import "TTAdLog.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"
#import "TTAdTrackManager.h"
#import "TTCanvasBundleManager.h"
#import "TTImageInfosModel.h"
#import "TTMonitor.h"
#import "TTNetworkManager.h"
#import "TTTrackerWrapper.h"
#import "TTUIResponderHelper.h"
#import "UIView+CustomTimingFunction.h"
#import <TTServiceKit/TTServiceCenter.h>
#import <TTTracker/TTTrackerProxy.h>
#import "ExploreOrderedData+TTAd.h"

#define kTTAdCanvasCacheDictPath @"canvasAdDict.plist"
static NSString * const kTTAdCanvasModel = @"kTTAdCanvasModel";


@interface TTAdCanvasManager ()<TTRNViewDelegate, SSActivityViewDelegate, TTAdCanvasVCDelegate>
@property (nonatomic, strong) TTActivityShareManager* activityActionManager;
@property (nonatomic, strong) SSActivityView* shareView;
@property (nonatomic, strong) TTActionSheetController* actionSheetController;
@property (nonatomic, assign) BOOL isRnFatal;
@property (nonatomic, assign) BOOL hasPreCreate; //在feed可视区域预加载过
@property (nonatomic, weak)   UITableViewCell<TTAdAnimationCell> *cell;
@property (nonatomic, strong) ExploreOrderedData *orderData;
@end

@implementation TTAdCanvasManager

Singleton_Implementation(TTAdCanvasManager)

+ (void)load
{
    [[TTAdSingletonManager sharedManager] registerSingleton:[TTAdCanvasManager sharedManager] forKey:NSStringFromClass([self class])];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isRnFatal = NO;
        _hasPreCreate = NO;
    }
    return self;
}

#pragma mark --Notification

- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestCanvasData];
    });
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestCanvasData];
    });
}

/**
 CPT  格式请求 Canvas预加载数据  下发多个广告【创意计划】数据  [ad_id[creative_id]]
 */
- (void)requestCanvasData {
    //ipad、iOS7不请求preload接口
    if (![TTAdCanvasUtils canvasEnable]) {
        return;
    }
    
    TTAdCanvasModel* canvasModel = [TTAdCanvasManager getCanvasModel];
    //当前date早于reuqstTime
    if ([[NSDate date] compare:canvasModel.data.requestTime] == NSOrderedAscending) {
        return;
    }
    
    NSString* url = [CommonURLSetting canvasAdURLString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj) {
        NSError * jsonerror = nil;
        TTAdCanvasModel* model = [[TTAdCanvasModel alloc] initWithDictionary:jsonObj error:&jsonerror];
        if (model && [model isKindOfClass:[TTAdCanvasModel class]]) {
            [TTAdCanvasManager saveCanvasModel:model];              //上一次有效的 请求,更新请求上下文，请求频次控制
            [TTAdCanvasManager mergeProjects:model.data.ad_projects];          // 增量 存储所有的 广告创意数据
            [TTAdCanvasDownloadManager downloadResource:model];
        }
    }];
}


#pragma mark -- show canvasView

- (BOOL)canOpenCanvasOrderData:(ExploreOrderedData*)orderData model:(TTAdCanvasProjectModel *)projectModel error:(NSError **)error {
    if (![TTAdCanvasUtils canvasEnable]) {
        if (error) {
            *error = [NSError errorWithDomain:kTTAdCanvasErrorDomain code:TTAdCnavasOpenErrorCodeNotSupport userInfo:nil];
        }
        return NO;
    }
    
    if (!projectModel) {
        if (error) {
            *error = [NSError errorWithDomain:kTTAdCanvasErrorDomain code:TTAdCnavasOpenErrorCodeNotfound userInfo:nil];
        }
        return NO;
    }
    
    if (![TTAdCanvasUtils nativeEnable]) {
        if (self.isRnFatal == YES) {
            if (error) {
                *error = [NSError errorWithDomain:kTTAdCanvasErrorDomain code:TTAdCnavasOpenErrorCodeFatal userInfo:nil];
            }
            return NO;
        }
    }
    
    if (![projectModel checkResource]) {
        if (error) {
            *error = [NSError errorWithDomain:kTTAdCanvasErrorDomain code:TTAdCnavasOpenErrorCodeImage userInfo:nil];
        }
        return NO;
    }

    NSDictionary* jsonDict = [[self class] parseJsonDict:projectModel];
    if (SSIsEmptyDictionary(jsonDict)) {
        if (*error) {
            *error = [NSError errorWithDomain:kTTAdCanvasErrorDomain code:TTAdCnavasOpenErrorCodeLayout userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)filterCanvas:(ExploreOrderedData *)orderData {
    if (orderData && orderData.raw_ad) {
        if ([orderData.raw_ad.style isEqualToString:kTTAdCanvasStyle]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)showCanvasView:(ExploreOrderedData*)orderData cell:(UITableViewCell<TTAdAnimationCell>*)cell {
    if (![TTAdCanvasManager filterCanvas:orderData]) {
        return NO;
    }
    TTAdFeedModel *rawAd = orderData.raw_ad;
    self.orderData = orderData;
    self.cell = cell;
    
    TTAdCanvasProjectModel *projectModel = [TTAdCanvasManager getMatchProjctModel:rawAd.ad_id];
    UINavigationController *navi = [TTUIResponderHelper topNavigationControllerFor:cell];
    BOOL canOpenCanvas = NO;
    
    NSMutableDictionary *openInfo = [NSMutableDictionary dictionary];
    NSError *error;
    if ([self canOpenCanvasOrderData:orderData model:projectModel error:&error]) {
        NSMutableDictionary *baseCondition = [NSMutableDictionary dictionary];
        TTAdCanvasViewModel *viewModel = [[TTAdCanvasViewModel alloc] initWithModel:projectModel];
        viewModel.ad_id = rawAd.ad_id;
        viewModel.log_extra = rawAd.log_extra;
        if ([cell conformsToProtocol:@protocol(TTAdAnimationCell)]) {
            NSDictionary *animationCondition = [cell animationContextInfo:orderData];
            if (animationCondition) {
                viewModel.sourceImageModel = animationCondition[kTTCanvasSourceImageModel];
                viewModel.soureImageFrame = CGRectFromString(animationCondition[kTTCanvasSourceImageFrame]);
                if (viewModel.hasCreateFeedData) {
                    if (animationCondition[kTTCanvasFeedData]) {
                        viewModel.canvasImageModel = viewModel.sourceImageModel;
                        viewModel.createFeedData = animationCondition[kTTCanvasFeedData];
                    }
                }
            }
        }
        if (viewModel.canvasImageModel == nil || viewModel.sourceImageModel == nil) {
            viewModel.animationStyle = TTAdCanvasOpenAnimationPush;
        }
       
        UIViewController<TTAdCanvasViewController> *canvasVC = nil;
        if ([TTAdCanvasUtils nativeEnable]) {
            canvasVC = [[TTAdCanvasVC alloc] initWithRouteParamObj:TTRouteParamObjWithDict(baseCondition)];
            [openInfo  setValue:@"2" forKey:@"style"];
        } else {
            canvasVC = [[TTAdCanvasViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(baseCondition)];
            self.rnView = nil;
            WeakSelf;
            [self setRNFatalHandler:^{
                StrongSelf;
                self.isRnFatal = YES;
                [navi popViewControllerAnimated:NO];
                [self pushWithNavi:navi orderData:orderData];
                
                TTAdRNBundleInfo *bundleInfo = [TTCanvasBundleManager currentCanvasBundleInfo];
                NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:4];
                [extra setValue:[bundleInfo toJSONString] forKey:@"bundle"];
                [extra setValue:rawAd.ad_id forKey:@"ad_id"];
                [extra setValue:rawAd.log_extra forKey:@"log_extra"];
                [TTAdMonitorManager trackService:@"ad_canvas_fatalerror" status:0 extra:extra];
            }];
            [openInfo setValue:@"1" forKey:@"style"];
        }
        canvasVC.viewModel = viewModel;
        canvasVC.tracker = [TTAdCanvasTracker tracker:rawAd];
        canvasVC.delegate = self;
        BOOL animation = (viewModel.animationStyle == TTAdCanvasOpenAnimationPush);
        [navi pushViewController:canvasVC animated:animation];
        
        canOpenCanvas = YES;
    } else {
        canOpenCanvas = NO;
        [self trackCanvasTag:@"detail_immersion_ad" label:@"web_page" dict:nil];
        [openInfo setValue:@"3" forKey:@"style"];
        [openInfo setValue:rawAd.ad_id forKey:@"ad_id"];
        if (error && error.domain) {
            [openInfo setValue:@(error.code) forKey:error.domain];
        }
    }
    
    [[TTMonitor shareManager] trackService:@"ad_canvas_openstyle" attributes:openInfo];
    
    DLog(@"CANVAS %s can open Canvas %d reson %@ ", __PRETTY_FUNCTION__,  canOpenCanvas, openInfo);
    return canOpenCanvas;
}

- (void)pushWithNavi:(UINavigationController*)navi orderData:(ExploreOrderedData*)orderData
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *ad_id = orderData.raw_ad.ad_id;
    [parameters setValue:ad_id forKey:SSViewControllerBaseConditionADIDKey];
    [parameters setValue:@(YES) forKey:@"supportRotate"];
    SSWebViewController *controller = [[SSWebViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(parameters)];
    
    Article* article = (Article*)orderData.article;
    [controller requestWithURL:[TTStringHelper URLWithURLString:article.articleURLString]];
    [navi pushViewController:controller animated:YES];
}

#pragma mark -- 检查ad计划资源是否ready

+ (TTAdCanvasProjectModel *)getMatchProjctModel:(NSString *)ad_id
{
    NSDictionary* canvasDict = [TTAdCanvasManager getCacheCanvasDict];
    if (!canvasDict || canvasDict.count == 0) {
        return nil;
    }
    TTAdCanvasProjectModel* matchModel = canvasDict[ad_id];
    if (matchModel && [matchModel isKindOfClass:[TTAdCanvasProjectModel class]]) {
        return matchModel;
    }
    return nil;
}

#pragma mark -- Save Cache

//将所有ad_project存储在dict里并缓存
+ (void)mergeProjects:(NSArray<TTAdCanvasProjectModel *> *)projectModels {
    //将projectModel加入到 projectDict中
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionary];
    [projectDict addEntriesFromDictionary:[TTAdCanvasManager getCacheCanvasDict]];
    
    [projectModels enumerateObjectsUsingBlock:^(TTAdCanvasProjectModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasProjectModel* projectModel = (TTAdCanvasProjectModel*)obj;
        if (projectModel && [projectModel isKindOfClass:[TTAdCanvasProjectModel class]]) {
            //记录后期清空的时间
            [projectModel updateClearTime];
            [projectModel.ad_ids enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [projectDict setValue:projectModel forKey:[NSString stringWithFormat:@"%@", obj]];
            }];
        }
    }];
    
    [self saveProjects:projectDict];
}

//将所有ad_project存储在dict里并缓存
+ (void)mergeProject:(TTAdCanvasProjectModel*)projectModel {
    //将projectModel加入到 projectDict中
    NSMutableDictionary* projectDict = [NSMutableDictionary dictionary];
    [projectDict addEntriesFromDictionary:[TTAdCanvasManager getCacheCanvasDict]];
    if (projectModel && [projectModel isKindOfClass:[TTAdCanvasProjectModel class]]) {
        //记录后期清空的时间
        [projectModel updateClearTime];
        [projectModel.ad_ids enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [projectDict setValue:projectModel forKey:[NSString stringWithFormat:@"%@", obj]];
        }];
    }
    [self saveProjects:projectDict];
}

+ (void)saveProjects:(NSDictionary *)projectDict {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary addEntriesFromDictionary:projectDict];
    
     //projectDict中清除过期的projectModel
    [projectDict.allKeys enumerateObjectsUsingBlock:^(NSString  *_Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasProjectModel* projectModel = projectDict[key]; //??
        if (projectModel && [projectModel isKindOfClass:[TTAdCanvasProjectModel class]]) {
            if ([projectModel.clearTime compare:[NSDate date]] == NSOrderedAscending) {
                [dictionary removeObjectForKey:key];
            }
        }
    }];
    
    @try {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        NSString * filePath = [kTTAdCanvasCacheDictPath stringCachePath];
        if (data) {
            [data writeToFile:filePath atomically:YES];
        } 
    } @catch (NSException *exception) {
        LOGD(@"%@", exception);
    } @finally {
    }
}

+ (nonnull NSDictionary*)getCacheCanvasDict
{
    NSString *filePath = [kTTAdCanvasCacheDictPath stringCachePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data == nil) {
        return @{};
    }
    NSDictionary* dict = nil;
    @try {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        LOGE(@"%@", exception);
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    } @finally {
    }
    
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    return [dict copy];
}

//存储每次请求的model,为requst_after限制请求频率
+ (void)saveCanvasModel:(TTAdCanvasModel*)canvasModel
{
    //记录下次请求的时间
    [canvasModel.data updateReqeustDate];
    @try {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:canvasModel];
        if (data) {
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTAdCanvasModel];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } @catch (NSException *exception) {
        LOGE(@"%@", exception);
    }
}

//获取存储的model,为requst_after限制请求频率
+ (TTAdCanvasModel*)getCanvasModel
{
    NSData* data = [[NSUserDefaults standardUserDefaults] valueForKey:kTTAdCanvasModel];
    TTAdCanvasModel* projectModel = nil;
    @try {
        projectModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        LOGE(@"%@", exception);
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTAdCanvasModel];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } @finally {
    }
    if (projectModel && [projectModel isKindOfClass:[TTAdCanvasModel class]]) {
        return projectModel;
    }
    return nil;
}

- (void)clearModelCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTAdCanvasModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- Create Canvas

- (void)preCreateCanvasView:(ExploreOrderedData *)orderData {
    if (self.hasPreCreate) {
        return;
    }
    if (![TTAdCanvasManager filterCanvas:orderData]) {
        return;
    }
    if ([NSThread isMainThread]) {
        [self preCreateCanvasView];
        self.hasPreCreate = YES;
    }
}

- (void)preCreateCanvasView
{
    if (![TTAdCanvasUtils canvasEnable]) {
        return ;
    }
    
    if (TTAdCanvasUtils.nativeEnable) {
        return;
    }
    TTRNView* rnView = [self createRNView];
    [rnView loadModule:kTTAdCanvasReatModule initialProperties:@{}];
    WeakSelf;
    [self setRNFatalHandler:^{
        StrongSelf;
        self.isRnFatal = YES;
    }];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [TTTrackerWrapper eventV3:@"precreate_canvas_rn" params:params];
}

- (TTRNView *)createRNView {
    self.rnView = [[TTRNView alloc] init];
    self.rnView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.rnView.delegate = self;
    return self.rnView;
}

- (void)destroyRNView
{
    self.rnView.delegate = nil;
    self.rnView = nil;
}

#pragma mark TTRNViewDelegate

- (NSURL *)RNBundleUrl
{
    return [TTCanvasBundleManager bundleURL];
}

- (NSURL *)fallbackSourceURL
{
    return [TTCanvasBundleManager fallbackSourceURL];
}

- (void)setRNFatalHandler:(TTRNFatalHandler)handler
{
    if (self.rnView) {
        [self.rnView setFatalHandler:handler];
    }
}

#pragma mark --TTAdCanvasVCDelegate

- (void)canvasVCShowEndAnimation:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel *)souceImageModel toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel *)toImageInfoModel complete:(void (^)(BOOL))completion {
    UINavigationController *navi = [TTUIResponderHelper topNavigationControllerFor:self.cell];
    UIViewController *containerVC = [TTUIResponderHelper topViewControllerFor:self.cell];
    UIViewController *canvasVC = navi.topViewController;
    UIView *containerView = containerVC.view;
    
    CGSize size = canvasVC.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [canvasVC.view drawViewHierarchyInRect:canvasVC.view.bounds afterScreenUpdates:NO];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:sourceImage];
    sourceImageView.clipsToBounds = YES;
    sourceImageView.contentMode = UIViewContentModeScaleAspectFill;
    sourceImageView.frame = canvasVC.view.frame;
    
    [navi popViewControllerAnimated:NO];
    
    NSDictionary *dict = [self.cell animationContextInfo:self.orderData];
    if (!SSIsEmptyDictionary(dict) && dict[kTTCanvasSourceImageFrame]) {
        toFrame = CGRectFromString(dict[kTTCanvasSourceImageFrame]);
    }
    
    if (toFrame.size.width > FLT_EPSILON) {
        CGFloat sourceWidth = CGRectGetWidth(sourceImageView.bounds);
        CGFloat sourceHeight = ceilf(sourceWidth * toFrame.size.height / toFrame.size.width);
        sourceFrame = CGRectMake(0, 0, sourceWidth, sourceHeight);
    }
    
    TTImageView *toImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    toImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
    toImageView.clipsToBounds = YES;
    [toImageView setImageWithModel:toImageInfoModel];
    
    [containerView addSubview:toImageView];
    [containerView insertSubview:sourceImageView belowSubview:toImageView];
    
    toImageView.alpha = 0;
    [UIView animateWithDuration:0.28 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        sourceImageView.frame = toFrame;
        toImageView.frame = toFrame;
        toImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [sourceImageView removeFromSuperview];
        [toImageView removeFromSuperview];
    }];
}

#pragma mark -- track

- (void)trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict {
    [TTAdCanvasTracker trackerWithModel:self.orderData.raw_ad tag:tag label:label extra:dict];
}

- (void)trackCanvasRN:(NSDictionary *)dict
{
    NSMutableDictionary* dataDict = [NSMutableDictionary dictionary];
    __block NSString* tag = nil;
    __block NSString* label = nil;
    [dict.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([key isEqualToString:@"tag"]) {
            tag = key;
        } else if ([key isEqualToString:@"label"]) {
            label = key;
        } else {
            [dataDict setValue:[dict valueForKey:key] forKey:key];
        }
    }];
    if (!isEmptyString(tag)&&!isEmptyString(label)) {
        [self trackCanvasTag:[dict valueForKey:tag] label:[dict valueForKey:label] dict:dataDict];
    }
}

- (void)canvasCall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasVideoNotificationPause object:nil];
    [self listenCall:self.orderData];
}

//监听电话状态
- (void)listenCall:(ExploreOrderedData*)orderData
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = orderData.raw_ad.ad_id;
    callModel.log_extra = orderData.raw_ad.log_extra;
    callModel.position = @"detail_immersion_ad";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = @(1);
    [TTAdManageInstance call_callAdModel:callModel];
}

#pragma mark --share
- (void)canvasShare
{
    Article *article = self.orderData.article;
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSString *ad_id = self.orderData.raw_ad.ad_id;
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:article adID:@(ad_id.integerValue) showReport:YES];
    
    _shareView = [[SSActivityView alloc] init];
    _shareView.delegate = self;
    _shareView.activityItems = activityItems;
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:ad_id groupId:self.orderData.article.groupModel.groupID];
    [_shareView showOnViewController:[TTUIResponderHelper correctTopViewControllerFor:nil] useShareGroupOnly:NO];
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (itemType == TTActivityTypeReport) {
        self.actionSheetController = [[TTActionSheetController alloc] init];
        
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.orderData.article.groupModel.groupID;
                model.videoID = self.orderData.article.videoID;
                
                [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeAD reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderData.categoryID) contentModel:model extraDic:nil animated:YES];
            }
        }];
        
    } else {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderData.article.uniqueID];
        [self.activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper correctTopViewControllerFor:nil] sourceObjectType:TTShareSourceObjectTypeArticle uniqueId:uniqueID adID:self.orderData.raw_ad.ad_id platform:TTSharePlatformTypeOfMain groupFlags:self.orderData.article.groupFlags];
    }
    self.shareView = nil;
}


- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    //do nothing
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc {
    //do nothing
}


#pragma mark -- handleJsonLayout

- (TTAdCanvasJsonLayoutModel* )parseJsonLayout:(NSDictionary *)layoutInfo {
    NSError *jsonError;
    TTAdCanvasJsonLayoutModel* jsonModel = [[TTAdCanvasJsonLayoutModel alloc] initWithDictionary:layoutInfo error:&jsonError];
    if (!jsonModel) {
        LOGE(@"%@", jsonError.localizedDescription);
        return nil;
    }
    
    NSMutableArray* components = [NSMutableArray arrayWithCapacity:jsonModel.components.count];
    [jsonModel.components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasLayoutModel* layoutModel = (TTAdCanvasLayoutModel*)obj;
        if (layoutModel) {
            if ([layoutModel isInValidComponent]) {
                [components addObject:layoutModel];
            }
        }
    }];
    
    jsonModel.components = (NSArray<TTAdCanvasLayoutModel>*)components;
    
    [jsonModel.components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasLayoutModel* layoutModel = (TTAdCanvasLayoutModel*)obj;
        layoutModel.indexPath = idx + 1;
    }];
    return jsonModel;
}

+ (NSDictionary *)parseJsonDict:(TTAdCanvasProjectModel*)projectModel {
    NSData *jsonData = [[SSSimpleCache sharedCache] dataForUrl:projectModel.resource.jsonString];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (isEmptyString(jsonStr)) {
        return nil;
    }
    NSString *canvasStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *data = [canvasStr dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        NSError *jsonError = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        return dict;
    }
    return nil;
}

@end
