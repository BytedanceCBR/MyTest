//
//  ArticleMomentListViewBase.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-27.
//
//

#import "ArticleMomentListViewBase.h"
#import "ArticleAvatarView.h"
#import "ArticleTitleImageView.h"
#import "ArticleMomentManager.h"
#import <TTAccountBusiness.h>
#import "ArticleCommentView.h"
#import "ArticleMomentDetailViewController.h"
#import "ArticleCommentView.h"
#import "ArticleListNotifyBarView.h"
#import "NetworkUtilities.h"
#import "SSActionManager.h"
#import "ArticleMomentGroupModel.h"
#import "SSUserSettingManager.h"
#import "ArticleBadgeManager.h"
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "ArticleAddressBridger.h"
#import "ExploreCellHelper.h"
#import "ExploreMixListDefine.h"
#import "ExploreMomentListCell.h"
#import "ArticlePostMomentViewController.h"
#import "ExploreMomentDefine.h"
#import "ArticleMomentCommentModel.h"
#import "ExploreDeleteManager.h"
#import "SSIndicatorTipsManager.h"
#import "ArticleForwardViewController.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import <objc/runtime.h>
#import "TTAuthorizeManager.h"
#import "TTMomentMomoCell.h"
#import "UIScrollView+Refresh.h"
#import "TTNavigationController.h"
#import "UIView+Refresh_ErrorHandler.h"

#import "SSWebViewController.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
//#import "TTAddFriendViewController.h"
#import "TTActivityShareSequenceManager.h"
#import "TTTabBarProvider.h"

#define kLoadMoreCellLabelTopPadding 14

#define kLogicOnceLoadCount 20

#define kHeaderViewHeight 257
#define kHeaderBgImageViewHeight 215
#define kAvatarViewHeight 57
#define kAvatarViewWidth 57
#define kHeaderLeftPadding 10
#define kHeaderRightPadding 10

#define kLoadMoreFontSize 15

#define kSendMomentButtonHeight 40

//#define kDeleteCommentActionSheetTag 1

#define kAssociatedCellKey     @"associatedCellKey"

extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface ArticleMomentListViewBase() <ArticleComentViewDelegate, ExploreMomentListCellBaseDelegate, SSActivityViewDelegate,UIViewControllerErrorHandler, TTAccountMulticastProtocol>
{
    NSTimeInterval _midnightInterval;
    BOOL _isShowing;
    
    //保护：当loadMore返回“hasMore”为true但无moment返回时，要防止反复调用loadMoreData
    BOOL _hasLoadedMore;
    
 }

@property(nonatomic, assign)BOOL isUserPull;
@property(nonatomic, assign)BOOL loadMoreHasMore;
@property(nonatomic, assign)BOOL serverErrorStatus;                         //记录当前server 返回异常， 如果异常， 则不允许自动加载
@property(nonatomic, strong)ArticleListNotifyBarView * notifyBarView;    //提示条

@property(nonatomic, strong)NSMutableSet * currentModelIDs;

@property(nonatomic, strong)UIButton * bottomSendMomentButton;
@property(nonatomic, weak)ArticleCommentView  *commentView;

@property(nonatomic, strong)ArticleMomentModel *momentModelWithNeedDeleteComment;
@property(nonatomic, strong)TTActivityShareManager *activityActionManager;
@property(nonatomic, strong)SSActivityView *phoneShareView;
@property(nonatomic, strong)ExploreMomentListCell *popToShareMomentCell;
@property(nonatomic, strong)NSTimer *preloadTimer;

@end

@implementation ArticleMomentListViewBase

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    
    if (self.commentView) {
        self.commentView.delegate = nil;
    }
    [_notifyBarView clean];
    _listView.delegate = nil;
    _listView.dataSource = nil;
    [_preloadTimer invalidate];
}


