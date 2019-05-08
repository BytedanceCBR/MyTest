//
//  TTMessageNotificationViewController.m
//  Article
//
//  Created by lizhuoli on 17/3/27.
//
//

#import "TTMessageNotificationViewController.h"
#import "TTMessageNotificationBaseCell.h"
#import "TTMessageNotificationReadFooterCell.h"
#import "TTMessageNotificationManager.h"

#import <TTAccountBusiness.h>
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "NetworkUtilities.h"
#import "SSNavigationBar.h"
#import "SDWebImageCompat.h"
#import "TTMessageNotificationCellHelper.h"
#import "SSImpressionManager.h"
#import "TTMessageNotificationTipsManager.h"
#import "SSWebViewController.h"
#import <TTTrackerWrapper.h>
#import "TTRoute.h"
#import <WDNetWorkPluginManager.h>
#import <WDDislikeView.h>
#import <TTBaseLib/JSONAdditions.h>
#import "TTMessageNotificationMacro.h"
#import "TTMonitor.h"
#import "TTMessageCenterRouter.h"
#import <WDApiModel.h>


#define kTTMessageNotificationCellIdentifier @"kTTMessageNotificationCellIdentifier"
#define kTTMessageNotificationReadFooterCellIdentifier @"kTTMessageNotificationReadFooterCellIdentifier"

typedef NS_ENUM(NSUInteger, TTMessageNotificationCellSectionType) {
    TTMessageNotificationCellSectionTypeMessage = 0,
    TTMessageNotificationCellSectionTypeReadFooter = 1
};

@interface TTMessageNotificationViewController ()<UITableViewDelegate, UITableViewDataSource, UIViewControllerErrorHandler, SSImpressionProtocol>

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, copy) NSArray<TTMessageNotificationModel *> *messageModels; //所有拉取到的message模型数组
@property (nonatomic, strong) NSNumber *minCursor; //当前的消息列表的minCursor，在loadMore为YES时可以继续用该cursor值拉取后续的消息
@property (nonatomic, strong) NSNumber *readCursor; //未读已读的分界线cursor
@property (nonatomic, assign) NSUInteger readSeparatorIndex; //message模型数组对应的未读已读分界线index，找不到时为NSNotFound
@property (nonatomic, assign) BOOL hasMore; //请求是否hasMore
@property (nonatomic, assign) BOOL hasLoad; //是否第一次加载成功
@property (nonatomic, assign) BOOL hasReadFooterView; //是否已经点击了查看历史消息
@property (nonatomic, assign) BOOL hasGetListResponse; //判断是否获取过list接口的response
@property (nonatomic, assign) BOOL shouldSendPushEvent; //针对的是通过push进入页面时，用户点击页面跳转时，需要发送埋点

@end

@implementation TTMessageNotificationViewController


+ (void)load
{
    //注册URL Schema
    RegisterRouteObjWithEntryName(@"message");
    RegisterRouteObjWithEntryName(@"notification");
    RegisterRouteObjWithEntryName(@"msg");
}

- (void)dealloc{
    [[SSImpressionManager shareInstance] removeRegist:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *contextInfo = paramObj.allParams;
        NSString *source = [contextInfo tt_stringValueForKey:@"source"];
        if([source isEqualToString:@"push"]){
            [TTTrackerWrapper eventV3:@"interactive_push_enter_msglist" params:nil];
            self.shouldSendPushEvent = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[TTMessageNotificationTipsManager sharedManager] clearTipsModel];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"消息", nil)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //初始化
    self.readSeparatorIndex = NSNotFound;
    self.messageModels = [NSArray array];
    self.readCursor = @(-1);
    self.hasGetListResponse = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDislikeCell:) name:kTTMessageWDInviteAnswerNotInterestNotification object:nil];
    
    [self setupSubViews];
    [self loadRequest];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheHeight) name:kClearCacheHeightNotification object:nil];
}

