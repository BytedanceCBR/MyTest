//
//  TTIMChatCenterViewController.m
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatCenterViewController.h"

#import "TTAlphaThemedButton.h"
#import "TTIMChatEmptyView.h"
#import "TTIMCellHelper.h"
#import "TTIMCenterChatCell.h"
#import "TTIMChatCenterViewModel.h"
#import "TTIMSDKService.h"
#import "TTIMDateFormatter.h"
#import "TTIMMessage.h"
#import "TTIMUtils.h"
#import "TTIMMessageSender.h"
#import "TTReachability.h"
#import "NetworkUtilities.h"
#import "TTIMCenterMessageCell.h"
#import "TTPLManager.h"
#import "UIViewController+NavigationBarStyle.h"

#import "TTRoute.h"

static NSString * const kTTIMCenterChatCellReuseIdentifier = @"kTTIMCenterChatCellReuseIdentifier";
static NSString * const kTTIMCenterMessageCellReuseIdentifier = @"kTTIMCenterMessageCellReuseIdentifier";

@interface TTIMChatCenterViewController () <UITableViewDelegate, UITableViewDataSource, TTIMChatCenterCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<TTIMChatCenterModel *> *sessionsArray;
@property (nonatomic, strong) TTIMChatCenterViewModel *chatCenterViewModel;
@property (nonatomic, assign) BOOL shouldRefreshList;
@property (nonatomic, strong) TTIMChatEmptyView *emptyView;

@end

@implementation TTIMChatCenterViewController

- (void)dealloc
{
//    [[TTIMSDKService sharedInstance] unRegisterSession:@"" listener:self.chatCenterViewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.shouldRefreshList = YES;
    
    [self setupNavigationBarItems];
    [self setupConversationTableView];
    
    self.chatCenterViewModel = [[TTPLManager sharedManager] chatCenterViewModel];
    [self refreshWithNewSessionsArray:[self.chatCenterViewModel.sessionsDict allValues]];
//    self.chatCenterViewModel = [TTIMChatCenterViewModel new];
//    [[TTIMSDKService sharedInstance] registerSession:@"" listener:self.chatCenterViewModel];
    WeakSelf;
    self.chatCenterViewModel.didAddNewMessageHandler = ^(NSDictionary *sessions) {
        StrongSelf;
        [self refreshWithNewSessionsArray:[sessions.allValues copy]];
    };
//    [self fetchChatCenterDataSource];
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ttHideNavigationBar = NO;
    
    self.shouldRefreshList = YES;
    
    [self refreshWithNewSessionsArray:self.sessionsArray];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.shouldRefreshList = NO;
}

#pragma mark - Data

- (void)fetchChatCenterDataSource {
    WeakSelf;
    [self.chatCenterViewModel fetchChatCenterSessionsWithResultHandler:^(NSDictionary *sessions) {
        StrongSelf;
        [self refreshWithNewSessionsArray:[sessions.allValues copy]];
    }];
}

- (void)refreshWithNewSessionsArray:(NSArray *)sessions
{
    self.sessionsArray = [sessions sortedArrayUsingComparator:^NSComparisonResult(TTIMChatCenterModel * _Nonnull model1, TTIMChatCenterModel * _Nonnull model2) {
        return (NSComparisonResult)(model2.latestMsg.createTime - model1.latestMsg.createTime);
    }];
    
    [self showEmptyViewIfNeeded];
    
    if (self.shouldRefreshList) {
        [self.tableView reloadData];
    }
}

// 如果shouldRemoveSession为YES，则会同时标记清除IMSDK数据库的session
- (void)deleteChatWithModel:(TTIMChatCenterModel *)chatCenterModel shouldRemoveSession:(BOOL)shouldRemoveSession
{
    if (isEmptyString(chatCenterModel.sessionId)) {
        return;
    }
    
    NSUInteger index = [self.sessionsArray indexOfObject:chatCenterModel];
    
    [self.tableView beginUpdates];
    NSMutableArray *dataSource = [self.sessionsArray mutableCopy];
    [dataSource removeObject:chatCenterModel];
    self.sessionsArray = [dataSource copy];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [self showEmptyViewIfNeeded];
    
    if (shouldRemoveSession) {
        [self.chatCenterViewModel removeChatWithSessionId:chatCenterModel.sessionId];
    } else {
        [self.chatCenterViewModel.sessionsDict removeObjectForKey:chatCenterModel.sessionId];
    }
    [[TTPLManager sharedManager] refreshUnreadNumber];
}

