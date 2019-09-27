//
//  FHMessageListSysViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListSysViewModel.h"
#import "FHMessageAPI.h"
#import <UIScrollView+Refresh.h>
#import "FHSystemMsgCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUserTracker.h"
#import "FHSystemMsgModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"

#define kCellId @"FHBSystemMsgCell_id"

@interface FHMessageListSysViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, copy) NSString *originSearchId;
@property(nonatomic, copy) NSString *searchId;

@end

@implementation FHMessageListSysViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHBaseViewController *)viewController
{
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
        [tableView registerClass:[FHSystemMsgCell class] forCellReuseIdentifier:kCellId];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [self addEnterCategoryLog];
    }
    return self;
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self.viewController categoryName];
    tracerDict[@"enter_from"] = @"messagetab";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"search_id"] = self.searchId ? self.searchId : @"be_null";
    tracerDict[@"origin_from"] = @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? self.originSearchId : @"be_null";
    tracerDict[@"element_from"] = @"be_null";
    
    return tracerDict;
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    TRACK_EVENT(@"enter_category", tracerDict);
}

-(void)requestData:(BOOL)isHead first:(BOOL)isFirst
{
    [super requestData:isHead first:isFirst];
    
    if(isFirst){
        [self.viewController startLoading];
    }

    if(isHead){
        self.maxCursor = nil;
    }else{
        [self addRefreshLog];
    }
    
    __weak typeof(self) wself = self;
    
    self.requestTask = [FHMessageAPI requestSysMessageWithListId:FHMessageTypeSystem maxCoursor:self.maxCursor completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        [wself.tableView.mj_footer endRefreshing];
        FHSystemMsgModel *msgModel = (FHSystemMsgModel *)model;
        
        if (!wself) {
            return;
        }
        
        if (error && self.dataList.count == 0) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            
            wself.maxCursor = msgModel.data.minCursor;
            
            if (isHead) {
                [wself.dataList removeAllObjects];
                wself.searchId = msgModel.data.searchId;
                wself.originSearchId = wself.searchId;
            }
            [wself.dataList addObjectsFromArray:msgModel.data.items];
            wself.tableView.hasMore = msgModel.data.hasMore;
            [wself updateTableViewWithMoreData:msgModel.data.hasMore];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
            }
        }
        
    }];
}

- (void)addRefreshLog
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    TRACK_EVENT(@"category_refresh", tracerDict);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHSystemMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    FHSystemMsgDataItemsModel *model = self.dataList[indexPath.row];
    
    cell.dateLabel.text = model.dateStr;
    cell.titleLabel.text = model.title;
    cell.descLabel.text = model.content;
    cell.lookDetailLabel.text = model.buttonName;
    
    FHSystemMsgDataItemsImagesModel *imageModel = model.images;
    if(imageModel.url){
        [cell.imgView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed:@"default_image"]];
    }else{
        cell.imgView.image = [UIImage imageNamed:@"default_image"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHSystemMsgDataItemsModel *model = self.dataList[indexPath.row];
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self.viewController categoryName];
    tracerDict[@"log_pb"] = model.logPb ? : @"be_null";
    tracerDict[@"official_message_id"] = model.id;
    TRACK_EVENT(@"click_official_message", tracerDict);
    
    NSURL* url = [NSURL URLWithString:model.openUrl];
    if ([url.scheme isEqualToString:@"fschema"]) {
        NSString *newModelUrl = [model.openUrl stringByReplacingOccurrencesOfString:@"fschema:" withString:@"snssdk1370:"];
        url = [NSURL URLWithString:newModelUrl];
    }
    if (url && ([@"home" isEqualToString:[url host]] || [@"main" isEqualToString:[url host]])) {
        [[TTRoute sharedRoute] openURL:url userInfo:nil objHandler:nil];
        return;
    }
    
    NSMutableDictionary *infoDic = @{}.mutableCopy;
    infoDic[TRACER_KEY] = @{
        UT_ENTER_TYPE: @"click"
    };
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDic];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

@end
