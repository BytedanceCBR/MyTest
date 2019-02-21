//
//  FHMessageListHouseViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListHouseViewModel.h"
#import "FHMessageAPI.h"
#import <UIScrollView+Refresh.h>
#import "FHHouseMsgCell.h"
#import "FHUserTracker.h"
#import "FHHouseMsgModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHHouseHeaderView.h"
#import "FHHouseMsgFooterView.h"
#import "TTRoute.h"
#import "FHHouseType.h"

#define kCellId @"FHHouseMsgCell_id"

@interface FHMessageListHouseViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic ,assign) NSInteger listId;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) NSInteger rank;
@property(nonatomic, copy) NSString *originSearchId;
@property(nonatomic, copy) NSString *searchId;
@property(nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FHMessageListHouseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListViewController *)viewController listId:(NSInteger)listId
{
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.listId = listId;
        self.dataList = [[NSMutableArray alloc] init];
        [tableView registerClass:[FHHouseMsgCell class] forCellReuseIdentifier:kCellId];
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    return self;
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self.viewController categoryName];
    tracerDict[@"enter_from"] = @"messagetab";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"element_from"] = @"be_null";
    tracerDict[@"origin_from"] = [self.viewController originFrom];
    tracerDict[@"origin_search_id"] = self.originSearchId ? self.originSearchId : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? self.searchId : @"be_null";
    
    return tracerDict;
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst
{
    [super requestData:isHead first:isFirst];
    
    if(isFirst){
        [self.viewController startLoading];
    }
    
    if(isHead){
        self.maxCursor = nil;
        self.searchId = nil;
        self.originSearchId = nil;
        [self.clientShowDict removeAllObjects];
        self.rank = 0;
    }else{
        [self addRefreshLog];
    }
    
    __weak typeof(self) wself = self;
    
    self.requestTask = [FHMessageAPI requestHouseMessageWithListId:self.listId maxCoursor:self.maxCursor searchId:self.originSearchId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        [wself.tableView.mj_footer endRefreshing];
        FHHouseMsgModel *msgModel = (FHHouseMsgModel *)model;
        
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
            wself.originSearchId = msgModel.data.searchId;
            
            if (isHead) {
                [wself.dataList removeAllObjects];
            }
            [wself.dataList addObjectsFromArray:msgModel.data.items];
            wself.tableView.hasMore = msgModel.data.hasMore;
            [wself updateTableViewWithMoreData:msgModel.data.hasMore];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                wself.refreshFooter.hidden = NO;
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
            }
            
            if(self.isFirstLoad){
                self.originSearchId = self.searchId;
                self.isFirstLoad = NO;
                [self addEnterCategoryLog];
            }
            
            if(!isHead){
                [self addRefreshLog];
            }
        }
        
    }];
}

- (void)addRefreshLog {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    tracerDict[@"element_from"] = @"be_null";
    TRACK_EVENT(@"category_refresh", tracerDict);
}