- (instancetype)initWithFrame:(CGRect)frame navigationBarHidden:(BOOL)navigationBarHidden refreshViewHidden:(BOOL)refreshViewHidden {
    self = [super initWithFrame:frame];
    if (self) {
        
        _showTipBar = YES;
        _isUserPull = YES;
        
        _isShowing = NO;
        [[SSImpressionManager shareInstance] addRegist:self];
        _serverErrorStatus = NO;
        _midnightInterval = 0;
        _loadMoreHasMore = YES;
        
        _hasLoadedMore = NO;
        
        self.currentModelIDs = [NSMutableSet setWithCapacity:100];
        
        self.listView = [[SSThemedTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.ttErrorToastView = [ArticleListNotifyBarView addErrorToastViewWithTop:self.ttContentInset.top width:self.width height:[SSCommonLogic articleNotifyBarHeight]];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView registerNib:[UINib nibWithNibName:@"TTMomentMomoCell" bundle:nil] forCellReuseIdentifier:@"MomoIdentifier"];
        
        [self addSubview:_listView];
        
        if (!navigationBarHidden) {
            self.navigationBar = [[SSNavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), [SSNavigationBar navigationBarHeight])];
            
            self.refreshTitleView = [[ArticleMomentRefreshTitleView alloc] initWithFrame:self.navigationBar.titleView.frame];
            self.refreshTitleView.delegate = self;
            self.navigationBar.titleView = self.refreshTitleView;
            
        }
        
        __weak typeof(self) wself = self;
        [self.listView tt_addDefaultPullDownRefreshWithHandler:^{
            [wself reloadData];
            if (wself.isUserPull) {
                if (wself.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
                    [TTTrackerWrapper event:@"micronews_tab" label:@"pull_refresh" value:nil extValue:nil extValue2:nil dict:nil];
                }
                else {
                    [wself momentTrack:@"pull_refresh"];
//                    if ([[[ArticleBadgeManager shareManger] momentUpdateNumber] integerValue] > 0) {
//                        [wself momentTrack:@"pull_refresh_tip"];
//                    }
//                    else {
//                        [wself momentTrack:@"pull_refresh"];
//                    }
                }
            }
            wself.isUserPull = YES;
        }];
        
        self.listView.hasMore = self.loadMoreHasMore;
        [self.listView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [wself loadMoreData];
        }];
        

        CGFloat notifyBarY;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            
            notifyBarY = 64;
        }
        else
            notifyBarY = 0;
        
        self.notifyBarView = [[ArticleListNotifyBarView alloc] initWithFrame:CGRectMake(0, notifyBarY, self.width, [SSCommonLogic articleNotifyBarHeight])];
        //[self addSubview:_notifyBarView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportSSEditUserProfileViewAvatarChangedNotification:) name:SSEditUserProfileViewAvatarChangedNotification object:nil];

        [TTAccount addMulticastDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteArticle:) name:kExploreMixListItemDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMoment:) name:kMomentDidDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:kSettingFontSizeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPostForumDoneNotification:) name:kPostForumItemDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPostMomentDoneNotification:) name:kPostMomentItemDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getForwardMomentDoneNotification:) name:kForwardMomentItemDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMomentNotification:) name:kDeleteMomentNotificationKey object:nil];
        
        [[self currentManager] setCacheEnabled:[self isCacheEnable]];
        [self refreshHeaderView];
        [self reloadThemeUI];
        
        [self bringSubviewToFront:self.navigationBar];
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame navigationBarHidden:NO refreshViewHidden:NO];
}

- (void)removeRegistFromImpression {
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.navigationBar.frame = CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight]);
    _listView.frame = self.bounds;

    if ([TTDeviceHelper isPadDevice])
    {
        [self.listView reloadData];
        [self _settingBottomSendMomentButtonFrame];
    }
}


- (void)themeChanged:(NSNotification *)notification
{
    _listView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.ttErrorView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];

    
    if (self.bottomSendMomentButton) {
        _bottomSendMomentButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
        [_bottomSendMomentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
        [_bottomSendMomentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText12Highlighted] forState:UIControlStateHighlighted];
        [_bottomSendMomentButton setImage:[UIImage themedImageNamed:@"writeicon_dynamic.png"] forState:UIControlStateNormal];
        [_bottomSendMomentButton setImage:[UIImage themedImageNamed:@"writeicon_dynamic_press.png"] forState:UIControlStateHighlighted];
    }
}

- (void)refreshListUI
{
    [_listView reloadData];
}

- (void)fontSizeChanged:(NSNotification *)notification
{
    [self refreshListUI];
}

- (void)receiveDeleteMoment:(NSNotification *)notification
{
    long long  mid = [[[notification userInfo] objectForKey:@"momentID"] longLongValue];
    if (mid == 0) {
        return;
    }
    NSString * midStr = [NSString stringWithFormat:@"%lli", mid];
    ArticleMomentModel * needOmitModel = [self fetchMomentFromCurrentMomentsByID:midStr];
    [self deleteMomdel:needOmitModel];
}

- (void)receiveDeleteArticle:(NSNotification *)notification
{
    long long  gid = [[[notification userInfo] objectForKey:@"uniqueID"] longLongValue];
    if (gid == 0) {
        return;
    }
    NSString * needOmitArticleID = [NSString stringWithFormat:@"%lli", gid];
    ArticleMomentModel * needOmitModel = [self articleInMomentModels:needOmitArticleID];
    [self deleteMomdel:needOmitModel];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self showBottomSendMomentButtonIfNeed];
    
     _loadMoreHasMore = YES;
}

#pragma mark - Notifications

- (void)receiveDeleteMomentNotification:(NSNotification *)notification
{
    long long momengID = [[[notification userInfo] objectForKey:@"id"] longLongValue];
    if (momengID == 0) {
        return;
    }
    NSArray * allMoments = [[self currentManager] momentsInManagerForID:[NSString stringWithFormat:@"%lli", momengID] containForwardOriginItem:YES];
    for (ArticleMomentModel * model in allMoments) {
        [model.originItem deleteModelContent];
    }
    NSArray * moments = [[self currentManager] momentsInManagerForID:[NSString stringWithFormat:@"%lli", momengID] containForwardOriginItem:NO];
    if ([moments count] > 0) {
        [[self currentManager] removeMoments:moments];
        [self refreshListUI];
    }
}



