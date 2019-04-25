//
//  ArticleNoticeView.m
//  Article
//
//  Created by SunJiangting on 14-5-26.
//
//

#import "ArticleNoticeView.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "ArticleNoticeViewCell.h"

#import "ArticleNotificationManager.h"
#import "ArticleNotificationModel.h"

#import "ArticleMomentProfileViewController.h"
#import "ArticleBadgeManager.h"
#import "ArticleFriend.h"
#import "TTRelationshipViewController.h"
#import "ArticleMomentProfileViewController.h"
#import "ArticleMomentHelper.h"
#import "ArticleEmptyView.h"
#import "SSUserSettingManager.h"
#import "NetworkUtilities.h"
#import "ArticleListNotifyBarView.h"
#import "SSNavigationBar.h"
//#import "ExploreEntryHelper.h"

#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTStringHelper.h"
#import "TTRoute.h"



#import <TTAccountBusiness.h>


const NSInteger ArticleNoticePageSize = 20;


@interface ArticleNoticeView () <UITableViewDataSource, UITableViewDelegate, ArticleNoticeDelegate,UIViewControllerErrorHandler> {
}

@property (nonatomic, strong) ArticleNotificationManager * manager;
@property (nonatomic, strong) ArticleTableView         * tableView;
@property (nonatomic, copy)   NSArray *messages;

@end

@implementation ArticleNoticeView

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.manager = [ArticleNotificationManager sharedManager];
        
        
        self.tableView = [[ArticleTableView alloc] initWithFrame:self.tableViewFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollsToTop = NO;
        [self addSubview:self.tableView];
        
        NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"正在努力加载";
        
        __weak typeof(self) wself = self;
        [self.tableView addPullDownWithInitText:@"下拉刷新"
                                       pullText:@"松开即可刷新"
                                    loadingText:loadingText
                                     noMoreText:@"暂无新数据"
                                       timeText:nil
                                    lastTimeKey:nil
                                  actionHandler:^{
                                      [wself refreshDataFromCache:NO];
                                  }];
        
        CGFloat barH = [SSCommonLogic articleNotifyBarHeight];
        self.ttMessagebarHeight = barH;
        if ([SSCommonLogic isNewPullRefreshEnabled]) {
            self.tableView.pullDownView.pullRefreshLoadingHeight = barH;
            self.tableView.pullDownView.messagebarHeight = barH;
        }
        
        [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [wself loadNextPage];
        }];
        
        
        [self.tableView registerClass:[ArticleNoticeViewCell class] forCellReuseIdentifier:ArticleNoticeCellIdentifier];
        
        [self.tableView registerClass:[ArticlePGCNoticeViewCell class] forCellReuseIdentifier:ArticlePGCNoticeCellIdentifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
        [self reloadThemeUI];
        
        [self tt_startUpdate];
    }
    return self;
}

- (BOOL)tt_hasValidateData {
    return self.messages.count>0;
}

- (CGRect)tableViewFrame {
    return self.bounds;
}


- (void)fontChanged:(NSNotification *) notification {
    [self.tableView reloadData];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)emptyViewBtnAction {
    
    [self.tableView triggerPullDown];
    
}

- (void)refreshDataFromCache:(BOOL)fromCache {
    
    [self tt_startUpdate];
    
    __weak ArticleNoticeView * weakSelf = self;
    
    [self.manager startRefreshNotificationsWithCount:ArticleNoticePageSize finishBlock:^(NSArray *notifications, BOOL hasMore, NSError *error) {
        if (!error) {
            if(fromCache) {
                self.messages = self.manager.notifications;
            }
            else {
                self.messages = notifications;
            }
            
            weakSelf.tableView.hasMore = hasMore;
            if (weakSelf.badgeChangedHandler) {
                weakSelf.badgeChangedHandler(weakSelf);
            }
            [weakSelf.tableView reloadData];
        }
        
        [weakSelf.tableView finishPullDownWithSuccess:!error];
        if ([TTAccountManager isLogin]) {
            weakSelf.ttViewType = TTFullScreenErrorViewTypeEmpty;
            [weakSelf tt_endUpdataData:fromCache error:error];
        } else {
            weakSelf.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
            [weakSelf tt_endUpdataData:fromCache error:[NSError errorWithDomain:kCommonErrorDomain code:kSessionExpiredErrorCode userInfo:nil]];
            weakSelf.ttErrorView.errorMsg.text = @"暂未登录";
            if(!fromCache) {
                [weakSelf tt_ShowTip:@"暂未登录"duration:2 tipTouchBlock:^{
                    [weakSelf calloutLoginIfNeed];
                }];
            }
        }
        
    } cache:fromCache];
}

- (void)loadNextPage {
    if (self.manager.isLoading || !TTNetworkConnected()) {
        return;
    }
    //////////////////TODO:  友盟统计
    wrapperTrackEvent(@"information", @"more_notify");
    
    [self tt_startUpdate];
    
    __weak ArticleNoticeView * weakSelf = self;
    [self.manager startLoadMoreNotificationsWithCount:ArticleNoticePageSize finishBlock:^(NSArray *notifications, BOOL hasMore, NSError *error) {
        
        [weakSelf.tableView finishPullUpWithSuccess:!error];
        [weakSelf tt_endUpdataData:NO error:error];
        
        if (!error) {
            weakSelf.messages = self.manager.notifications;
            weakSelf.tableView.hasMore = hasMore;
            [weakSelf.tableView reloadData];
        }
    } cache:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messages.count) {
        ArticleNotificationModel * noticeModel = [self.messages objectAtIndex:indexPath.row];
        return [ArticleNoticeViewCell heightForNoticeModel:noticeModel constrainedToWidth:[TTUIResponderHelper splitViewFrameForView:self].size.width];
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < self.messages.count) {
        ArticleNotificationModel * noticeModel = [self.messages objectAtIndex:indexPath.row];
        
        NSString * identifier = (noticeModel.pgcAccount || noticeModel.group) ? ArticlePGCNoticeCellIdentifier : ArticleNoticeCellIdentifier;
        ArticleNoticeViewCell * noticeCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if ([noticeCell isKindOfClass:[ArticlePGCNoticeViewCell class]]) {
            ((ArticlePGCNoticeViewCell *) noticeCell).delegate = self;
        }
        noticeCell.noticeModel = noticeModel;
        cell =  noticeCell;
        
    }
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"unknownCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unknownCell"];
        }
    }
    return cell;
}


