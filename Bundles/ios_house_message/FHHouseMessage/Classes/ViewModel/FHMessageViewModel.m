//
//  FHMessageViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageViewModel.h"
#import <TTRoute.h>
#import <TTHttpTask.h>
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

#define kCellId @"FHMessageCell_id"
@interface DeleteAlertDelegate : NSObject<UIAlertViewDelegate>
@property (nonatomic, strong) IMConversation* conv;
@property (nonatomic, weak) FHMessageViewModel* viewModel;
@end

@implementation DeleteAlertDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_viewModel deleteConversation:_conv];
}

@end

@interface FHMessageViewModel()<IMChatStateObserver>
@property(nonatomic, strong) FHConversationDataCombiner *combiner;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMessageViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) id<FHMessageBridgeProtocol> messageBridge;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) NSString *pageType;

@property(nonatomic, strong) DeleteAlertDelegate *deleteAlertDelegate;

@end

@implementation FHMessageViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController
{
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
    }
    return self;
}

- (void)setPageType:(NSString *)pageType {
    _pageType = pageType;
}

-(void)requestData {
    [self.requestTask cancel];
    
//    [self trackRefresh];
    __weak typeof(self) wself = self;
    
    if(self.isFirstLoad){
        [self.viewController startLoading];
    }
    NSArray<IMConversation*>* allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    self.requestTask = [FHMessageAPI requestMessageListWithCompletion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        FHUnreadMsgModel *msgModel = (FHUnreadMsgModel *)model;
        
        if(self.isFirstLoad){
            [self.viewController endLoading];
        }
        
        if (!wself) {
            return;
        }
        
        wself.isFirstLoad = NO;
        
        if (error && wself.dataList.count == 0) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            [wself clearBadgeNumber];
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            wself.dataList = msgModel.data.unread;
            [wself.combiner resetSystemChannels:msgModel.data.unread];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
                [wself clearBadgeNumber];
            }
        }

    }];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_combiner numberOfItems];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[_combiner allItems] count] > indexPath.row) {
        id item = [_combiner allItems][indexPath.row];
        if ([item isKindOfClass:[FHUnreadMsgDataUnreadModel class]]) {
            FHUnreadMsgDataUnreadModel* theModel = item;
            if([theModel.unread integerValue] > 0){
                // Tab消息个数减少
                //        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMessageTabBarBadge" object:model.unread];
                [[self messageBridgeInstance] reduceMessageTabBarBadgeNumber:[theModel.unread integerValue]];

                theModel.unread = @"0";
                FHMessageCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                cell.unreadView.badgeNumber = TTBadgeNumberHidden;
            }
            NSURL *url = [NSURL URLWithString:[theModel.openUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            NSDictionary *dict = @{
                                   @"typeId": theModel.id
                                   };

            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        } else {
            IMConversation* conv = item;
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
        if ([conv isKindOfClass:[IMConversation class]]){
            [self displayDeleteConversationConfirm:conv];
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    UIContextualAction* action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        @strongify(self);
        completionHandler(YES);
        if ([self.combiner allItems].count > indexPath.row) {
            id conv = [self.combiner allItems][indexPath.row];
            if ([conv isKindOfClass:[IMConversation class]]){
                [self displayDeleteConversationConfirm:conv];
            }
        }
    }];
    action.backgroundColor = [UIColor colorWithRed:236/255.0 green:77/255.0 blue:61/255.0 alpha:1];
    UISwipeActionsConfiguration* config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

- (id<FHMessageBridgeProtocol>)messageBridgeInstance {
    if (!_messageBridge) {
        Class classBridge = NSClassFromString(@"FHMessageBridgeImp");
        if (classBridge) {
            _messageBridge = [[classBridge alloc] init];
        }
    }
    return _messageBridge;
}

-(void)openConversation:(IMConversation*)conv {
    NSString *title = conv.conversationDisplayName;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:conv.identifier forKey:KSCHEMA_CONVERSATION_ID];
    [params setObject:title  forKey:KSCHEMA_CHAT_TITLE];
    NSURL *openUrl = [TTURLUtils URLWithString:@"sslocal://open_single_chat" queryItems:params];
    [self clickImMessageEvent:conv];
    [[TTRoute sharedRoute] openURLByPushViewController: openUrl];
}

-(void)displayDeleteConversationConfirm:(IMConversation*) conversation{
    self.deleteAlertDelegate = [[DeleteAlertDelegate alloc] init];
    self.deleteAlertDelegate.viewModel = self;
    self.deleteAlertDelegate.conv = conversation;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"删除会话"
                                                        message:@"确定要删除当前会话记录？"
                                                       delegate:self.deleteAlertDelegate
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"删除", nil];

    [alertView show];
};

-(void)deleteConversation:(IMConversation*)conv {
    [conv markLocalDeleted:^(NSError * _Nullable error) {

    }];
}

- (void)clickImMessageEvent:(IMConversation*)conv {
    NSString *conversationId = conv.identifier;
    NSString *targetUserId = [conv getTargetUserId: [[TTAccount sharedAccount] userIdString]];
    NSDictionary *params = @{
                             @"event_type": @"house_app2b",
                             @"page_type": _pageType,
                             @"conversation_id" : conversationId,
                             @"realtor_id" : targetUserId,
                             };
    [FHUserTracker writeEvent:@"click_conversation" params:params];
}

-(void)conversationUpdated:(NSString *)conversationIdentifier {
    NSArray<IMConversation*>* allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    [self.tableView reloadData];
}

@end