- (void)willAppear
{
    [super willAppear];
    
    [self.listView reloadData];
    
    _isShowing = YES;
    if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
        [[SSImpressionManager shareInstance] enterWeitoutiaoViewForKeyName:[self impressionKeyName]];
    }
    else {
        [[SSImpressionManager shareInstance] enterMomentViewForKeyName:[self impressionKeyName]];
    }
}

- (void)didAppear
{
    [super didAppear];

    self.ttContentInset = UIEdgeInsetsMake(self.listView.originContentInset.top,0,0,0);

    
    if ([self sourceType] == ArticleMomentSourceTypeMoment && self.currentManager.moments.count > 0) {
        [self showAuthorizeAlert];
    }
}

- (void)willDisappear
{
    [super willDisappear];
    _isShowing = NO;
    
    if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
        [[SSImpressionManager shareInstance] leaveWeitoutiaoViewForKeyName:[self impressionKeyName]];
    }
    else {
        [[SSImpressionManager shareInstance] leaveMomentViewForKeyName:[self impressionKeyName]];
    }
}

- (BOOL)isCacheEnable
{
    return NO;
}

- (void)scrollToTopCellAnimation:(BOOL)animation
{
    if (![self isNoData] && [self.listView numberOfRowsInSection:0]) {
        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.listView scrollToRowAtIndexPath:firstRow atScrollPosition:UITableViewScrollPositionTop animated:animation];
    }
}

#pragma mark -- action

- (void)openPostMomentViewController
{
    [self postMoment];
}

- (void)postMoment
{
    ArticlePostMomentViewController * postMomentController = nil;
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        postMomentController = [[ArticlePostMomentViewController alloc] initWithSourceType:PostMomentSourceFromForum];
        postMomentController.forumID = [[self currentUserID] longLongValue];
    }
    else {
        postMomentController = [[ArticlePostMomentViewController alloc] initWithSourceType:PostMomentSourceFromMoment];
    }
    
    UIViewController * vc = [TTUIResponderHelper topViewControllerFor: self];;
    if (vc) {
        TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:postMomentController];
        nav.ttDefaultNavBarStyle = @"White";

        [vc presentViewController:nav animated:YES completion:NULL];
    }

}

- (void)openMomentDetail:(ArticleMomentModel *)model
{
    if (!model) {
        return;
    }

    ArticleMomentDetailViewController * controller = [[ArticleMomentDetailViewController alloc] initWithMomentModel:model momentManager:[self currentManager] sourceType:ArticleMomentSourceTypeMomentDetail];
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
}

- (void)_settingBottomSendMomentButtonFrame
{
    _bottomSendMomentButton.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kSendMomentButtonHeight, CGRectGetWidth(self.frame), kSendMomentButtonHeight);
//    _bottomSendMomentButton.frame = CGRectMake(CGRectGetMinX([self splitViewFrame]), CGRectGetHeight(self.frame) - kSendMomentButtonHeight, CGRectGetWidth([self splitViewFrame]), kSendMomentButtonHeight);
}

#pragma mark -- public

- (void)showBottomSendMomentButtonIfNeed
{
    BOOL needShow = NO;
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        needShow = YES;
    }
    
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        needShow = YES;
    }
    if (!needShow) {
        if (_listView.contentInset.bottom != 0) {
            UIEdgeInsets inset = _listView.contentInset;
            inset.bottom = 0;
            _listView.contentInset = inset;
        }
        return;
    }

    if (!needShow) {
        return;
    }
    
    if (!_bottomSendMomentButton) {
        NSString * title = self.sourceType == ArticleMomentSourceTypeMoment ? @" 发动态" : @" 发新帖";
        self.bottomSendMomentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomSendMomentButton setTitle:title forState:UIControlStateNormal];
        [_bottomSendMomentButton setTitle:title forState:UIControlStateHighlighted];
        [_bottomSendMomentButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_bottomSendMomentButton addTarget:self action:@selector(openPostMomentViewController) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bottomSendMomentButton];
    }
    [self _settingBottomSendMomentButtonFrame];
    _bottomSendMomentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIEdgeInsets inset = _listView.contentInset;
    inset.bottom = (_bottomSendMomentButton.height);
    _listView.contentInset = inset;
}

#pragma mark -- protected

- (NSString *)impressionKeyName
{
    return nil;
}

- (NSString *)currentUmentEventName
{
    return @"update_tab";
}

- (NSString *)umentEventName
{
    if ([self fromSource] == NewsGoDetailFromSourceUpate) {
        return @"update_tab";
    }
    else if ([self fromSource] == NewsGoDetailFromSourceUpdateDetail) {
        return @"update_detail";
    }
    else if ([self fromSource] == NewsGoDetailFromSourceProfile) {
        return @"profile";
    }
    return nil;
}

