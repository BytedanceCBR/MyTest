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
#import "ChatRootViewController.h"
#import "IMManager.h"
#import "IMChatStateObserver.h"
#import "TTURLUtils.h"
#import <libextobjc/extobjc.h>
#import "FHUserTracker.h"
#import "TTAccount.h"
#import "FHMessageNotificationManager.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHMessageEditHelp.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "FHMessageEditView.h"
#import "TestModel.h"

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
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) NSString *pageType;
@property (nonatomic, copy)     NSString       *enterFrom;
@property(nonatomic, strong) DeleteAlertDelegate *deleteAlertDelegate;

@end

@implementation FHMessageViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController {
    self = [super init];
    if (self) {
        _isFirstLoad = self.combiner.isFirstLoad;
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
    if (self.isFirstLoad) {
        [self.viewController startLoading];
    }
    WeakSelf;
    self.requestTask = [FHMessageAPI requestMessageListWithCompletion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        StrongSelf;
        [wself requestUgcUnread:model error:error];
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
        [wself dataLoaded:unreadMsg error:error ugcUnread:model];
    }];
}

- (void)dataLoaded:(FHUnreadMsgModel *)unreadMsg error:(NSError *)error ugcUnread:(FHUnreadMsgDataUnreadModel *)ugcUnread {
    
    BOOL isLogin = [IMManager shareInstance].isClientLogin;
    if(isLogin) {
        NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
        [self.viewController.fatherVC.combiner resetConversations:allConversations];
    };
    
    if (self.isFirstLoad) {
        [self.viewController endLoading];
    }

    self.isFirstLoad = NO;

    if (error && [self.viewController.fatherVC.combiner allItems].count == 0) {
        //TODO: show handle error
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        [self clearBadgeNumber];
        return;
    }

    [self.viewController.emptyView hideEmptyView];

    self.viewController.fatherVC.dataList = [unreadMsg.data.unread mutableCopy];
    [self.viewController.fatherVC.combiner resetSystemChannels:[self dataList] ugcUnreadMsg:ugcUnread];
    self.viewController.hasValidateData = [self dataList].count > 0;
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
        [self clearBadgeNumber];
    }
}

- (void)clearBadgeNumber {
    [[self messageBridgeInstance] clearMessageTabBarBadgeNumber];
}

//消息列表页刷新 埋点
//- (void)trackRefresh {
//    NSMutableDictionary *dict = [self.viewController.tracerModel logDict];
//    dict[@"refresh_type"] = @"default";
//    TRACK_EVENT(@"category_refresh", dict);
//}

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
        }
        __weak typeof(self)wself = self;
        cell.deleteConversation = ^(id data) {
            [wself displayDeleteConversationConfirm:data];
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
                // Tab消息个数减少
                //        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMessageTabBarBadge" object:model.unread];
                [[self messageBridgeInstance] reduceMessageTabBarBadgeNumber:[theModel.unread integerValue]];

                theModel.unread = @"0";
                FHMessageCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                cell.unreadView.badgeNumber = TTBadgeNumberHidden;
            }
            NSURL *url = [NSURL URLWithString:[theModel.openUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //ugc 消息列表
            if([theModel.id isEqualToString:@"309"]){
                NSMutableDictionary *tracerDictForUgc = [NSMutableDictionary dictionary];
                tracerDictForUgc[@"origin_from"] = @"message";
                tracerDictForUgc[@"enter_from"] = @"messagetab";
                tracerDictForUgc[@"enter_type"] = @"click";
                tracerDictForUgc[@"element_from"] = @"feed_messagetab_cell";
                TTRouteUserInfo *ugcUserInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDictForUgc}];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:ugcUserInfo];
                return;
            }

            NSDictionary *dict = @{
                    @"typeId": theModel.id
            };

            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            
            
        } else {
            IMConversation *conv = item;
            [self openConversation:conv];
        }
    }
}

- (void)reloadData {
    NSInteger chatNumber = 0;
    NSInteger systemMessageNumber = 0;
    BOOL hasChatRedPoint = NO;
    for (IMConversation *conv in [[self combiner] conversationItems]) {
        if (conv.mute) {
            if (conv.unreadCount > 0) {
                hasChatRedPoint = YES;
            }
        } else {
            chatNumber += conv.unreadCount;
        }
    }
    for (FHUnreadMsgDataUnreadModel *item in [[self combiner] channelItems]) {
        systemMessageNumber += [item.unread integerValue];
    }
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
    NSString *targetUserId = [conv getTargetUserId:[[TTAccount sharedAccount] userIdString]];
    NSDictionary *params = @{@"a:c_del": (conv.lastMessageIdentifier ? conv.lastMessageIdentifier : @"del_empty_conver")};
    [conv setSyncExtEntry:params completion:^(id _Nullable response, NSError *_Nullable error) {
        if (error == nil) {
            [conv setDraft:nil];
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

- (NSArray<SwipeButton *> *)tableView:(UITableView *)tableView rightSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath
{
    SwipeButton *deleteBtn = [SwipeButton createSwipeButtonWithTitle:@"删除" font:16 textColor:[UIColor blackColor] backgroundColor:[UIColor redColor] image:[UIImage imageNamed:@"delete"] touchBlock:^{
        
        NSLog(@"点击了check按钮");
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

@end