- (void)deleteDislikeCell:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    TTMessageNotificationModel *messageModel = [userInfo objectForKey:kTTMessageWDDislikeDataKey];
    NSArray <TTFeedDislikeWord *>*dislikeWords = [userInfo objectForKey:kTTMessageWDInviteAnswerNotInterestWordsKey];
    WDWendaPostDislikeRequestModel *requestModel = [[WDWendaPostDislikeRequestModel alloc] init];
    requestModel.msg_id = messageModel.ID;
    requestModel.cursor = messageModel.cursor.stringValue;
    if (dislikeWords && [dislikeWords count]) {
        NSMutableArray *itemList = [NSMutableArray array];
        for (TTFeedDislikeWord *dislikeWord in dislikeWords) {
            NSMutableDictionary *dislikeDict = [NSMutableDictionary dictionary];
            [dislikeDict setObject:dislikeWord.ID forKey:@"id"];
            [dislikeDict setObject:dislikeWord.name forKey:@"word_code"];
            [itemList addObject:dislikeDict];
        }
        requestModel.item_list = [itemList tt_JSONRepresentation];
    }
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
    }];
    NSMutableArray<TTMessageNotificationModel *> *messageModels = [self.messageModels mutableCopy];
    NSInteger dislikeIndex = 0;
    if ([messageModels containsObject:messageModel]) {
        dislikeIndex = [messageModels indexOfObject:messageModel];
    }
    [messageModels removeObjectAtIndex:dislikeIndex];
    self.messageModels = [messageModels copy];
    [self updateReadSeparatorIndexIfNeeded];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dislikeIndex inSection:0];
    @try {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } @catch (NSException *exception) {
    }
}

- (void)clearCacheHeight{
    [self.messageModels enumerateObjectsUsingBlock:^(TTMessageNotificationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(setCachedHeight:)]){
            [obj setCachedHeight:@(0)];
        }
    }];
    
    [self reloadTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[SSImpressionManager shareInstance] enterMessageNotificationList];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[SSImpressionManager shareInstance] leaveMessageNotificationList];
}

- (void)setupSubViews
{
    CGFloat topPadding = ([TTDeviceHelper isIPhoneXDevice] ? 44 : 20) + TTNavigationBarHeight;
    self.tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.width, self.view.height - topPadding)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColorThemeKey = kColorBackground4;
    self.tableView.enableTTStyledSeparator = NO;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    //允许上拉刷新
    WeakSelf;
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        [self triggerLoadMore];
    }];
    
    self.tableView.pullUpView.enabled = NO;
    
    /*注册相应的cell*/
    [TTMessageNotificationCellHelper registerAllCellClassWithTableView:self.tableView];
    
    //修改空页面文案
    self.customEmptyErrorMsgBlock = ^NSString *{
        return @"暂无消息";
    };
}

- (void)calloutLoginIfNeed {
    if (![TTAccountManager isLogin]) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"mine_message" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    dispatch_main_async_safe(^{
                        [self loadRequest];
                    })
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"mine_message" completion:^(TTAccountLoginState state) {
                    
                }];
            }
        }];
    }
}

- (void)loadRequest
{
    return;
//    [self tt_startUpdate];
//
//    //未联网处理
//    if (!TTNetworkConnected()) {
//        self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
//        [self tt_endUpdataData:NO error:[NSError errorWithDomain:kCommonErrorDomain code:kNoNetworkErrorCode userInfo:nil]];
//        if(self.hasLoad){
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        }
//        [self.tableView finishPullUpWithSuccess:NO];
//        return;
//    }
//
//    WeakSelf;
//    [[TTMessageNotificationManager sharedManager] fetchMessageListWithChannel:nil cursor:self.minCursor completionBlock:^(NSError *error, TTMessageNotificationResponseModel *response) {
//        StrongSelf;
//        if (!self.hasGetListResponse) {
//            [[TTMessageNotificationTipsManager sharedManager] clearTipsModel];
//            [[TTMessageNotificationManager sharedManager] fetchUnreadMessageWithChannel:nil];
//            self.hasGetListResponse = YES;
//        }
//        if (!error) {
//            self.hasLoad = YES;
//            self.tableView.pullUpView.enabled = YES;
//            self.hasMore = response.hasMore.boolValue;
//            self.tableView.hasMore = response.hasMore.boolValue;
//            self.minCursor = response.minCursor;
//
//            // 当前列表第一刷的时候 才需要更新readCursor
//            if ([self.readCursor compare:@(0)] !=  NSOrderedDescending) {
//                self.readCursor = response.readCursor;
//            }
//
//            [self addMessageModelsWithModels:response.msgList];
//
//            if (![self tt_hasValidateData]) { //显示空页面
//                self.ttViewType = TTFullScreenErrorViewTypeEmpty;
//            }
//        } else {
//            self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
//            if (self.hasLoad) {
//                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"服务器不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//            }
//        }
//        [self finishNetworkResponseWithError:error];
//        [self monitorMessageResponse:response error:error];
//    }];
}