- (void)momentTrack:(NSString *)label
{
    NSString * eventName = [self umentEventName];
    if (!isEmptyString(eventName) && !isEmptyString(label)) {
        wrapperTrackEvent(eventName, label);
    }
}


- (NewsGoDetailFromSource)fromSource
{
    return NewsGoDetailFromSourceUpate;
}

- (void)refreshHeaderView
{
}

- (ArticleMomentManager *)currentManager
{
    return nil;
}

- (ArticleMomentSourceType)sourceType
{
    //subview implements
    return ArticleMomentSourceTypeProfile;
}

- (void)loadMoreDataDone
{
    [_currentModelIDs removeAllObjects];
    for (ArticleMomentModel * model  in [self currentMomentModels]) {
        [_currentModelIDs addObject:model.ID];
    }
}

- (void)reloadDataDone:(NSError *)error
{
    if (!error) {
        [_currentModelIDs removeAllObjects];
        for (ArticleMomentModel * model  in [self currentMomentModels]) {
            [_currentModelIDs addObject:model.ID];
        }
    }
}

- (NSString *)currentUserID
{
    return nil;
}

- (NSString *)currentTalkID
{
    return nil;
}

- (void)clearTalkID {
}

- (BOOL)notifyBarCouldShow
{
    return YES;
}

#pragma mark -- delete logic

- (void)deleteModels:(NSArray *)list
{
    [[self currentManager] removeMoments:list];
    [self refreshListUI];
}

- (void)deleteMomdel:(ArticleMomentModel *)model
{
    [[self currentManager] removeMoment:model];
    [self refreshListUI];
}

- (ArticleMomentModel *)fetchMomentFromCurrentMomentsByID:(NSString *)mID
{
    if (isEmptyString(mID)) {
        return nil;
    }
    ArticleMomentModel * result = nil;
    for (ArticleMomentModel * model in [self currentMomentModels]) {
        if ([model.ID isEqualToString:mID]) {
            result = model;
            break;
        }
    }
    return result;
}

- (ArticleMomentModel *)articleInMomentModels:(NSString *)gID
{
    if (isEmptyString(gID)) {
        return nil;
    }
    ArticleMomentModel * result = nil;
    for (ArticleMomentModel * model in [self currentMomentModels]) {
        if ([model.group.ID isEqualToString:gID]) {
            result = model;
            break;
        }
    }
    return result;
}

#pragma mark -- logic

- (NSArray *)currentMomentModels
{
    return [[self currentManager] moments];
}

- (ArticleMomentModel *)modelForIndex:(NSUInteger)index
{
    if (index < [[self currentMomentModels] count]) {
        ArticleMomentModel * model = [[self currentMomentModels] objectAtIndex:index];
        return model;
    }
    return nil;
}

- (void)pullAndRefresh
{
    self.isUserPull = NO;
    [self.listView triggerPullDown];
}

- (BOOL)tt_hasValidateData {
    
    if (self.listView.tableHeaderView) {
        return YES;
    }
    return [[self currentMomentModels] count] > 0;
}

- (void)reloadData
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    _midnightInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
    
    if (self.refreshTitleView)
    {
        [self.refreshTitleView startAnimation];
    }
    
    //为了蓝条 拼了！-- nick
    self.listView.ttIntegratedMessageBar = self.ttErrorToastView;
    self.ttAssociatedScrollView = self.listView;
    self.ttTargetView = self.listView;
    
    if (self.showTipBar) {
        [self tt_startUpdate];
        self.ttLoadingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
    __weak __typeof(self) weakSelf = self;
    [[self currentManager] startRefreshWithID:[self currentUserID] talkID:[self currentTalkID] listType:[self sourceType] count:kLogicOnceLoadCount finishBlock:^(NSArray *moments, NSDictionary *userInfo, NSError *error) {
        
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        NSString * msg = nil;
        SSTipModel * model = nil;
        NSDictionary * tipDicts = [userInfo objectForKey:kArticleMomentUserTipDataKey];
        
        if ([tipDicts count] > 0) {
            model = [[SSTipModel alloc] initWithDictionary:tipDicts];
            msg = [tipDicts objectForKey:@"display_info"];
        }
        
        if (self.showTipBar) {
            [strongSelf tt_endUpdataData:NO error:error tip:msg duration:3 tipTouchBlock:^{
                if (model) {
                    if ([model.type isEqualToString:@"app"]) {
                        if ([model.openURL hasSuffix:@"login"]) {
                            wrapperTrackEvent(@"notify", @"tips1_click");
                        } else if ([model.openURL hasSuffix:@"add_friend"]) {
                            wrapperTrackEvent(@"notify", @"tips2_click");
                        }
                    }
                    [[SSActionManager sharedManager] actionForModel:model];
                }
                
            }];
            self.ttErrorView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        }
        
        if (error) {
         
            [strongSelf refreshListUI];
            [strongSelf reloadDataDone:error];
            
        }
        else {
            if ([strongSelf currentTalkID]) {
                [strongSelf clearTalkID];
            }
            
            [strongSelf refreshListUI];
            [strongSelf reloadDataDone:error];
            [strongSelf updateDetails:[userInfo objectForKey:kArticleMomentUserInfoChangeListKey]];
            
            if ([[userInfo allKeys] containsObject:kArticleMomentUserInfoHasMoreKey]) {
                //reloadData的时候，hasMore表示是否与本地数据有空隙，所以hasMore为NO的时候，不表示loadMoreHasMore也为NO，所以改为|=
                strongSelf.loadMoreHasMore |= [[userInfo objectForKey:kArticleMomentUserInfoHasMoreKey] boolValue];
                strongSelf.listView.hasMore = strongSelf.loadMoreHasMore;
            }
            
            if ([strongSelf currentMomentModels].count == 0) {
                strongSelf.loadMoreHasMore = NO;
                strongSelf.listView.hasMore = strongSelf.loadMoreHasMore;
                
            }

        }
        
        [strongSelf.refreshTitleView stopAnimation];

        if ([self.delegate respondsToSelector:@selector(momentListViewDidFinishPullRefresh:error:tip:)]) {
            [self.delegate momentListViewDidFinishPullRefresh:self error:error tip:msg];
        }
        else
            [weakSelf.listView finishPullDownWithSuccess:!error];

        
        if ([self sourceType] == ArticleMomentSourceTypeMoment) {
            [self showAuthorizeAlert];
        }
        

    }];
}

