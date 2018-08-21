//
//  TTIMChatViewController.m
//  EyeU
//
//  Created by matrixzk on 10/18/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatViewController.h"

#import "TTIMCellHelper.h"
#import "TTIMMessageCell.h"
#import "TTIMSystemMessageCell.h"
#import "TTIMMessageInputViewController.h"
#import "TTIMChatViewController+MessageHandler.h"
#import "TTIMDateFormatter.h"
#import "TTIMChatViewModel.h"
#import "TTIMMessage.h"
#import "TTIMSDKService.h"
#import "TTIMUtils.h"
#import "SSActivityView.h"
#import "TTActivity.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"
#import "TTUserServices.h"
#import "TTUserData.h"
#import "ArticleMomentProfileViewController.h"
#import "TTProfileShareService.h"
#import "UIMenuController+Extension.h"
#import "TTPLManager.h"
#import "TTActivityShareManager.h"
#import "TTBlockManager.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "NetworkUtilities.h"
#import "TTIMChatRemindView.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTIconLabel+VerifyIcon.h"
#import "SSWebViewController.h"

@interface TTIMRefreshView : UIView
@property (nonatomic, strong) SSThemedImageView *loadingImgView;
@property (nonatomic, assign) BOOL isAnimating;

- (void)beginRefreshing;
- (void)endRefreshing;
- (BOOL)isRefreshing;
@end

@implementation TTIMRefreshView
{
//    UIActivityIndicatorView *_loadingView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _loadingImgView = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"sendloading"]]; // 18*18
        [self addSubview:_loadingImgView];
        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _loadingImgView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
}

