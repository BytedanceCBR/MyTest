//
//  FHMessageViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageViewModel.h"
#import "TTRoute.h"
#import "TTHttpTask.h"
#import "FHMessageCell.h"
#import "FHMessageAPI.h"
#import "FHUnreadMsgModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHMessageViewController.h"
#import "FHConversationDataCombiner.h"
#import "IMChatStateObserver.h"
#import "TTURLUtils.h"
#import <libextobjc/extobjc.h>
#import "FHUserTracker.h"
#import "TTAccount.h"
#import "FHMessageNotificationManager.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "FHMessageNotificationTipsManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ios_house_im/IMManager.h>

#define kCellId @"FHMessageCell_id"

@interface DeleteAlertDelegate : NSObject <UIAlertViewDelegate>
@property(nonatomic, strong) IMConversation *conv;
@property(nonatomic, weak) FHMessageViewModel *viewModel;
@end

@implementation DeleteAlertDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_viewModel deleteConversation:_conv];
    }
}

@end

@interface FHMessageViewModel () <UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMessageViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) id <FHMessageBridgeProtocol> messageBridge;
@property(nonatomic, strong) NSString *pageType;
@property (nonatomic, copy)     NSString       *enterFrom;
@property(nonatomic, strong) DeleteAlertDelegate *deleteAlertDelegate;

@end

@implementation FHMessageViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;

        [tableView registerClass:[FHMessageCell class] forCellReuseIdentifier:kCellId];

        tableView.delegate = self;
        tableView.dataSource = self;

        self.viewController = viewController;
    }
    return self;
}

- (void)setPageType:(NSString *)pageType {
    _pageType = pageType;
}

- (void)setEnterFrom:(NSString *)enterFrom {
    _enterFrom = enterFrom;
}

- (void)requestData {
    [self.requestTask cancel];
    [self.viewController startLoading];
    WeakSelf;
    self.requestTask = [FHMessageAPI requestMessageListWithCompletion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        StrongSelf;
        [self requestUgcUnread:model error:error];
    }];
}

- (void)requestUgcUnread:(FHUnreadMsgModel *)unreadMsg error:(NSError *)error {
    if(![FHEnvContext isUGCOpen] || ![TTAccountManager isLogin] ){
        [self dataLoaded:unreadMsg error:error ugcUnread:nil];
        return;
    }
    WeakSelf;
    [[FHMessageNotificationManager sharedManager] fetchUnreadMessageWithChannel:nil callback:^(FHUnreadMsgDataUnreadModel *model) {
        StrongSelf;
        [self dataLoaded:unreadMsg error:error ugcUnread:model];
    }];
}

- (void)dataLoaded:(FHUnreadMsgModel *)unreadMsg error:(NSError *)error ugcUnread:(FHUnreadMsgDataUnreadModel *)ugcUnread {
    
    // 如果请求被取消，则不处理
    if(error.code == -999) {
        return ;
    }
    
    BOOL isLogin = [IMManager shareInstance].isClientLogin;
    if(isLogin) {
        NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
        [self.viewController.fatherVC.combiner resetConversations:allConversations];
    };
    [self.viewController endLoading];
    [self.viewController.emptyView hideEmptyView];

    self.viewController.fatherVC.dataList = [unreadMsg.data.unread mutableCopy];
    [self.viewController.fatherVC.combiner resetSystemChannels:[self dataList] ugcUnreadMsg:ugcUnread];
    self.viewController.hasValidateData = [self items].count > 0;
    [self checkShouldShowEmptyMaskView];
}

- (NSMutableArray *)dataList {
    return self.viewController.fatherVC.dataList;
}

- (void)checkShouldShowEmptyMaskView {
    if (![TTAccount sharedAccount].isLogin && self.viewController.dataType == FHMessageRequestDataTypeIM) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoLogin];
        [self clearBadgeNumber];
        return;
    }
    if ([self items].count > 0) {
        [self.viewController.emptyView hideEmptyView];
        [self reloadData];
    } else {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyChatMessage];
        [self reloadData];
        [self clearBadgeNumber];
    }
}