- (void)updateDetails:(NSArray *)momentIDs
{
    NSMutableArray * fetchAry = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < [momentIDs count]; i ++) {
        NSString * str = [NSString stringWithFormat:@"%lli", [[momentIDs objectAtIndex:i] longLongValue]];
        if ([_currentModelIDs containsObject:str] && !isEmptyString(str)) {
            [fetchAry addObject:str];
        }
    }
    
    if ([fetchAry count] == 0) {
        return;
    }
    
    [[self currentManager] startGetMomentDetailWithIDs:momentIDs finishBlock:^(NSArray *moments, NSDictionary *userInfo, NSError *error) {
        if (!error) {
            if ([moments count] > 0) {
                
                NSMutableArray * ary = [NSMutableArray arrayWithCapacity:10];
                for (ArticleMomentModel * model in moments) {
                    if (model.isDeleted) {
                        [ary addObject:model];
                    }
                }
                [self deleteModels:ary];
            }
        }
    }];
}


- (void)loadMoreData
{
    if ([[self currentManager] isLoading] || !_isShowing) return;
    
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        wrapperTrackEvent(@"topic_tab", @"loadmore");
    } else {
        if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
            [TTTrackerWrapper event:@"micronews_tab" label:@"load_more" value:nil extValue:nil extValue2:nil dict:nil];
        }
        else {
            wrapperTrackEvent(@"update_tab", @"loadmore");
        }
    }
    
    __weak typeof(self) wself = self;
    [[self currentManager] startLoadMoreWithID:[self currentUserID] listType:[self sourceType] count:kLogicOnceLoadCount finishBlock:^(NSArray *moments, NSDictionary *userInfo, NSError *error) {
        
        [wself.listView finishPullUpWithSuccess:!error];

        
        
        if (error) {
            wself.serverErrorStatus = YES;
            
        }
        else {
            wself.serverErrorStatus = NO;
            
            
        }
        
        if ([[userInfo allKeys] containsObject:kArticleMomentUserInfoHasMoreKey]) {
            wself.loadMoreHasMore = [[userInfo objectForKey:kArticleMomentUserInfoHasMoreKey] boolValue];
            wself.listView.hasMore = wself.loadMoreHasMore;
        }
        
        if ([wself currentMomentModels].count == 0) {
            wself.loadMoreHasMore = NO;
            wself.listView.hasMore = wself.loadMoreHasMore;
            
        }

        
        _hasLoadedMore = YES;
        [wself refreshListUI];
        [wself loadMoreDataDone];
    }];
}

- (BOOL)isNoData
{
    return [[self currentMomentModels] count] == 0 && !_loadMoreHasMore;
}