- (void)beginRefreshing
{
    if (!_isAnimating) {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
        rotationAnimation.duration = 1.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 10000.0f;
        [_loadingImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        _isAnimating = YES;
    }
    self.hidden = NO;
}

- (void)endRefreshing
{
    [_loadingImgView.layer removeAllAnimations];
    _loadingImgView.transform = CGAffineTransformIdentity;
    
    _isAnimating = NO;
    self.hidden = YES;
}

- (BOOL)isRefreshing
{
    return _isAnimating && !self.hidden;
}

@end


#pragma mark - TTIMChatViewController

@interface TTIMChatViewController () <UITableViewDelegate, UITableViewDataSource, TTIMMessageInputViewDelegate, SSActivityViewDelegate, TTBlockManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<TTIMMessage *> *messagesArray;
@property (nonatomic, strong) TTIMMessageInputViewController *messageInputVC;
@property (nonatomic, strong) TTIMRefreshView *refreshView;
@property (nonatomic, strong) TTIMChatViewModel *chatViewModel;
@property (nonatomic, copy)   NSString *sessionId;
@property (nonatomic, strong) TTUserData *userData;
@property (nonatomic, assign) BOOL noMoreHistoryMsgs;
@property (nonatomic, assign) BOOL firstLoadHistoryFinished;
@property (nonatomic, assign) BOOL hadFetchedHistoryMsgs;

@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@property (nonatomic, strong) TTActivityShareManager *activityActionManager;
@property (nonatomic, strong) TTBlockManager *blockUserManager;

/** 标题 */
@property (nonatomic, strong) TTIconLabel *titleView;
@property (nonatomic, strong) TTIMChatRemindView *remindView;

@end

static CGFloat kBaseTopInsetOfTableView = 64;
static CGFloat kRefreshViewHeight = 30;

@implementation TTIMChatViewController

- (void)dealloc
{
    PLLOGD(@">>>>>>> dealloc : %s", __func__);
    [[TTIMSDKService sharedInstance] unRegisterSession:_sessionId listener:_chatViewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    wrapperTrackEvent(@"private_letter", @"return");
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        _sessionId = [params tt_stringValueForKey:@"uid"];
        _draft = [params tt_stringValueForKey:@"draft"];
        _willExitBlock = [params tt_objectForKey:@"exit_block"];
        NSString *from = [params tt_stringValueForKey:@"from"];
        if (!isEmptyString(_sessionId)) {
            _userData = [TTUserData objectForPrimaryKey:_sessionId];
            if (!_userData) {
                [TTUserServices fetchUserDataWithUserId:_sessionId completion:^(TTUserData * _Nullable userData, BOOL success) {
                    if (success) {
                        _userData = userData;
                        _titleView.text = userData.name;
                        [_titleView removeAllIcons];
                        if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userData.userAuthInfo]) {
                            [_titleView addIconWithVerifyInfo:userData.userAuthInfo];
                        }
                        [_titleView refreshIconView];
                    }
                }];
            }
        }
        if (!isEmptyString(from)) {
            wrapperTrackEvent(@"private_letter", from);
            if ([from isEqualToString:@"mine_msg_enter"]) {
                [[TTPLManager sharedManager] setHasShowTip];
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStatusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    [self setupNavgationBar];
    [self setupConversationTableView];
    
    _remindView = [[TTIMChatRemindView alloc] init];
    _remindView.backgroundColorThemeKey = kColorBackground13;
    [_remindView addTarget:self action:@selector(scrollToBottom) forControlEvents:UIControlEventTouchUpInside];
    _remindView.hidden = YES;
    _remindView.layer.cornerRadius = _remindView.height / 2;
    [self.view addSubview:_remindView];
    
    self.messagesArray = [NSMutableArray array];
    
    self.chatViewModel = [[TTIMChatViewModel alloc] initWithSessionId:self.sessionId messageArray:self.messagesArray];
    [[TTIMSDKService sharedInstance] registerSession:self.sessionId listener:self.chatViewModel];
    
    WeakSelf;
    self.chatViewModel.showNewMessagesBlock = ^(NSArray<TTIMMessage *> *newMessages) {
        StrongSelf;
        [self showMessages:newMessages];
    };
    
    [self.chatViewModel fetchHistoryMessagesWithFinishHandler:^(NSArray<TTIMMessage *> *historyMsgs, BOOL hasMore) {
        
        StrongSelf;
        
        // 从联系人列表直接发视频或图片消息进入聊天列表时，确保加载历史消息和新消息的入库在UI上互斥
        self.hadFetchedHistoryMsgs = YES;
        
        if (historyMsgs.count == 0) {
            [self sendWelcomeMessageIfNeeded];
            return ;
        }
        
        [self.messagesArray insertObjects:historyMsgs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, historyMsgs.count)]];
        
        [self.tableView reloadData];
        [self scrollTableViewContentToBottomAnimated:NO];
        
        if (hasMore) {
            self.tableView.contentInset = UIEdgeInsetsMake(kBaseTopInsetOfTableView + kRefreshViewHeight, 0, 0, 0);
        } else {
            self.noMoreHistoryMsgs = YES;
        }
        
        self.firstLoadHistoryFinished = YES;
    }];
    
    self.messageInputVC = [TTIMMessageInputViewController setupMessageInputViewWithParentViewController:self associateTableView:self.tableView delegate:self];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)dismissMessageInputView
{
    [self.messageInputVC dismissMessageInputView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ttHideNavigationBar = NO;
    
    // TODO: 多次进入同一个会话界面，发消息时消息发送状态KVO只对最后一个消息model生效，导致UI不同步，比如前者一直处于发送中状态，
    // 待优化：同一个会话只进一次，将要进入的和已存在的如果相同，则直接退回，若不同，则先退再进；
    [self.tableView reloadData];
    
    wrapperTrackEvent(@"private_letter", @"enter");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.draft.length > 0) {
        [self.messageInputVC callOutMsgInputViewWithText:self.draft];
        self.draft = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self dismissMessageInputView];
    [UIMenuController dismissWithAnimated:NO];
    
    BOOL shouldExitAndRemoveChat = NO;
    if (self.userData.isBlocking.boolValue) {
        shouldExitAndRemoveChat = YES;
    }
    
    // 如果把该逻辑放在 dealloc 中，会导致 chatCenterVC 的数据源的更新晚于 chatCenterVC 界面的刷新，导致看不到草稿
    if (self.willExitBlock) {
        self.willExitBlock(self.sessionId, [self.messageInputVC currentInputtingText], shouldExitAndRemoveChat);
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    kBaseTopInsetOfTableView = [UIApplication sharedApplication].statusBarFrame.size.height + 44.f;
    self.tableView.contentInset = UIEdgeInsetsMake(kBaseTopInsetOfTableView, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    /*
    [self.messagesArray enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        message.tempLocalSelectedImage = nil;
        message.thumbImage = nil;
    }];
     */
}

- (void)receiveStatusBarOrientationChange:(NSNotification *)notice {
//    [_messageInputVC dismissMessageInputView];
    [_messageInputVC layoutSubview];
}

- (NSArray<TTIMMessage *> *)messages
{
    return self.messagesArray;
}

- (void)setupNavgationBar {
    _titleView = [[TTIconLabel alloc] init];
    _titleView.font = [UIFont systemFontOfSize:17];
    _titleView.textColorThemeKey = kColorText1;
    _titleView.text = _userData.name ? : _sessionId;
    _titleView.textAlignment = NSTextAlignmentCenter;
    [_titleView removeAllIcons];
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:_userData.userAuthInfo]) {
        [_titleView addIconWithVerifyInfo:_userData.userAuthInfo];
    }
    [_titleView refreshIconView];
    
    self.navigationItem.titleView = _titleView;
    
//#warning 数据有问题
    SSThemedButton *moreButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [moreButton sizeToFit];
    moreButton.imageName = @"new_more_titlebar";
    [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
}

#pragma mark Theme

- (void)themeChanged:(NSNotification *)notification {
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)moreButtonClick:(id)sender {
    [self.messageInputVC dismissMessageInputView];
    
    [_activityActionManager clearCondition];
    
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
//    TTActivity *pgc = [TTActivity activityOfPGCWithAvatarUrl:self.userData.avatarUrl showName:@"查看主页"];
//    [activityItems addObject:pgc];
    TTActivity *report = [TTActivity activityOfReport];
    [activityItems addObject:report];
    if ([[_userData isBlocking] boolValue]) {
        TTActivity *unblockUser = [TTActivity activityOfUnBlockUser];
        [activityItems addObject:unblockUser];
    } else {
        TTActivity *blockUser = [TTActivity activityOfBlockUser];
        [activityItems addObject:blockUser];
    }
    
    _phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor:self]];
    wrapperTrackEvent(@"private_letter", @"more_menu");
}