- (void)setReadCursor:(NSNumber *)readCursor{
    _readCursor = readCursor;
    [TTMessageNotificationManager sharedManager].curListReadCursor = readCursor;
}

- (void)refreshData{
    [self loadRequest];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)finishNetworkResponseWithError:(NSError *)error {
    if (!error) {
        [self searchIndexOfUnreadSeparatorIfNeed];
    }
    [self.tableView finishPullUpWithSuccess:!error];
    if (self.hasLoad) {
        [self tt_endUpdataData:NO error:nil];
    } else {
        [self tt_endUpdataData:NO error:error];
    }
    
    if ([self tt_hasValidateData]) {
        [self reloadTableView];
    }
    
    //服务器故障提示错误提示
    if (TTNetworkConnected() && self.ttViewType == TTFullScreenErrorViewTypeNetWorkError) {
        self.ttErrorView.errorMsg.text = @"服务器出了点小故障，点击屏幕重试";
    }
}

- (void)triggerLoadMore {
    if ([self hasMoreData]) {
        [self loadRequest];
    } else {
        [self.tableView finishPullUpWithSuccess:YES];
    }
}

- (BOOL)hasMoreData
{
    //在未点击查看历史消息，而且该次load达到了未读已读分界时，取消loadMore
    if (!self.hasReadFooterView && self.readSeparatorIndex != NSNotFound) {
        return NO;
    }
    
    return self.hasMore;
}

#pragma mark - UIViewControllerErrorHandler
- (BOOL)tt_hasValidateData
{
    return self.hasLoad && self.messageModels.count > 0;
}

- (void)sessionExpiredAction
{
    [self calloutLoginIfNeed];
}

