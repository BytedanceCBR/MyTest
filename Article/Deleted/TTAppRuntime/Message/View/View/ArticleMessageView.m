//
//  ArticleMessageView.m
//  Article
//
//  Created by SunJiangting on 14-5-25.
//
//

#import "ArticleMessageView.h"
#import "ArticleTableView.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "SSNavigationBar.h"

#import "ArticleMessageManager.h"
#import "ArticleMessageModel.h"
#import "ArticleMessageCell.h"

#import "ArticleMomentDetailViewController.h"
#import "ArticleBadgeManager.h"
#import "ArticleEmptyView.h"

#import "SSUserSettingManager.h"
#import "NetworkUtilities.h"
#import "ArticleListNotifyBarView.h"

#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"

#import "ArticleMomentCommentModel.h"
#import <TTAccountBusiness.h>
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"

#import "TTRoute.h"


const NSInteger ArticleMessagePageSize = 20;


@interface ArticleMessageView () <UITableViewDataSource, UITableViewDelegate, UIViewControllerErrorHandler> {
}

@property (nonatomic, strong) ArticleMessageManager *manager;
@property (nonatomic, strong) ArticleTableView *tableView;
@property (nonatomic, assign) TTArticleMessageType type;
@property (nonatomic, copy) NSArray *messages;

@end