- (void)setupConversationTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - [TTIMMessageInputViewController heightOfMsgInputView])];
    self.tableView.scrollsToTop = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.tableView.contentInset = UIEdgeInsetsMake(kBaseTopInsetOfTableView, 0, 0, 0);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.tableView registerClass:[TTIMMessageCell class]
           forCellReuseIdentifier:[TTIMMessageCell TTIMIncomingTextCellReuseIdentifier]];
    [self.tableView registerClass:[TTIMMessageCell class]
           forCellReuseIdentifier:[TTIMMessageCell TTIMOutgoingTextCellReuseIdentifier]];
    [self.tableView registerClass:[TTIMMessageCell class]
           forCellReuseIdentifier:[TTIMMessageCell TTIMIncomingMediaCellReuseIdentifier]];
    [self.tableView registerClass:[TTIMMessageCell class]
           forCellReuseIdentifier:[TTIMMessageCell TTIMOutgoingMediaCellReuseIdentifier]];
    [self.tableView registerClass:[TTIMSystemMessageCell class]
           forCellReuseIdentifier:[TTIMSystemMessageCell TTIMSystemMsgCellReuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    _refreshView = [[TTIMRefreshView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight, CGRectGetWidth(self.tableView.frame), kRefreshViewHeight)];
    [self.tableView addSubview:_refreshView];
}

#pragma mark - 私信空白提示消息
- (void)sendWelcomeMessageIfNeeded
{
    if (self.messagesArray.count > 0) {
        return;
    }
    NSString *promptMessageText = [TTIMMessage promptTextOfWelcomeMessage];
    [TTIMMessage sendPromptMessageWithText:promptMessageText toUser:self.sessionId];
}

#pragma mark - UITapGesture
- (void)viewDidTap:(UITapGestureRecognizer *)sender
{
    [UIMenuController dismissWithAnimated:YES];
    [self dismissMessageInputView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    PLLOGD(@">>>>> offset: %@", @(scrollView.contentOffset.y));
    
    if (scrollView.contentOffset.y <= -(kBaseTopInsetOfTableView + kRefreshViewHeight) &&
        !self.refreshView.isRefreshing &&
        scrollView.contentSize.height > 0 && self.firstLoadHistoryFinished && /* 确保第一次进来时不load */
        !self.noMoreHistoryMsgs ) {
        
        [self.refreshView beginRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WeakSelf;
            [self.chatViewModel fetchHistoryMessagesWithFinishHandler:^(NSArray<TTIMMessage *> *historyMsgs, BOOL hasMore) {
                
                StrongSelf;
                if (historyMsgs.count > 0) {
                    [self.messagesArray insertObjects:historyMsgs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, historyMsgs.count)]];
                    
                    [self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:historyMsgs.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                
                if (!hasMore) {
                    self.noMoreHistoryMsgs = YES;
                    self.tableView.contentInset = UIEdgeInsetsMake(kBaseTopInsetOfTableView, 0, 0, 0);
                }
                
                [self.refreshView endRefreshing];
            }];
            wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"loadmore_msg"});
        });
    }
}