#pragma mark - UITableViewDelegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.hasLoad) {
        return 0;
    }
    
    if (self.hasReadFooterView) {
        return 1;
    } else {
        return 2; // 未点击查看历史消息，需要单独显示一个提示cell
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TTMessageNotificationCellSectionTypeMessage) {
        if (self.hasReadFooterView) {
            return self.messageModels.count;
        } else { //未点击查看历史消息，显示未读部分
            return MIN(self.readSeparatorIndex, self.messageModels.count);
        }
    } else if (section == TTMessageNotificationCellSectionTypeReadFooter) {
        if (self.hasReadFooterView) {
            return 0;
        } else if (self.readSeparatorIndex == NSNotFound) {
            return 0; //未达到未读已读分界
        } else {
            return 1;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            //calculate height
            CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:tableView].size.width;
            return [TTMessageNotificationCellHelper heightForData:model cellWidth:cellWidth];
        }
    } else if (indexPath.section == TTMessageNotificationCellSectionTypeReadFooter) {
        return [TTMessageNotificationReadFooterCell cellHeight];
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            // refresh UI
            cell = [TTMessageNotificationCellHelper dequeueTableCellForData:model tableView:tableView atIndexPath:indexPath];
            if([cell isKindOfClass:[TTMessageNotificationBaseCell class]]){
                [(TTMessageNotificationBaseCell*)cell refreshWithData:model];
            }
        }
    } else if (indexPath.section == TTMessageNotificationCellSectionTypeReadFooter) {
        cell = [tableView dequeueReusableCellWithIdentifier:kTTMessageNotificationReadFooterCellIdentifier];
        if (!cell) {
            cell = [[TTMessageNotificationReadFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTTMessageNotificationReadFooterCellIdentifier];
        }
    }
    
    if (!cell) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preventCrashCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"preventCrashCellIdentifier"];
        }
        cell.textLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            if([model.ID longLongValue] != 0){
                SSImpressionParams *params = [[SSImpressionParams alloc] init];
                params.actionType = model.actionType;
                [[SSImpressionManager shareInstance] recordMessageNotificationImpressionWithItemID:model.ID status:SSImpressionStatusRecording params:params];
            }
        }
    } else if (indexPath.section == TTMessageNotificationCellSectionTypeReadFooter) {
        wrapperTrackEvent(@"message_cell", @"history_show");
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            if([model.ID longLongValue] != 0){
                SSImpressionParams *params = [[SSImpressionParams alloc] init];
                params.actionType = model.actionType;
                [[SSImpressionManager shareInstance] recordMessageNotificationImpressionWithItemID:model.ID status:SSImpressionStatusEnd params:params];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            NSString *bodyUrl = model.content.bodyUrl;
            if (!isEmptyString(bodyUrl)) {
                if (self.shouldSendPushEvent) {
                    [TTTrackerWrapper eventV3:@"interactive_push_click_msgdetail" params:nil];
                    self.shouldSendPushEvent = NO;
                }
                
                wrapperTrackEventWithCustomKeys(@"message_cell", @"click", model.ID, nil, [TTMessageNotificationCellHelper listCellLogExtraForData:model]);
                
                NSURL *openURL = [TTStringHelper URLWithURLString:bodyUrl];
                NSString *URLString = openURL.absoluteString;
                if ([TTMessageCenterRouter canHandleOpenURL:openURL]) {
                    [TTMessageCenterRouter handleOpenURL:openURL];
                }
                else if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
                    [[TTRoute sharedRoute] openURLByPushViewController:openURL];
                }
                else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
                    UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
                    ssOpenWebView(openURL, @"", topController.navigationController, NO, nil);
                }
                else if([[UIApplication sharedApplication] canOpenURL:openURL]) {
                    [[UIApplication sharedApplication] openURL:openURL];
                }
                if (TTMessageNotificationStyleFollow == model.style.integerValue && model.user.userID.longLongValue > 0) {
                    [TTTrackerWrapper eventV3:@"enter_homepage"
                                       params:@{@"user_id":model.user.userID,
                                                @"from_page":@"message_cell"}];
                }
            }
        }
    } else if (indexPath.section == TTMessageNotificationCellSectionTypeReadFooter) {
        wrapperTrackEvent(@"message_cell", @"history_click");
        self.hasReadFooterView = YES;
        self.tableView.pullUpView.enabled = YES;
        [self reloadTableView];
        [self triggerLoadMore];
    }
}

#pragma mark - Util

- (void)addMessageModelsWithModels:(NSArray<TTMessageNotificationModel *> *)models;
{
    if (SSIsEmptyArray(models)) {
        return;
    }
    
    NSMutableArray<TTMessageNotificationModel *> *messageModels = [self.messageModels mutableCopy];
    __block TTMessageNotificationModel *preModel = self.messageModels.lastObject;
    [models enumerateObjectsUsingBlock:^(TTMessageNotificationModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        //如果是第一个，直接添加；否则，后续添加需要保持按cursor严格降序排列
        if (!preModel || [preModel.cursor compare:model.cursor] == NSOrderedDescending) {
            preModel = model;
            [messageModels addObject:model];
        }
    }];
    self.messageModels = [messageModels copy];
    
    // 保存最新的消息的cursor
    if(self.messageModels.count > 0){
        [[TTMessageNotificationTipsManager sharedManager] saveLastListMaxCursor:self.messageModels[0].cursor];
    }
}

