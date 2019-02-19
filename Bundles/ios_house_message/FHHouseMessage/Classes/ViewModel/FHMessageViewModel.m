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
#import "TTURLUtils.h"

#define kCellId @"FHMessageCell_id"

@interface FHMessageViewModel()
@property(nonatomic, strong) FHConversationDataCombiner *combiner;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMessageViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) id<FHMessageBridgeProtocol> messageBridge;

@end

@implementation FHMessageViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController
{
    self = [super init];
    if (self) {
        self.combiner = [[FHConversationDataCombiner alloc] init];
        _dataList = [[NSMutableArray alloc] init];
        
        self.tableView = tableView;
        
        [tableView registerClass:[FHMessageCell class] forCellReuseIdentifier:kCellId];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
        
    }
    return self;
}

-(void)requestData {
    [self.requestTask cancel];
    
//    [self trackRefresh];
    __weak typeof(self) wself = self;
    
    if(self.dataList.count == 0){
        [self.viewController startLoading];
    }
    NSArray<IMConversation*>* allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    self.requestTask = [FHMessageAPI requestMessageListWithCompletion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        FHUnreadMsgModel *msgModel = (FHUnreadMsgModel *)model;
        
        if(self.dataList.count == 0){
            [self.viewController endLoading];
        }
        
        if (!wself) {
            return;
        }
        
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

- (void)clearBadgeNumber
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kClearMessageTabBarBadgeNumberNotification" object:nil];
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
    [[TTRoute sharedRoute] openURLByPushViewController: openUrl];
}

@end