- (NSString *)formattedSendDateOfMsgWithIndex:(NSInteger)index
{
    if (index < 0) { return nil; }
    TTIMMessage *lastMsg = index > 0 ? self.messagesArray[index - 1] : nil;
    return [TTIMDateFormatter showFormattedDateIfNeededWithMessage:self.messagesArray[index]
                                                           lastMsg:lastMsg];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTIMMessage *message = self.messagesArray[indexPath.row];
    CGFloat cellHeight = [TTIMCellHelper cellHeightWithMessage:message];
    if ([self formattedSendDateOfMsgWithIndex:indexPath.row].length > 0) {
        cellHeight += kTopPaddingOfCellTopLabel() + kHeightOfCellTopLabel() + kBottomPaddingOfCellTopLabel();
    }
    if (indexPath.row == self.messagesArray.count - 1) {
        cellHeight += TTIMPadding(10);
    }
    return cellHeight + kBottomPaddingOfCell();
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTIMMessage *message = self.messagesArray[indexPath.row];
    if (!message.shouldShowCellAnimation) { return; }
    message.shouldShowCellAnimation = NO;
    
    CGRect originFrame = cell.contentView.frame;
    cell.contentView.frame = (CGRect){0, CGRectGetHeight(originFrame)/3, originFrame.size};
    cell.contentView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.contentView.frame = originFrame;
        cell.contentView.alpha = 1;
    } completion:nil];
    
    if (indexPath.row + 1 == self.messagesArray.count) {
        self.remindView.hidden = YES;
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTIMMessage *message = self.messagesArray[indexPath.row];
    message.formattedSendDate = [self formattedSendDateOfMsgWithIndex:indexPath.row];
    
    UITableViewCell *cell;
    if (TTIMMessageTypeSystem == message.messageType) {
        TTIMSystemMessageCell *systemMsgCell = [tableView dequeueReusableCellWithIdentifier:[TTIMSystemMessageCell TTIMSystemMsgCellReuseIdentifier] forIndexPath:indexPath];
        [systemMsgCell setupCellWithMessage:message];
        cell = systemMsgCell;
    } else {
        NSString *cellIdentifer;
        if (TTIMMessageTypeText == message.messageType) {
            cellIdentifer = [message isSelf] ? [TTIMMessageCell TTIMOutgoingTextCellReuseIdentifier] : [TTIMMessageCell TTIMIncomingTextCellReuseIdentifier];
        } else {
            cellIdentifer = [message isSelf] ? [TTIMMessageCell TTIMOutgoingMediaCellReuseIdentifier] : [TTIMMessageCell TTIMIncomingMediaCellReuseIdentifier];
        }
        
        TTIMMessageCell *msgCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
        msgCell.delegate = self;
        [msgCell setupCellWithMessage:message];
        cell = msgCell;
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self.messageInputVC dismissMessageInputView];
    }
}