/// scrollToComment ，是否滚动到最新评论
- (void)forwardNewsDetailWithNoticeModel:(ArticleNotificationModel *) noticeModel
                         scrollToComment:(BOOL) scrollToComment {
    [ArticleMomentHelper openGroupDetailViewFromNotificationModel:noticeModel showComment:scrollToComment];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ArticleNotificationModel * noticeModel = [self.messages objectAtIndex:indexPath.row];
    wrapperTrackEventWithCustomKeys(@"information", @"system_notification", nil, nil, nil);
    //这里优先处理Cell的 schema url 如果有url 走schema 没有的话 按类型跳转 --nick add 4.7
    NSString * linkURLString = noticeModel.openURL;
    if (linkURLString) {
        
        NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
        if ([linkURLString hasPrefix:TTLocalScheme] || [linkURLString hasPrefix:@"snssdk"]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }
    else {
        
        /// 这里只考虑点击cell时的跳转，点击头像和PGC详情区域的跳转都已经在cell里面处理过了
        if (noticeModel.type == ArticleNotificationTypeSubscribe) {
            ///  订阅了媒体账号，点击cell去用户主页
            ArticleMomentProfileViewController * viewController = [[ArticleMomentProfileViewController alloc] initWithUserModel:noticeModel.user];
            /// 点击头像
            [self.navigationController pushViewController:viewController animated:YES];
            //////////////////TODO:  友盟统计
            wrapperTrackEvent(@"information", @"click_avatar");
            return;
        }
        if (noticeModel.type == ArticleNotificationTypeReplyArticle || noticeModel.type == ArticleNotificationTypeHasNewReplies) {
            /// 评论了你的文章，点击进入文章详情页面,并且定位到最新评论， 有N个新评论
            [self forwardNewsDetailWithNoticeModel:noticeModel scrollToComment:YES];
            return;
        }
        if (noticeModel.type == ArticleNotificationTypeArticleApproved || noticeModel.type == ArticleNotificationTypeFavoriteArticle || noticeModel.type == ArticleNotificationTypeRepostArticle) {
            /// 文章通过审核，去文章详情页面
            [self forwardNewsDetailWithNoticeModel:noticeModel scrollToComment:NO];
            return;
        }
        if (noticeModel.type == ArticleNotificationTypeHasNewFans) {
            /// 有N个新粉丝,进入粉丝列表
            //////////////////TODO:  友盟统计
            wrapperTrackEvent(@"information", @"click_fans");
            TTRelationshipViewController * relationViewController = [[TTRelationshipViewController alloc] initWithAppearType:2 currentUser:[ArticleFriend accountUser]];
            [self.navigationController pushViewController:relationViewController animated:YES];
            return;
        }
    }
    
}

#pragma mark - ArticleDelegate
- (void)articlePGCNoticeViewActionFired:(ArticlePGCNoticeViewCell *) pgcNoticeCell {
    ArticleNotificationModel * noticeModel = pgcNoticeCell.noticeModel;
    
    //这里优先处理Cell的 schema url 如果有url 走schema 没有的话 按类型跳转 --nick add 4.7
    NSString * linkURLString = noticeModel.extraOpenURL;
    if (linkURLString) {
        
        NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
        if ([linkURLString hasPrefix:TTLocalScheme] || [linkURLString hasPrefix:@"snssdk"]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else {
        
        if (noticeModel.type == ArticleNotificationTypeReplyArticle || noticeModel.type == ArticleNotificationTypeHasNewReplies) {
            [self forwardNewsDetailWithNoticeModel:noticeModel scrollToComment:YES];
            return;
        }
        if (noticeModel.type == ArticleNotificationTypeArticleApproved || noticeModel.type == ArticleNotificationTypeFavoriteArticle || noticeModel.type == ArticleNotificationTypeRepostArticle) {
            [self forwardNewsDetailWithNoticeModel:noticeModel scrollToComment:NO];
            return;
        }
        if (noticeModel.type == ArticleNotificationTypeSubscribe) {
            ///  订阅了媒体账号，点击PGC去用户主页
            [ArticleMomentProfileViewController openWithMediaID:noticeModel.pgcAccount.mediaID enterSource:@"notification" itemID:nil];
            //////////////////TODO:  友盟统计

            wrapperTrackEvent(@"information", @"click_pgc");
        }
    }
}

- (void)goBack:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.tableViewFrame;
}

- (void)sectScrollToTopEnabled:(BOOL)enabled {
    self.tableView.scrollsToTop = enabled;
}

- (void)refreshData {
    [self refreshDataFromCache:YES];
    [self tt_endUpdataData];
    [self refreshDataFromCache:NO];
}

- (void)sessionExpiredAction {
    [self calloutLoginIfNeed];
}

#pragma mark -- Login

- (void)calloutLoginIfNeed {
    if (![TTAccountManager isLogin]) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"mine_message" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self refreshDataFromCache:NO];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"mine_message" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}

@end