- (TTIMChatCenterModel *)chatCenterModelWithSessionId:(NSString *)sessionId
{
    __block TTIMChatCenterModel *chatCenterModel;
    [self.sessionsArray enumerateObjectsUsingBlock:^(TTIMChatCenterModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.sessionId isEqualToString:sessionId]) {
            chatCenterModel = model;
            *stop = YES;
        }
    }];
    
    return chatCenterModel;
}

- (void)handleWillExitChatVCWithSessionId:(NSString *)sessionId draft:(NSString *)draft shouldRemoveChat:(BOOL)shouldRemoveChat
{
    TTIMChatCenterModel *chatCenterModel = [self chatCenterModelWithSessionId:sessionId];
    if (!chatCenterModel) {
        return;
    }
    
    chatCenterModel.unreadCount = 0;
    chatCenterModel.draft = draft.length > 0 ? draft : nil;
    
    [[TTIMSDKService sharedInstance] markAllReaded:sessionId];
    
    if (shouldRemoveChat) {
        // 删除返回前的会话，但不真正清除IDSDK数据库中的session
        [self deleteChatWithModel:chatCenterModel shouldRemoveSession:NO];
        return;
    }
    
    [[TTPLManager sharedManager] refreshUnreadNumber];
    [[TTPLManager sharedManager] setDraft:draft withSessionId:sessionId];
}


#pragma mark - Notification

- (void)handleUserLoginNotification:(NSNotification *)notification
{
    [self fetchChatCenterDataSource];
    [self.tableView reloadData];
}

- (void)handleUserLogoutNotification:(NSNotification *)notification
{
    [self refreshWithNewSessionsArray:nil];
    [self.tableView reloadData];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    TTIMChatCenterModel *model = self.sessionsArray[indexPath.row];
    [dic setValue:model.draft forKey:@"draft"];
    [dic setValue:^(NSString *sessionId, NSString *draft, BOOL shouldRemoveChat) {
        [self handleWillExitChatVCWithSessionId:sessionId draft:draft shouldRemoveChat:shouldRemoveChat];
    } forKey:@"exit_block"];
    [dic setValue:model.sessionId forKey:@"uid"];
    [dic setValue:@"mine_msg_enter" forKey:@"from"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://private_letter"] userInfo:TTRouteUserInfoWithDict(dic)];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4Highlighted];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SSCommonLogic isIMServerEnable] ? self.sessionsArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTIMCenterChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTIMCenterChatCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setupCellWithModel:self.sessionsArray[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.sessionsArray.count) {
        TTIMChatCenterModel *chatCenterModel = self.sessionsArray[indexPath.row];
        [self deleteChatWithModel:chatCenterModel shouldRemoveSession:YES];
    }
}

#pragma mark - Navigation Bar Items

- (void)setupNavigationBarItems
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = @"私信";
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - UI

- (void)setupConversationTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.scrollsToTop = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = TTIMPadding(70);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [SSThemedView new];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.tableView registerClass:[TTIMCenterChatCell class]
           forCellReuseIdentifier:kTTIMCenterChatCellReuseIdentifier];
    [self.tableView registerClass:[TTIMCenterMessageCell class] forCellReuseIdentifier:kTTIMCenterMessageCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
}

#pragma mark - TTIMChatCenterViewController (TTIMChatCenterCellDelegate)

- (void)ttimChatCenterDeleteChat:(TTIMChatCenterModel *)chatCenterModel
{
    
}

- (void)ttimChatCenterStickChat:(TTIMChatCenterModel *)chatCenterModel
{
    
}

#pragma mark - 私信空白页

- (void)showEmptyViewIfNeeded
{
    if (self.sessionsArray.count == 0) {
        self.emptyView.hidden = NO;
    } else {
        self.emptyView.hidden = YES;
    }
}

- (TTIMChatEmptyView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[TTIMChatEmptyView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64)];
        _emptyView.imageView.imageName = @"im_empty_icon";
        _emptyView.label.text = @"暂无消息";
        [_emptyView.label sizeToFit];
        [self.view insertSubview:_emptyView aboveSubview:self.tableView];
    }
    return _emptyView;
}

@end