#pragma mark - Manager lazy init
- (TTActivityShareManager *)activityActionManager
{
    if (!_activityActionManager) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    return _activityActionManager;
}

- (TTBlockManager *)blockUserManager
{
    if (!_blockUserManager) {
        _blockUserManager = [[TTBlockManager alloc] init];
        _blockUserManager.delegate = self;
    }
    return _blockUserManager;
}

#pragma mark - Show Messages

- (void)showMessages:(NSArray<TTIMMessage *> *)msgsArray
{
    if (msgsArray.count == 0 || !self.hadFetchedHistoryMsgs) { return; }
    
    BOOL shouldNotScrollToBottom = YES;
    __block BOOL hasNewMessage = NO;

    if (msgsArray.count == 1 && [[msgsArray firstObject] isSelf]) {
        shouldNotScrollToBottom = NO;
    } else {
        shouldNotScrollToBottom = (self.tableView.contentOffset.y < self.tableView.contentSize.height - self.tableView.height - 10);
    }
    
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] initWithCapacity:msgsArray.count];
    [msgsArray enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPathArray addObject:[NSIndexPath indexPathForRow:(self.messagesArray.count + idx) inSection:0]];
        if (!hasNewMessage && ![obj isSelf]) {
            hasNewMessage = YES;
        }
    }];
    [self.messagesArray addObjectsFromArray:msgsArray];
    [self.tableView insertRowsAtIndexPaths:indexPathArray
                          withRowAnimation:UITableViewRowAnimationNone];
    
    // 防止crash
    if (shouldNotScrollToBottom) {
        if (hasNewMessage) {
            self.remindView.centerX = self.view.width / 2;
            self.remindView.bottom = self.view.height - 60;
            self.remindView.hidden = NO;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollTableViewContentToBottomAnimated:YES];
        });
    }
}

// 动画删除消息，同时在数据库中标记该消息为删除
- (void)deleteMessage:(TTIMMessage *)message
{
    NSUInteger index = [[self messages] indexOfObject:message];
    [self.messagesArray removeObject:message];
    [[TTIMSDKService sharedInstance] deleteMessage:message];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationTop];
}

- (void)scrollToBottom {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollTableViewContentToBottomAnimated:YES];
    });
}

- (void)scrollTableViewContentToBottomAnimated:(BOOL)animated
{
    if (self.messagesArray.count == 0) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.messagesArray.count - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - SSActivityViewDelegate
- (void)activityView:(SSActivityView *)view willCompleteByItemType:(TTActivityType)itemType {
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeNone) {
            wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu" : @"cancel"});
        }
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeReport) {
            wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu":@"report"});
            self.actionSheetController = [[TTActionSheetController alloc] init];
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
            [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
                if (parameters[@"report"]) {
                    // 举报用户时，需要上报最近的10条对话
                    NSString *reportMessage = [self searchedRecentReportMessageString];
                    [self reportUserWithParameters:parameters message:reportMessage];
                } else {
                    wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"cancel"});
                }
            }];
//        } else if (itemType == TTActivityTypePGC) {
//            NSString *url = [NSString stringWithFormat:@"sslocal://profile?uid=%@", self.userData.userId];
//            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
//            wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu" : @"profile"});
        } else if (itemType == TTActivityTypeBlockUser) {
            wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu":@"block"});
            [self block:self.sessionId isBlock:YES];
        } else if (itemType == TTActivityTypeUnBlockUser) {
            [self block:self.sessionId isBlock:NO];
        }
        self.phoneShareView = nil;
    }
}

#pragma mark - TTIMMessageCellEventDelegate
- (void)ttimMessageCellHandleReportEvent:(TTIMMessage *)message {
    // 长按对话举报
    wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"pop_menu":@"report"});
    // 需要当前对话气泡的内容
    NSString *reportMessage = message.msgText;
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            [self reportMessageWithParameters:parameters message:reportMessage];
        } else {
            wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"cancel"});
        }
    }];
}

- (void)ttimMessageCellHandleBlockEvent:(TTIMMessage *)message {
    // 长按对话拉黑
    wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"pop_menu":@"block"});
    [self block:self.sessionId isBlock:YES];
}

