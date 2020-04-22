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

#import <ReactiveObjC/ReactiveObjC.h>

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

@interface FHMessageViewModel () <IMChatStateObserver, UITableViewDelegate>
@property(nonatomic, strong) FHConversationDataCombiner *combiner;

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
        self.combiner = [[FHConversationDataCombiner alloc] init];
        _dataList = [[NSMutableArray alloc] init];
        _isFirstLoad = YES;
        self.tableView = tableView;

        [tableView registerClass:[FHMessageCell class] forCellReuseIdentifier:kCellId];

        tableView.delegate = self;
        tableView.dataSource = self;

        self.viewController = viewController;
        [[IMManager shareInstance] addChatStateObverver:self];
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KUSER_UPDATE_NOTIFICATION object:nil] throttle:2] subscribeNext:^(NSNotification *_Nullable x) {
            @strongify(self)
            NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
            [_combiner resetConversations:allConversations];
            [self.tableView reloadData];
        }];
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTTMessageNotificationTipsChangeNotification object:nil] throttle:2] subscribeNext:^(NSNotification *_Nullable x) {
            @strongify(self)
            if([FHMessageNotificationTipsManager sharedManager].tipsModel){
                [_combiner resetSystemChannels:self.dataList ugcUnreadMsg:[FHMessageNotificationTipsManager sharedManager].tipsModel];
                [self.tableView reloadData];
                return;
            }
        }];
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
    NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    if (self.isFirstLoad) {
        [self.viewController endLoading];
    }

    self.isFirstLoad = NO;

    if (error && [self.combiner allItems].count == 0) {
        //TODO: show handle error
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        [self clearBadgeNumber];
        return;
    }

    [self.viewController.emptyView hideEmptyView];

    self.dataList = [unreadMsg.data.unread mutableCopy];
    [self.combiner resetSystemChannels:self.dataList ugcUnreadMsg:ugcUnread];
    self.viewController.hasValidateData = self.dataList.count > 0;
    [self checkShouldShowEmptyMaskView];
}

- (void)checkShouldShowEmptyMaskView {
    if ([self.combiner allItems].count > 0) {
        [self.viewController.emptyView hideEmptyView];
        [self.tableView reloadData];
    } else {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
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
    return [_combiner numberOfItems];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if ([[_combiner allItems] count] > indexPath.row) {
        id model = [_combiner allItems][indexPath.row];
        if ([model isKindOfClass:[FHUnreadMsgDataUnreadModel class]]) {
            [cell updateWithModel:model];
        } else {
            [cell updateWithChat:model];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 92;
    }
    return 82;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[_combiner allItems] count] > indexPath.row) {
        id item = [_combiner allItems][indexPath.row];
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_combiner allItems] count] > indexPath.row) {
        id item = [_combiner allItems][indexPath.row];
        if ([item isKindOfClass:[IMConversation class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_combiner allItems] count] > indexPath.row) {
        id item = [_combiner allItems][indexPath.row];
        if ([item isKindOfClass:[IMConversation class]]) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.combiner allItems].count > indexPath.row) {
        id conv = [self.combiner allItems][indexPath.row];
        if ([conv isKindOfClass:[IMConversation class]]) {
            [self displayDeleteConversationConfirm:conv];
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
        @strongify(self);
        completionHandler(YES);
        if ([self.combiner allItems].count > indexPath.row) {
            id conv = [self.combiner allItems][indexPath.row];
            if ([conv isKindOfClass:[IMConversation class]]) {
                [self displayDeleteConversationConfirm:conv];
            }
        }
    }];
    action.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:77 / 255.0 blue:61 / 255.0 alpha:1];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
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

- (void)deleteConversation:(IMConversation *)conv {
    NSString *conversationId = conv.identifier;
    NSString *targetUserId = [conv getTargetUserId:[[TTAccount sharedAccount] userIdString]];
    NSDictionary *params = @{@"a:c_del": (conv.lastMessageIdentifier ? conv.lastMessageIdentifier : @"del_empty_conver")};
    [conv setSyncExtEntry:params completion:^(id _Nullable response, NSError *_Nullable error) {
        if (error == nil) {
            [conv setDraft:nil];
            NSDictionary *params = @{
                    @"page_type": _pageType,
                    @"conversation_id": conversationId,
                    @"realtor_id": targetUserId,
                    @"enter_from":self.enterFrom ?: @"be_null"
            };
            [FHUserTracker writeEvent:@"delete_conversation" params:params];
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

- (void)conversationUpdated:(NSString *)conversationIdentifier {
    NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
//    [self.tableView reloadData];
    [self checkShouldShowEmptyMaskView];
}

@end