#pragma mark -- UITableViewDelegate & UITableVewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self currentMomentModels] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleMomentModel * model = [self  modelForIndex:indexPath.row];
    if (model) {
        if (model.cellType == MomentListCellTypeMoment) {
            return [ExploreMomentListCell heightForModel:model cellWidth:[TTUIResponderHelper splitViewFrameForView:self].size.width sourceType:self.sourceType];
        } else if (model.cellType == MomentListCellTypeMomo) {
            return 60;
        } else {
            return 0;
        }
    }
 
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  包含文章的动态, 对应MomentItemTypeArticle = 100,
     */
    static NSString * momentCellIdentifier = @"ExploreMomentMomentCellIdentifier";
    static NSString * tipMoreCellIdentifier = @"tipMoreCellIdentifier";
    static NSString * recommendUserIdentifier = @"recommendUserIdentifier";
    
    UITableViewCell *tableViewCell = nil;
    if (indexPath.row < [[self currentMomentModels] count]) {
        ArticleMomentModel * model = [self modelForIndex:indexPath.row];
        
        if (model.cellType == MomentListCellTypeMoment) {

            ExploreMomentListCell * cell = [tableView dequeueReusableCellWithIdentifier:momentCellIdentifier];
            
            if (!cell) {
                cell = [[ExploreMomentListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:momentCellIdentifier];
                cell.delegate = self;
            }
            cell.sourceType = self.sourceType;
            cell.cellIndex = indexPath;

            [cell refreshWithModel:model indexPath:indexPath];
            
            UIButton *forwardButton = cell.headerItem.actionItemView.forwardButton;
            if (forwardButton) {
                objc_setAssociatedObject(forwardButton, kAssociatedCellKey, cell, OBJC_ASSOCIATION_ASSIGN);
                [forwardButton addTarget:self
                                  action:@selector(shareButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            }
            tableViewCell = cell;
            
        } else if (model.cellType == MomentListCellTypeMomo) {
            TTMomentMomoCell *momoCell = [tableView dequeueReusableCellWithIdentifier:@"MomoIdentifier"];
            momoCell.momentModel = model;
            if (!momoCell) {
                momoCell = [[TTMomentMomoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MomoIdentifier"];
            }
            tableViewCell = momoCell;
        }
    }
    if (!tableViewCell) {
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"unknownCellIdentifier"];
        if (!tableViewCell) {
            tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tipMoreCellIdentifier];
        }
    }

    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[self currentMomentModels] count]) {
        ArticleMomentModel * model = [[self currentMomentModels] objectAtIndex:indexPath.row];
        if (model.cellType == MomentListCellTypeMoment) {
            if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:model.ID forKey:@"item_id"];
                [extra setValue:model.group.ID forKey:@"value"];
                [TTTrackerWrapper event:@"micronews_tab" label:@"detail" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            else {
                wrapperTrackEventWithCustomKeys(@"update_detail", @"enter", model.ID, nil, @{@"ext_value": model.itemType == MomentItemTypeForum? @"2": @"3"});
            }
            [self openMomentDetail:model];
        } else if (model.cellType == MomentListCellTypeMomo) {
            wrapperTrackEvent(@"topic_tab", @"group_cell_click");
            NSURL *URL = [TTStringHelper URLWithURLString:model.url];
            if (URL) {
                ssOpenWebView(URL, nil, self.navigationController, NO, nil);
            }
        }
    }
    else if ([self isNoData]) {
        //do nothing..
    }
    else {
        //load more
        if (![[self currentManager] isLoading]) {
            [self loadMoreData];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[self currentMomentModels] count]) {
        ArticleMomentModel * model = [self modelForIndex:indexPath.row];
        
        SSImpressionStatus impressionStatus = _isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
            [ArticleImpressionHelper recordGroupForWeitoutiaoWithMomentModel:model status:impressionStatus keyName:[self impressionKeyName]];
        }
        else {
            [ArticleImpressionHelper recordGroupForMomentModel:model status:impressionStatus keyName:[self impressionKeyName]];
        }
        
    } else {
        if ([[[self currentManager] moments] count] > 0 && ![[self currentManager] isLoading] && !_serverErrorStatus && !_hasLoadedMore) {
            [self loadMoreData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[self currentMomentModels] count]) {
        ArticleMomentModel * model = [self modelForIndex:indexPath.row];
        if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
            [ArticleImpressionHelper recordGroupForWeitoutiaoWithMomentModel:model status:SSImpressionStatusEnd keyName:[self impressionKeyName]];
        }
        else {
            [ArticleImpressionHelper recordGroupForMomentModel:model status:SSImpressionStatusEnd keyName:[self impressionKeyName]];
        }
    }
}

#pragma mark - ActionItemViewShareButton

- (void)shareButtonPressed:(id)sender
{
    UIButton *shareButton = (UIButton *)sender;
    ExploreMomentListCell *cell = objc_getAssociatedObject(shareButton, kAssociatedCellKey);
    self.popToShareMomentCell = cell;
    NSIndexPath *indexPath = [self.listView indexPathForCell:cell];
    ArticleMomentModel *moment = [self modelForIndex:indexPath.row];
    
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager moment:moment sourceType:ArticleMomentSourceTypeMoment];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnWindow:self.window];
    
    if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:moment.ID forKey:@"item_id"];
        [extra setValue:moment.group.ID forKey:@"value"];
        [TTTrackerWrapper event:@"share_micronews_post" label:@"share_button" value:nil extValue:nil extValue2:nil dict:[extra copy]];
    }
    else {
        [self sendMomentShareTrackWithItemType:TTActivityTypeShareButton forMoment:moment];
    }
}