- (void)clearBadgeNumber {
    if ([[[self combiner] allItems] count] == 0) {
        [[self messageBridgeInstance] clearMessageTabBarBadgeNumber];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    if ([[self items] count] > indexPath.row) {
        cell.swipeDelegate = self;
        id model = [self items][indexPath.row];
        if ([model isKindOfClass:[FHUnreadMsgDataUnreadModel class]]) {
            [cell updateWithModel:model];
            cell.isCanGesture = NO;
        } else {
            [cell updateWithChat:model];
            cell.isCanGesture = YES;
            if([[FIMDebugManager shared] isEnableForEntry:FIMDebugOptionEntrySwitchShowDebugInfo]) {
                cell.indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(indexPath.row), @(self.items.count)];
            }
        }
        __weak typeof(self)wself = self;
        cell.deleteConversation = ^(NSInteger index) {
            if (index >= 0 && index < [wself items].count) {
                [wself displayDeleteConversationConfirm:[wself items][index]];
            }
        };
        cell.openEditTrack = ^(id data) {
            [wself openEditTrack];
        };
        cell.stateIsClose = ^(id data) {
            [wself reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 92;
    }
    return 96;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (FHConversationDataCombiner *)combiner {
    return self.viewController.fatherVC.combiner;
}

- (NSArray *)items {
    switch (self.viewController.dataType) {
        case FHMessageRequestDataTypeIM:
            return [[self combiner] conversationItems];
            break;
        case FHMessageRequestDataTypeSystem:
            return [[self combiner] channelItems];
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (FHMessageCell *cell in self.tableView.visibleCells) {
        if (!cell.isClose) {
            [cell hiddenSwipeAnimationAtCell:YES];
            return;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[self items] count] > indexPath.row) {
        id item = [self items][indexPath.row];
        if ([item isKindOfClass:[FHUnreadMsgDataUnreadModel class]]) {
            FHUnreadMsgDataUnreadModel *theModel = item;
            if ([theModel.unread integerValue] > 0) {
                theModel.unread = @"0";
                FHMessageCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                cell.unreadView.badgeNumber = TTBadgeNumberHidden;
                [self reloadData];
                [[self messageBridgeInstance] reduceMessageTabBarBadgeNumber:[theModel.unread integerValue]];
            }
            NSURL *url = [NSURL URLWithString:[theModel.openUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            FHMessageType type = [theModel.id integerValue];
            //ugc 消息列表
            if(type == FHMessageTypeHouseRent){
                NSMutableDictionary *tracerDictForUgc = [NSMutableDictionary dictionary];
                tracerDictForUgc[@"origin_from"] = @"interactive_messages";
                tracerDictForUgc[@"enter_from"] = @"message_list";
                tracerDictForUgc[@"enter_type"] = @"click";
                tracerDictForUgc[@"element_from"] = @"feed_messagetab_cell";
                TTRouteUserInfo *ugcUserInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDictForUgc}];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:ugcUserInfo];
                return;
            }

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"typeId"] = theModel.id;
            
            NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
            
            if(type == FHMessageTypeHouseReport) {
                // 房源举报反馈列表
                tracerDict[UT_ORIGIN_FROM] = @"messagetab_feedback";
                tracerDict[UT_ENTER_FROM] = @"message_notice";
                tracerDict[UT_ELEMENT_FROM] = @"feedback";
            }
            dict[TRACER_KEY] = tracerDict;
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            
            
        } else {
            IMConversation *conv = item;
            if(conv.type == IMConversationType1to1Chat) {
                [self processJumpToConversation:conv];
            } else {
                [self openConversation:conv];
            }
        }
    }
}

- (void)processJumpToConversation:(IMConversation *)conv {
    // TODO: JOKER 判断经纪人是否被关黑
    [conv getTargetUserInfoWithCompletion:^(NSString * _Nonnull userId, FHChatUserInfo * _Nonnull userInfo) {
        BOOL isPunish = [userInfo.punishStatus boolValue];
        NSString *tips = userInfo.punishTips;
        BOOL isBlackmail = (isPunish && tips.length > 0);
        if(isBlackmail) {
            [[IMManager shareInstance] showBlackmailRealtorPopupViewWithContent:tips leftTitle:@"其它经纪人" leftAction:^{
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL btd_URLWithString:userInfo.redirect]];
            } rightTitle:@"继续联系" rightAction:^{
                [self openConversation:conv];
            }];
        } else {
            [self openConversation:conv];
        }
    }];
}

- (void)reloadData {
    // 通知栏未读数计算
    NSInteger systemMessageNumber = 0;
    for (FHUnreadMsgDataUnreadModel *item in [[self combiner] channelItems]) {
        systemMessageNumber += [item.unread integerValue];
    }
    // 微聊未读数计算
    RACTuple *unreadNumberTuple = [[IMManager shareInstance] unreadNumberTupleForConversations];
    RACTupleUnpack(NSNumber *totalUnmuteUnreadNumber, NSNumber *totalMuteUnreadNumber) = unreadNumberTuple;
    NSInteger chatNumber = totalUnmuteUnreadNumber.unsignedIntegerValue;
    // 更新消息中心的数据源，用于底部未读数展示
    [[FHEnvContext sharedInstance].messageManager writeUnreadChatMsgCount:chatNumber];
    BOOL hasChatRedPoint = (totalMuteUnreadNumber.unsignedIntegerValue > 0);
    
    // 更新顶部未读数标签
    if (self.viewController.updateRedPoint) {
        self.viewController.updateRedPoint(chatNumber, hasChatRedPoint, systemMessageNumber);
    }
    [self.tableView reloadData];
}

- (id <FHMessageBridgeProtocol>)messageBridgeInstance {
    if (!_messageBridge) {
        Class classBridge = NSClassFromString(@"FHMessageBridgeImp");
        if (classBridge) {
            _messageBridge = [[classBridge alloc] init];
        }
    }
    return _messageBridge;
}

