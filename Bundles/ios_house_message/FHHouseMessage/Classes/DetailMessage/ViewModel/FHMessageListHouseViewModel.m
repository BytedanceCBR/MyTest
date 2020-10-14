//
//  FHMessageListHouseViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListHouseViewModel.h"
#import "FHMessageAPI.h"
#import "UIScrollView+Refresh.h"
#import "FHHouseMsgCell.h"
#import "FHUserTracker.h"
#import "FHHouseMsgModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHHouseHeaderView.h"
#import "FHHouseMsgFooterView.h"
#import "TTRoute.h"
#import "FHHouseType.h"
#import <FHHouseBase/FHHouseTypeManager.h>
#import "FHFeedbackMsgCell.h"
#import "FHFeedbackMsgHeaderView.h"

@interface FHMessageListHouseViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic ,assign) NSInteger listId;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) NSInteger rank;
@property(nonatomic, copy) NSString *originSearchId;
@property(nonatomic, copy) NSString *searchId;

@end

@implementation FHMessageListHouseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListViewController *)viewController listId:(NSInteger)listId
{
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.listId = listId;
        self.dataList = [[NSMutableArray alloc] init];
        [tableView registerClass:[FHHouseMsgCell class] forCellReuseIdentifier:NSStringFromClass([FHHouseMsgCell class])];
        [tableView registerClass:[FHHouseHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([FHHouseHeaderView class])];
        [tableView registerClass:[FHHouseMsgFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([FHHouseMsgFooterView class])];
        [tableView registerClass:[FHFeedbackMsgCell class] forCellReuseIdentifier:NSStringFromClass([FHFeedbackMsgCell class])];
        [tableView registerClass:[FHFeedbackMsgHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([FHFeedbackMsgHeaderView class])];
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
    
    return tracerDict.copy;
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
    
    self.requestTask = [FHMessageAPI requestHouseMessageWithListId:self.listId maxCoursor:self.maxCursor searchId:self.searchId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
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
            
            if (isHead) {
                wself.searchId = msgModel.data.searchId;
                wself.originSearchId = wself.searchId;
                [wself.dataList removeAllObjects];
            }
            for (FHHouseMsgDataItemsModel *item in msgModel.data.items) {
                BOOL isSoldout = YES;
                for (FHHouseMsgDataItemsItemsModel *houseItem in item.items) {
                    if (houseItem.status == 0) {
                        isSoldout = NO;
                        break;
                    }
                }
                item.isSoldout = isSoldout;
                [wself.dataList addObject:item];
            }
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
            
            if(isFirst){
                self.originSearchId = self.searchId;
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
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"element_from"] = @"messagetab";
    tracerDict[@"enter_from"] = @"messagetab";
    tracerDict[@"category_name"] = @"be_null";
    FHHouseMsgDataItemsItemsModel *itemModel = [model.items firstObject];
    if(itemModel){
        NSInteger houseType = [itemModel.houseType integerValue];
        switch (houseType) {
            case FHHouseTypeNewHouse:
                tracerDict[@"category_name"] = @"new_list";
                break;
            case FHHouseTypeSecondHandHouse:
                tracerDict[@"category_name"] = @"old_list";
                break;
            case FHHouseTypeRentHouse:
                tracerDict[@"category_name"] = @"rent_list";
                break;
            case FHHouseTypeNeighborhood:
                tracerDict[@"category_name"] = @"neighborhood_list";
                break;
                
            default:
                break;
        }
    }
    
    TRACK_EVENT(@"click_recommend_loadmore", tracerDict);
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
    userDict[@"tracer"] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:userDict];
    
    NSURL* url = [NSURL URLWithString:moreDetail];
    if ([url.scheme isEqualToString:@"fschema"]) {
        NSString *newModelUrl = [moreDetail stringByReplacingOccurrencesOfString:@"fschema:" withString:@"snssdk1370:"];
        url = [NSURL URLWithString:newModelUrl];
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

//埋点
- (void)trackOperationWithModel:(FHHouseMsgDataItemsItemsModel *)model index:(NSInteger)index trackName:(NSString *)trackName {
    if (!model) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"group_id"] = model.id;
    NSString *house_type = [[FHHouseTypeManager sharedInstance] traceValueForType:model.houseType.integerValue];
    tracerDict[@"house_type"] = house_type;
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
    if(section < self.dataList.count){
        FHHouseMsgDataItemsModel *model = self.dataList[section];
        if (self.listId == FHMessageTypeHouseReport) {
            if (model.content.length) {
                return 1;
            }
            return 0;
        }
        NSArray *houses = model.items;
        return [houses count];
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
    FHHouseMsgDataItemsItemsModel *itemsModel = nil;
    UITableViewCell *cell = nil;
    if (self.listId == FHMessageTypeHouseReport) {
        FHFeedbackMsgCell *msgCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHFeedbackMsgCell class]) forIndexPath:indexPath];
        msgCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [msgCell updateWithModel:model];
        [msgCell setPushURLBlock:^(NSString * _Nonnull URLString) {
            NSDictionary *logPb = model.logPb;
            NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
            tracerDict[@"card_type"] = @"left_pic";
            tracerDict[@"element_from"] = @"be_null";
            tracerDict[@"enter_from"] = [self.viewController categoryName];
            tracerDict[@"log_pb"] = logPb ? logPb : @"be_null";
            tracerDict[@"origin_search_id"] = self.originSearchId ? self.originSearchId : @"be_null";
            tracerDict[@"rank"] = @(indexPath.section);
           
            NSDictionary *dict = @{@"house_type":@(FHHouseTypeSecondHandHouse),
                                   @"tracer": tracerDict
                                   };
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL* url = [NSURL URLWithString:URLString];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }];
        cell = msgCell;
    } else {
        FHHouseMsgCell *msgCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHHouseMsgCell class]) forIndexPath:indexPath];
        msgCell.selectionStyle = UITableViewCellSelectionStyleNone;
        itemsModel = model.items[indexPath.row];
        [msgCell updateWithModel:itemsModel];
        cell = msgCell;
    }
    
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
    if (self.listId == FHMessageTypeHouseReport) {
        FHFeedbackMsgHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([FHFeedbackMsgHeaderView class])];
        if (!headerView) {
            headerView = [[FHFeedbackMsgHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        }
        FHHouseMsgDataItemsModel *model = self.dataList[section];
        headerView.dateLabel.text = model.dateStr;
        return headerView;
    } else {
        FHHouseHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([FHHouseHeaderView class])];
        if (!headerView) {
            headerView = [[FHHouseHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90)];
        }
        
        FHHouseMsgDataItemsModel *model = self.dataList[section];
        headerView.dateLabel.text = model.dateStr;
        headerView.contentLabel.text = model.title;
        if (model.isSoldout) {
            headerView.contentLabel.textColor = [UIColor themeGray3];
        }else {
            headerView.contentLabel.textColor = [UIColor themeGray1];
        }
        return headerView;
    }
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
            FHHouseMsgFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([FHHouseMsgFooterView class])];
            if (!footerView) {
                footerView = [[FHHouseMsgFooterView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 40)];
            }
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
        if (self.listId == FHMessageTypeHouseReport) {
            return UITableViewAutomaticDimension;
        }
        FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
        if(indexPath.row == model.items.count - 1){
            return 125;
        }
    }
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listId == FHMessageTypeHouseReport) {
        return;
    }
    FHHouseMsgDataItemsModel *model = self.dataList[indexPath.section];
    FHHouseMsgDataItemsItemsModel *itemsModel = model.items[indexPath.row];
    
    NSInteger houseType = [itemsModel.houseType integerValue];
    NSString *houseId = itemsModel.id;
    NSString *urlStr = @"";
    switch (houseType) {
        case FHHouseTypeNewHouse:
            urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",houseId];
            break;
        case FHHouseTypeSecondHandHouse:
            urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",houseId];
            break;
        case FHHouseTypeRentHouse:
            urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",houseId];
            break;
        case FHHouseTypeNeighborhood:
            urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",houseId];
            break;
            
        default:
            break;
    }
    
    NSString *section_row = [NSString stringWithFormat:@"%i_%i",indexPath.section,indexPath.row];
    NSInteger index = [_clientShowDict[section_row] integerValue];
    
    NSDictionary *logPb = itemsModel.logPb;
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"element_from"] = @"be_null";
    tracerDict[@"enter_from"] = [self.viewController categoryName];
    tracerDict[@"log_pb"] = logPb ? logPb : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? self.originSearchId : @"be_null";
    tracerDict[@"rank"] = @(index);
   
    NSDictionary *dict = @{@"house_type":@(houseType),
                           @"tracer": tracerDict
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

@end