- (void)viewMoreDetail:(NSString *)moreDetail model:(FHHouseMsgDataItemsModel *)model {
    NSMutableDictionary *tracerDict = [self categoryLogDict];
    tracerDict[@"element_from"] = @"messagetab";
    tracerDict[@"enter_from"] = @"messagetab";
    TRACK_EVENT(@"click_recommend_loadmore", tracerDict);
    
    NSURL* url = [NSURL URLWithString:moreDetail];
    if ([url.scheme isEqualToString:@"fschema"]) {
        NSString *newModelUrl = [moreDetail stringByReplacingOccurrencesOfString:@"fschema:" withString:@"snssdk1370:"];
        url = [NSURL URLWithString:newModelUrl];
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

//埋点
- (void)trackOperationWithModel:(FHHouseMsgDataItemsItemsModel *)model index:(NSInteger)index trackName:(NSString *)trackName {
    NSMutableDictionary *tracerDict = [self categoryLogDict];
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"group_id"] = model.id;
    tracerDict[@"house_type"] = model.houseType;
    tracerDict[@"impr_id"] = model.imprId;
    tracerDict[@"log_pb"] = model.logPb ? model.logPb : @"be_null";
    tracerDict[@"rank"] = @(index);
    tracerDict[@"page_type"] = [self.viewController categoryName];
    tracerDict[@"search_id"] = model.searchId;

    TRACK_EVENT(trackName, tracerDict);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FHHouseMsgDataItemsModel *model = self.dataList[section];
    NSArray *houses = model.items;
    return [houses count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
    FHHouseMsgDataItemsItemsModel *itemsModel = model.items[indexPath.row];
    
    [cell updateWithModel:itemsModel];
    
    if (!_clientShowDict) {
        _clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *section_row = [NSString stringWithFormat:@"%i_%i",indexPath.section,indexPath.row];
    if (_clientShowDict[section_row]) {
        return cell;
    }
    
    _clientShowDict[section_row] = @(_rank);
    [self trackOperationWithModel:itemsModel index:_rank trackName:@"house_show"];
    _rank++;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 90.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FHHouseHeaderView *headerView = [[FHHouseHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90)];
    
    FHHouseMsgDataItemsModel *model = self.dataList[section];
    headerView.dateLabel.text = model.dateStr;
    headerView.contentLabel.text = model.title;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section < self.dataList.count){
        FHHouseMsgDataItemsModel *model = self.dataList[section];
        if(model.moreLabel.length > 0){
            return 40.0f;
        }
    }
        
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    __weak typeof(self) wself = self;
    if(section < self.dataList.count){
        FHHouseMsgDataItemsModel *model = self.dataList[section];
        if(model.moreLabel.length > 0){
            FHHouseMsgFooterView *footerView = [[FHHouseMsgFooterView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 40)];
            footerView.contentLabel.text = model.moreLabel;
            footerView.footerViewClickedBlock = ^{
                [wself viewMoreDetail:model.moreDetail model:model];
            };
            
            return footerView;
        }
    }
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section < self.dataList.count){
        FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
        if(indexPath.row == model.items.count - 1){
            return 125;
        }
    }
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
    FHHouseMsgDataItemsItemsModel *itemsModel = model.items[indexPath.row];
    
    NSInteger houseType = [itemsModel.houseType integerValue];
    NSString *houseId = itemsModel.id;
    NSString *urlStr = @"";
    switch (houseType) {
        case FHHouseTypeNewHouse:
            urlStr = [NSString stringWithFormat:@"snssdk1370://new_house_detail?court_id=%@",houseId];
            break;
        case FHHouseTypeSecondHandHouse:
            urlStr = [NSString stringWithFormat:@"snssdk1370://old_house_detail?house_id=%@",houseId];
            break;
        case FHHouseTypeRentHouse:
            urlStr = [NSString stringWithFormat:@"snssdk1370://rent_detail?house_id=%@",houseId];
            break;
        case FHHouseTypeNeighborhood:
            urlStr = [NSString stringWithFormat:@"snssdk1370://neighborhood_detail?neighborhood_id=%@",houseId];
            break;
            
        default:
            break;
    }
    
    NSString *section_row = [NSString stringWithFormat:@"%i_%i",indexPath.section,indexPath.row];
    NSInteger index = [_clientShowDict[section_row] integerValue];
    
    NSDictionary *logPb = itemsModel.logPb;
    NSMutableDictionary *tracerDict = [self categoryLogDict];
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"element_from"] = @"be_null";
    tracerDict[@"enter_from"] = [self.viewController categoryName];
    tracerDict[@"log_pb"] = logPb ? logPb : @"be_null";
    tracerDict[@"search_id"] = itemsModel.searchId ? itemsModel.searchId : @"be_null";
    tracerDict[@"rank"] = @(index);
   
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracerDict}];
    
    NSURL* url = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

@end