- (void)searchIndexOfUnreadSeparatorIfNeed
{
    //一旦找到分界后，由于不支持下拉刷新reloadData，因此不需要再计算
    if (self.readSeparatorIndex != NSNotFound) {
        return;
    }
    if (self.hasReadFooterView) {
        self.readSeparatorIndex = NSNotFound;
        return;
    }
    
    if (![self.readCursor isKindOfClass:[NSNumber class]] || ![self.minCursor isKindOfClass:[NSNumber class]]) {
        self.readSeparatorIndex = NSNotFound;
        return;
    }
    
    //如果没有未读消息 当前进入消息列表的消息都是已读
    if (self.messageModels.count > 0 && [self.readCursor compare : self.messageModels[0].cursor] != NSOrderedAscending){
        self.readSeparatorIndex = NSNotFound;
        return;
    }
    
    //最小的minCursor如果大于readCursor，那么一定没达到分界
    if ([self.minCursor compare:self.readCursor] == NSOrderedDescending) {
        self.readSeparatorIndex = NSNotFound;
        return;
    }
    
    TTMessageNotificationModel *readCursorModel = [[TTMessageNotificationModel alloc] init];
    readCursorModel.cursor = self.readCursor;
    
    //二分搜索数组，根据cursor由小到大排序，且不重复，找到对应cursor >= readCursor的最小index
    NSUInteger readSeparatorIndex = [self.messageModels indexOfObject:readCursorModel inSortedRange:NSMakeRange(0, self.messageModels.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(TTMessageNotificationModel * _Nonnull obj1, TTMessageNotificationModel * _Nonnull obj2) {
        if (![obj1.cursor isKindOfClass:[NSNumber class]] || ![obj2.cursor isKindOfClass:[NSNumber class]]) { //保护
            return NSOrderedAscending;
        }
        
        return [obj2.cursor compare:obj1.cursor];
    }];
    
    self.readSeparatorIndex = readSeparatorIndex;
    self.tableView.pullUpView.enabled = NO;
}

- (void)updateReadSeparatorIndexIfNeeded {
    if (self.readSeparatorIndex != NSNotFound && self.readSeparatorIndex <= self.messageModels.count) {
        TTMessageNotificationModel *readCursorModel = [[TTMessageNotificationModel alloc] init];
        readCursorModel.cursor = self.readCursor;
        
        NSUInteger readSeparatorIndex = [self.messageModels indexOfObject:readCursorModel inSortedRange:NSMakeRange(0, self.messageModels.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(TTMessageNotificationModel * _Nonnull obj1, TTMessageNotificationModel * _Nonnull obj2) {
            if (![obj1.cursor isKindOfClass:[NSNumber class]] || ![obj2.cursor isKindOfClass:[NSNumber class]]) { //保护
                return NSOrderedAscending;
            }
            
            return [obj2.cursor compare:obj1.cursor];
        }];
        self.readSeparatorIndex = readSeparatorIndex;
    }
}

#pragma mark - impression统计相关

- (void)needRerecordImpressions{
    for (UITableViewCell * cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.section == TTMessageNotificationCellSectionTypeMessage) {
            if (indexPath.row < self.messageModels.count) {
                TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
                if([model.ID longLongValue] != 0){
                    SSImpressionParams *params = [[SSImpressionParams alloc] init];
                    params.actionType = model.actionType;
                    
                    [[SSImpressionManager shareInstance] recordMessageNotificationImpressionWithItemID:model.ID status:SSImpressionStatusRecording params:params];
                }
            }
        }
    }
}

#pragma mark - Monitor

- (void)monitorMessageResponse:(TTMessageNotificationResponseModel *)response error:(NSError *)error
{
    if ([response.msgList count] == 0) {
        NSMutableDictionary *extraParams = [NSMutableDictionary dictionary];
        
        [extraParams setValue:@(error.code) forKey:@"err_code"];
        [extraParams setValue:error.localizedDescription forKey:@"err_des"];
        
        [[TTMonitor shareManager] trackService:@"tt_message_monitor_list_no_data" status:1 extra:extraParams];
    }
}

@end