- (TTShareSourceObjectType)sourceTypeForSharedHeaderItem:(ExploreMomentListCellHeaderItem *)headerItem momentModel:(ArticleMomentModel *)moment
{
    if ([headerItem.forwardItemView isForumItemViewShown]) {
        return TTShareSourceObjectTypeForumPost;
    }
    else if (moment.itemType == MomentItemTypeOnlyShowInForum ||
             moment.itemType == MomentItemTypeForum) {
        return TTShareSourceObjectTypeForumPost;
    }
    else {
        return TTShareSourceObjectTypeMoment;
    }
}

#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        NSIndexPath *indexPath = [self.listView indexPathForCell:self.popToShareMomentCell];
        ArticleMomentModel *moment = [self modelForIndex:indexPath.row];
        TTShareSourceObjectType sourceType = [self sourceTypeForSharedHeaderItem:self.popToShareMomentCell.headerItem momentModel:moment];
        if (itemType == TTActivityTypeMyMoment) {
            [self.popToShareMomentCell.headerItem.actionItemView forwardButtonClicked];
            if (ttvs_isShareIndividuatioEnable()){
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
            }
        }
        else {
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:sourceType uniqueId:moment.ID];
            self.phoneShareView = nil;
        }
        [self sendMomentShareTrackWithItemType:itemType forMoment:moment];
        
        self.popToShareMomentCell = nil;
    }
}

#pragma mark -- Track

- (void)sendMomentShareTrackWithItemType:(TTActivityType)itemType forMoment:(ArticleMomentModel *)moment
{
    TTShareSourceObjectType sourceType = [self sourceTypeForSharedHeaderItem:self.popToShareMomentCell.headerItem momentModel:moment];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:sourceType];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    NSString *forumId = moment.forumID ? [NSString stringWithFormat:@"%lld", moment.forumID] : nil;
    wrapperTrackEventWithCustomKeys(tag, label, moment.ID, forumId, nil);
}

#pragma mark - ArticleCommentDelegate
- (void) commentView:(ArticleCommentView *)commentView
didFinishPublishComment:(ArticleMomentCommentModel *)commentModel {

    [commentView dismissAnimated:YES];
    self.commentView = nil;
}

- (void) commentView:(ArticleCommentView *) commentView
     willChangeFrame:(CGRect) newFrame
      keyboardHidden:(BOOL)keyboardHidden
         contextInfo:(id) contextInfo {
    if (![contextInfo valueForKey:@"frame"] || ![contextInfo valueForKey:@"contentOffset"]) {
        return;
    }
    CGRect frame = CGRectFromString([contextInfo valueForKey:@"frame"]);
    CGPoint contentOffset = CGPointFromString([contextInfo valueForKey:@"contentOffset"]);
    UIEdgeInsets contentInset = self.listView.contentInset;
    if (!keyboardHidden) {
        CGFloat delta = CGRectGetMinY(newFrame) - CGRectGetMaxY(frame);
        contentOffset.y -= delta;
        if (contentOffset.y < 0) {
            contentOffset.y = 0;
        }
        CGFloat contentMaxY = contentOffset.y + CGRectGetHeight(self.listView.frame);
        if (contentMaxY > self.listView.contentSize.height) {
            CGFloat contentHeight = self.listView.contentSize.height;
            contentInset.bottom = contentMaxY - contentHeight;
        }
    } else {
        contentInset.bottom = 0;
    }
    [UIView animateWithDuration:0.25 animations:^{
        if (!keyboardHidden) {
             self.listView.contentOffset = contentOffset;
        }
        self.listView.contentInset = contentInset;
    }];
}


#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions
{
    if ([[[self currentManager] moments] count] == 0) {
        return;
    }
    
    for (UITableViewCell * cell in [_listView visibleCells]) {
        if ([cell isKindOfClass:[ExploreMomentListCellBase class]]) {
            
            SSImpressionStatus status = SSImpressionStatusRecording;
            if (!_isShowing) {
                status = SSImpressionStatusSuspend;
            }
            
            if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
                [ArticleImpressionHelper recordGroupForWeitoutiaoWithMomentModel:((ExploreMomentListCellBase *) cell).momentModel status:status keyName:[self impressionKeyName]];
            }
            else {
                [ArticleImpressionHelper recordGroupForMomentModel:((ExploreMomentListCellBase *) cell).momentModel status:status keyName:[self impressionKeyName]];
            }
        }
    }
}

#pragma mark -- ArticleMomentRefreshTitleViewDelegate
- (void)rotationViewDidClicked:(ArticleMomentRefreshTitleView *)view
{
    self.isUserPull = NO;
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        wrapperTrackEvent(@"topic_tab", @"refresh_button");
    } else {
        wrapperTrackEvent(@"update_tab", @"refresh_button");
    }
    [self.listView triggerPullDown];
}

#pragma mark -- notification

- (void)reportSSEditUserProfileViewAvatarChangedNotification:(NSNotification*)notification
{
    [self.listView reloadData];
}

- (void)getPostMomentDoneNotification:(NSNotification *)notification
{
    if (self.sourceType != ArticleMomentSourceTypeMoment) {
        return;
    }
    
    ArticleMomentModel * momentModel = [[notification userInfo] objectForKey:@"item"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self insertMomentModelToTop:momentModel];
    });
}