- (void)openConversation:(IMConversation *)conv {
    if (conv.type == IMConversationTypeGroupChat) {
        NSString *title = [@"" stringByAppendingFormat:@"%@(%@)", conv.conversationDisplayName, [[NSNumber numberWithLongLong:conv.participantsCount] stringValue]];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:conv.identifier forKey:KSCHEMA_CONVERSATION_ID];
        [params setValue:title forKey:KSCHEMA_CHAT_TITLE];
        NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
        [tracer setValue:@"message_list" forKey:@"origin_from"];
        [tracer setValue:@"message_list" forKey:@"enter_from"];
        NSURL *openUrl = [TTURLUtils URLWithString:@"sslocal://open_group_chat" queryItems:params];
        [self clickImMessageEvent:conv];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracer}];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    } else {
        NSString *title = conv.conversationDisplayName;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:conv.identifier forKey:KSCHEMA_CONVERSATION_ID];
        [params setValue:title forKey:KSCHEMA_CHAT_TITLE];
        NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
        [tracer setValue:@"message_list" forKey:@"origin_from"];
        [tracer setValue:@"message_list" forKey:@"enter_from"];
        tracer[@"element_from"] = @"be_null";
        tracer[@"log_pb"] = @"be_null";
        tracer[@"origin_search_id"] = self.viewController.tracerModel.originSearchId;
        NSURL *openUrl = [TTURLUtils URLWithString:@"sslocal://open_single_chat" queryItems:params];
        [self clickImMessageEvent:conv];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracer}];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)displayDeleteConversationConfirm:(IMConversation *)conversation {
    self.deleteAlertDelegate = [[DeleteAlertDelegate alloc] init];
    self.deleteAlertDelegate.viewModel = self;
    self.deleteAlertDelegate.conv = conversation;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除会话"
                                                        message:@"确定要删除当前会话记录？"
                                                       delegate:self.deleteAlertDelegate
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"删除", nil];

    [alertView show];
};

- (NSString *)getPageTypeWithDataType{
    if (self.viewController.dataType == FHMessageRequestDataTypeIM) {
        return @"message_weiliao";
    } else if (self.viewController.dataType == FHMessageRequestDataTypeSystem) {
        return @"message_notice";
    }
    return @"message_list";
}

- (void)deleteConversation:(IMConversation *)conv {
    NSString *conversationId = conv.identifier;
    IMConversation *latestConversation = [[IMManager shareInstance].chatService conversationWithIdentifier:conversationId];
    NSString *targetUserId = [latestConversation getTargetUserId:[[TTAccount sharedAccount] userIdString]];
    NSDictionary *params = @{@"a:c_del": (latestConversation.lastMessageIdentifier ? latestConversation.lastMessageIdentifier : @"del_empty_conver")};
    [conv setSyncExtEntry:params completion:^(id _Nullable response, NSError *_Nullable error) {
        if (error == nil) {
            [latestConversation setDraft:nil];
            NSDictionary *params = @{
                    @"page_type": [self getPageTypeWithDataType],
                    //@"conversation_id": conversationId,
                    @"realtor_id": targetUserId,
                    @"click_position": @"delete",
                    @"enter_from":@"message"
            };
            //[FHUserTracker writeEvent:@"delete_conversation" params:params];
            [FHUserTracker writeEvent:@"message_flip_click" params:params];
        }
        
    }];
}

- (void)clickImMessageEvent:(IMConversation *)conv {
    NSString *conversationId = conv.identifier;
    NSString *targetUserId = [conv getTargetUserId:[[TTAccount sharedAccount] userIdString]];
    NSDictionary *params = @{
            @"page_type": _pageType,
            @"conversation_id": conversationId,
            @"realtor_id": targetUserId,
            @"enter_from":self.enterFrom ?: @"be_null"
    };
    [FHUserTracker writeEvent:@"click_conversation" params:params];
}

- (void)openEditTrack {
    NSDictionary *params = @{
            @"page_type": [self getPageTypeWithDataType],
            @"enter_from":@"message"
    };
    [FHUserTracker writeEvent:@"message_flip_show" params:params];
}


#pragma mark -- SwipeTableViewDelegate

// cell的滑动样式
- (SwipeTableCellStyle)tableView:(UITableView *)tableView styleOfSwipeButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SwipeTableCellStyleRightToLeft;
}

- (NSArray<FHMessageSwipeButton *> *)tableView:(UITableView *)tableView rightSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    FHMessageSwipeButton *deleteBtn = [FHMessageSwipeButton createSwipeButtonWithTitle:@"删除" font:16 textColor:[UIColor blackColor] backgroundColor:[UIColor redColor] touchBlock:^{
        
    }];
    deleteBtn.layer.cornerRadius = 10;
    deleteBtn.layer.masksToBounds = YES;
    deleteBtn.hidden = YES;
    return @[deleteBtn];
}


// swipeView的弹出样式
- (SwipeViewTransfromMode)tableView:(UITableView *)tableView swipeViewTransformModeAtIndexPath:(NSIndexPath *)indexPath
{
    return SwipeViewTransfromModeStatic;
}

// swipeButton 距上左下右的间距  注意不能刚给负值
- (UIEdgeInsets)tableView:(UITableView *)tableView swipeButtonEdgeAtIndexPath:(NSIndexPath *)indexPath
{

    return UIEdgeInsetsZero;
}

- (void)dealloc
{
    
}

@end