- (void)ttimMessageCellHandleLinkEvent:(TTIMMessage *)message URL:(NSURL *)URL {
    // 点击超链接
    NSString *URLString = URL.absoluteString;
    if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
        ssOpenWebView(URL, @"", topController.navigationController, NO, nil);
    }
}

#pragma mark - 举报
// 举报用户
- (void)reportUserWithParameters:(NSDictionary *)parameters message:(NSString *)message {
    NSString *reportType = [parameters valueForKey:@"report"];
    NSString *userInputText = [parameters valueForKey:@"criticism"];
    NSString *userID = self.userData.userId;
    if (!isEmptyString(userInputText)) {
        wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"publish"});
    } else {
        wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"done"});
    }
    TTReportUserModel *model = [[TTReportUserModel alloc] init];
    model.userID = userID;
    [[TTReportManager shareInstance] startReportUserWithType:reportType inputText:userInputText message:message source:@(TTReportSourcePrivateMessageUser).stringValue userModel:model animated:YES];
}

// 举报对话气泡
- (void)reportMessageWithParameters:(NSDictionary *)parameters message:(NSString *)message {
    NSString *reportType = [parameters valueForKey:@"report"];
    NSString *userInputText = [parameters valueForKey:@"criticism"];
    NSString *userID = self.userData.userId;
    if (!isEmptyString(userInputText)) {
        wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"publish"});
    } else {
        wrapperTrackEventWithCustomKeys(@"private_letter", @"pop_menu", nil, nil, @{@"report":@"done"});
    }
    TTReportUserModel *model = [[TTReportUserModel alloc] init];
    model.userID = userID;
    [[TTReportManager shareInstance] startReportUserWithType:reportType inputText:userInputText message:message source:@(TTReportSourcePrivateMessage).stringValue userModel:model animated:YES];
}

// 搜索最近的10条对话内容并拼接
- (NSString *)searchedRecentReportMessageString {
    const NSUInteger kTTIMReportMessageMaxCount = 10;
    NSMutableArray<NSString *> *reversedMessageArray = [NSMutableArray arrayWithCapacity:kTTIMReportMessageMaxCount];
    [self.messagesArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TTIMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (reversedMessageArray.count >= kTTIMReportMessageMaxCount) {
            *stop = YES;
            return;
        }
        // 仅过滤文本消息且为对方发送的消息
        if (![message isSelf] && message.messageType == TTIMMessageTypeText) {
            NSString *text = message.msgText;
            [reversedMessageArray addObject:text];
        }
    }];
    
    NSArray *reportMessageArray = [reversedMessageArray reverseObjectEnumerator].allObjects;
    NSString *reportMessage = [reportMessageArray componentsJoinedByString:@"\\n"];
    
    return reportMessage;
}

#pragma mark - 拉黑/取消拉黑
- (void)block:(NSString *)userID isBlock:(BOOL)isBlock {
    if (userID && [userID isKindOfClass:[NSNumber class]]) {
        userID = [((NSNumber *)userID) stringValue];
    }
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        if (!isBlock) {
            [self.blockUserManager unblockUser:userID];
        } else {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息，同时删除该对话" preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu":@"block_cancel"});
            }];
            [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                wrapperTrackEventWithCustomKeys(@"private_letter", @"more_menu", nil, nil, @{@"more_menu":@"block_yes"});
                
                [self.blockUserManager blockUser:userID];
            }];
            [alert showFrom:self animated:YES];
        }
    }
}

#pragma mark - TTBlockManagerDelegate
- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip {
    if (error) {
        if (isEmptyString(errorTip)) {
            errorTip = @"操作失败，请重试";
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errorTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    _userData.isBlocking = @(YES);
    [_userData save];
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拉黑成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    // 现在拉黑后，会直接返回消息中心页，并删除会话
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip {
    if (error) {
        if (isEmptyString(errorTip)) {
            errorTip = @"操作失败，请重试";
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:errorTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    _userData.isBlocking = @(NO);
    [_userData save];
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已解除黑名单" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

@end