@implementation ArticleMessageView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame type:(TTArticleMessageType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        // Initialization code
        self.manager = [ArticleMessageManager sharedManager];
        
        
        self.tableView = [[ArticleTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollsToTop = NO;
        [self addSubview:self.tableView];
        
        __weak typeof(self) wself = self;
        NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"正在努力加载";
        
        [self.tableView addPullDownWithInitText:@"下拉刷新"
                                       pullText:@"松开即可刷新"
                                    loadingText:loadingText
                                     noMoreText:@"暂无新数据"
                                       timeText:nil
                                    lastTimeKey:nil
                                  actionHandler:^{
                                      [wself reloadDataFromCache:NO];
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
        
        
        [self.tableView registerClass:[ArticleMessageCell class] forCellReuseIdentifier:ArticleMessageCellIdentifier];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
        [self reloadThemeUI];
        
        [self tt_startUpdate];
    }
    return self;
}

- (BOOL)tt_hasValidateData {
    return self.messages.count > 0;
}

- (void)refreshData {
    [self reloadDataFromCache:YES];
    [self tt_endUpdataData];
    [self reloadDataFromCache:NO];
}

- (void)sessionExpiredAction {
    [self calloutLoginIfNeed];
}

- (void)fontChanged:(NSNotification *) notification {
    [self.tableView reloadData];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)reloadDataFromCache:(BOOL)fromCache {
    __weak ArticleMessageView * weakSelf = self;
    
    [self tt_startUpdate];
    
    [self.manager  startRefreshMessagessWithCount:ArticleMessagePageSize finishBlock:^(NSArray *messages, BOOL hasMore, NSError *error) {
        if (fromCache) {
            if (self.type == TTArticleMessageComment) {
                self.messages = self.manager.commentMessages;
            }
            else if (self.type == TTArticleMessageDigg) {
                self.messages = self.manager.diggMessages;
            }
            weakSelf.tableView.hasMore = hasMore;
            [weakSelf.tableView reloadData];
        }
        else {
            if (!error) {
                self.messages = messages;
                weakSelf.tableView.hasMore = hasMore;
                if (weakSelf.badgeChangedHandler) {
                    weakSelf.badgeChangedHandler(weakSelf);
                }
                [weakSelf.tableView reloadData];
            }
        }
        
        [weakSelf.tableView finishPullDownWithSuccess:!error];
        if ([TTAccountManager isLogin]) {
            weakSelf.ttViewType = TTFullScreenErrorViewTypeEmpty;
            [weakSelf tt_endUpdataData:fromCache error:error];
        } else {
            weakSelf.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
            [weakSelf tt_endUpdataData:fromCache error:[NSError errorWithDomain:kCommonErrorDomain code:kSessionExpiredErrorCode userInfo:nil]];
            weakSelf.ttErrorView.errorMsg.text = NSLocalizedString(@"暂未登录", nil);
            if (!fromCache) {
                [weakSelf tt_ShowTip:NSLocalizedString(@"暂未登录", nil) duration:2 tipTouchBlock:^{
                    [weakSelf calloutLoginIfNeed];
                }];
            }
        }
        
    } type:self.type cache:fromCache];
}

- (void)loadNextPage {
    
    //////////////////TODO:  友盟统计
    wrapperTrackEvent(@"information", @"more_message");
    
    [self tt_startUpdate];
    
    __weak ArticleMessageView * weakSelf = self;
    [self.manager  startLoadMoreMessagessWithCount:ArticleMessagePageSize finishBlock:^(NSArray *messages, BOOL hasMore, NSError *error) {
        if(!error) {
            if (self.type == TTArticleMessageComment) {
                self.messages = self.manager.commentMessages;
            }
            else if (self.type == TTArticleMessageDigg) {
                self.messages = self.manager.diggMessages;
            }
            weakSelf.tableView.hasMore = hasMore;
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView finishPullUpWithSuccess:!error];
        [weakSelf tt_endUpdataData:NO error:error];
    } type:self.type cache:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messages.count) {
        ArticleMessageModel * messageModel = [self.messages objectAtIndex:indexPath.row];
        return [ArticleMessageCell heightForMessageModel:messageModel constrainedToWidth:[TTUIResponderHelper splitViewFrameForView:self].size.width];
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messages.count) {
        ArticleMessageModel * messageModel = [self.messages objectAtIndex:indexPath.row];
        ArticleMessageCell * messageCell = [tableView dequeueReusableCellWithIdentifier:ArticleMessageCellIdentifier];
        messageCell.messageModel = messageModel;
        return messageCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ArticleMessageModel * messageModel = [self.messages objectAtIndex:indexPath.row];
    
    //这里优先处理Cell的 schema url 如果有url 走schema 没有的话 按类型跳转 --nick add 4.7
    NSString * linkURLString = messageModel.openURL;
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
        //        NSString *newCommentTrackerLabel = nil;
        
        if (!messageModel.momentID) {
            return;
        }
        NSString * momentID = [NSString stringWithFormat:@"%@", messageModel.momentID];
        ArticleMomentModel * model = [[ArticleMomentModel alloc] initWithDictionary:@{@"id":momentID}];
        
        
        ArticleMomentDetailViewController * viewController = [[ArticleMomentDetailViewController alloc] initWithMomentModel:model momentManager:nil sourceType:ArticleMomentSourceTypeMessage];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:2];
        if (messageModel.user) {
            [dict setValue:messageModel.user forKey:@"user"];
        }
        if (!isEmptyString(messageModel.commentID)) {
            [dict setValue:messageModel.commentID forKey:@"id"];
        }
        if (dict.count == 2) {
            ArticleMomentCommentModel * replyCommentModel = [[ArticleMomentCommentModel alloc] initWithDictionary:dict];
            viewController.replyMomentCommentModel = replyCommentModel;
        }
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    //////////////////TODO:  友盟统计
    NSString * label = nil;
    //    101-110 动态评论消息
    //    111-120 动态顶消息
    if (isEmptyString(messageModel.openURL)) {
        [dict setValue:@"3" forKey:@"ext_value"];
    } else {
        [dict setValue:@"2" forKey:@"ext_value"]; //if 话题/帖子
    }
    if (messageModel.type > 100 && messageModel.type <= 110) {
        [dict setValue:@"1" forKey:@"source"];
        // 评论的type都小于110
        if (messageModel.type == 107) {
            label = @"click_repost";
        } else {
            label = @"click_comment";
        }
    }
    
    if (messageModel.type > 110 && messageModel.type <= 120) {
        [dict setValue:@"2" forKey:@"source"];
        
        if (messageModel.type == 115) {
            label = @"click_digg_reply";
        } else {
            label = @"click_digg";
            
        }
    }
    if (label.length > 0) {
        wrapperTrackEvent(@"information", label);
    }
    wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_message", messageModel.commentID, nil, dict);
}

- (void)goBack:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGRect)tableViewFrame {
    return self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.tableViewFrame;
}

- (void)sectScrollToTopEnabled:(BOOL)enabled {
    self.tableView.scrollsToTop = enabled;
}

#pragma mark -- Login

- (void)calloutLoginIfNeed {
    if (![TTAccountManager isLogin]) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"mine_message" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self reloadDataFromCache:NO];
                }
            }
            else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"mine_message" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}

@end