- (void)getForwardMomentDoneNotification:(NSNotification *)notification
{
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        return;
    }
    if (self.sourceType == ArticleMomentSourceTypeProfile) {
        if (![TTAccountManager isLogin]) {
            return;
        }
        
        if ([[TTAccountManager userID] longLongValue] != [[self currentUserID] longLongValue]) {
            return;
        }
    }
    ArticleMomentModel * momentModel = [[notification userInfo] objectForKey:@"item"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self insertMomentModelToTop:momentModel];
    });
}

- (void)getPostForumDoneNotification:(NSNotification *)notification
{
    if (self.sourceType != ArticleMomentSourceTypeForum) {
        return;
    }
    
    if ([[self currentUserID] longLongValue] != [[[notification userInfo] objectForKey:@"forum_id"] longLongValue]) {
        return;
    }
    
    ArticleMomentModel * momentModel = [[notification userInfo] objectForKey:@"item"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self insertMomentModelToTop:momentModel];
    });
}

- (void)insertMomentModelToTop:(ArticleMomentModel *)momentModel
{
    if ([momentModel.ID longLongValue] == 0) {
        return;
    }
    BOOL isDone = [[self currentManager] insertModel:momentModel toIndex:0];
    if (isDone) {
        
        [self tt_endUpdataData];
        [self refreshListUI];
        [self scrollToTopCellAnimation:NO];
    }
}

#pragma mark -- ExploreMomentListCellBaseDelegate

- (void)momentListCell:(ExploreMomentListCellBase *)listCell openCommentDetailForModel:(ArticleMomentModel *)model
{
    if (model) {
        [self openMomentDetail:model];
    }
}

- (void)momentListCell:(ExploreMomentListCellBase *)listCell needReloadForIndex:(NSUInteger)index
{
    if (index < [[self currentManager].moments count]) {
        //NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
        //[_listView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        [_listView reloadData];
    }
}

- (void)momentListCell:(ExploreMomentListCellBase *)listCell commentButtonClicked:(ArticleMomentCommentModel *)commentModel rectInKeyWindow:(CGRect)rect
{
    
    // 拉黑逻辑
    ArticleMomentModel *momentModel = listCell.momentModel;
    if (commentModel.user.isBlocked || commentModel.user.isBlocking || momentModel.user.isBlocked || momentModel.user.isBlocking)
    {
        NSString * description = nil;
        if (commentModel.user.isBlocked || momentModel.user.isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
        } else if (commentModel.user.isBlocking || momentModel.user.isBlocking){
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
        } else {
            NSLog(@"error");
            return;
        }
        if (!description) {
            description = (commentModel.user.isBlocked || momentModel.user.isBlocked) ? @" 根据对方设置，您不能进行此操作" : @"您已拉黑此用户，不能进行此操作";
        }

        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:description indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    NSMutableDictionary * contextInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [contextInfo setValue:momentModel forKey:ArticleMomentModelKey];
    [contextInfo setValue:commentModel forKey:ArticleMomentCommentModelKey];
    [contextInfo setValue:NSStringFromCGRect(rect) forKey:@"frame"];
    [contextInfo setValue:NSStringFromCGPoint(self.listView.contentOffset) forKey:@"contentOffset"];
    ArticleCommentView * commentView = [[ArticleCommentView alloc] init];
    commentView.contextInfo = contextInfo;
    commentView.delegate = self;
    [commentView showInView:nil animated:YES];
    
    if (self.sourceType != ArticleMomentSourceTypeMoment || [TTTabBarProvider isFollowTabOnTabBar]) {
        [self momentTrack:@"reply"];
    }
}

- (void)showAuthorizeAlert {
//    [[TTAuthorizeManager sharedManager].addressObj showAlertAtPageMoment:^{
//        TTAddFriendViewController *addFriendController = [[TTAddFriendViewController alloc] init];
//        addFriendController.autoSynchronizeAddressBook = YES;
//        [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:addFriendController animated:YES];
//    }];
}

#pragma mark -- PreLoadMore

#define kPreloadMoreThreshold 5

- (void)tryPreloadMore {
    [self.preloadTimer invalidate];
    
    self.preloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                         target:self
                                                       selector:@selector(preloadMore)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)preloadMore
{
    if ([[[self currentManager] moments] count] > 0 && ![[self currentManager] isLoading] && !_serverErrorStatus) {
        NSArray * visibleIndexes = [_listView indexPathsForVisibleRows];
        if ([visibleIndexes count] > 0) {
            id obj = [visibleIndexes lastObject];
            if ([obj isKindOfClass:[NSIndexPath class]]) {
                NSIndexPath * index = obj;
                if (index.row + kPreloadMoreThreshold >= [[self currentMomentModels] count]) {
                    [self loadMoreData];
                }
            }
        }
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.preloadTimer) {
        [self.preloadTimer invalidate];
        self.preloadTimer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self tryPreloadMore];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self tryPreloadMore];
}

@end
