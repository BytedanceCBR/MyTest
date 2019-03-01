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

#define kCellId @"FHMessageCell_id"

@interface FHMessageViewModel()

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMessageViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) id<FHMessageBridgeProtocol> messageBridge;
@property(nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FHMessageViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageViewController *)viewController
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _isFirstLoad = YES;
        self.tableView = tableView;
        
        [tableView registerClass:[FHMessageCell class] forCellReuseIdentifier:kCellId];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
        
    }
    return self;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"kFHMessageUnreadChangedNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData:(NSNotification *)notification {
    NSError *error = nil;
    if(notification.object){
        FHUnreadMsgModel *model = [[FHUnreadMsgModel alloc] initWithData:notification.object error:&error];
        if(!error && model){
            [self.requestTask cancel];
            [self.viewController.emptyView hideEmptyView];
            self.dataList = model.data.unread;
            self.viewController.hasValidateData = self.dataList.count > 0;
            [self.tableView reloadData];
        }
    }
}

- (void)requestData {
    [self.requestTask cancel];
    
//    [self trackRefresh];
    __weak typeof(self) wself = self;
    
    if(self.isFirstLoad){
        [self.viewController startLoading];
    }
    
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
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            NSInteger unreadCount = 0;
            for (FHUnreadMsgDataUnreadModel *unreadModel in self.dataList) {
                unreadCount += [unreadModel.unread integerValue];
            }
            
            [[wself messageBridgeInstance] setMessageTabBadgeNumber:unreadCount];
            
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
    return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    FHUnreadMsgDataUnreadModel *model = _dataList[indexPath.row];
    [cell updateWithModel:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    FHUnreadMsgDataUnreadModel *model = _dataList[indexPath.row];
    
    if([model.unread integerValue] > 0){
        // Tab消息个数减少
        [[self messageBridgeInstance] reduceMessageTabBarBadgeNumber:[model.unread integerValue]];
        
        model.unread = @"0";
        FHMessageCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        cell.unreadView.badgeNumber = TTBadgeNumberHidden;
    }

    NSURL *url = [NSURL URLWithString:[model.openUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *dict = @{
                           @"typeId": model.id
                           };

    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
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

@end
