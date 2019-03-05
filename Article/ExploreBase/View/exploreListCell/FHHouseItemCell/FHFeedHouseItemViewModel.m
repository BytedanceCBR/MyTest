//
//  FHFeedHouseItemViewModel.m
//  Article
//
//  Created by 张静 on 2018/11/21.
//

#import "FHFeedHouseItemViewModel.h"
#import "FHExploreHouseItemData.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "FHFeedHouseFooterView.h"
#import "TTRoute.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseRentModel.h"
#import "FHFeedHouseCellHelper.h"
#import <FHSingleImageInfoCell.h>
#import <FHSingleImageInfoCellModel.h>

#define kFHFeedHouseCellId @"kFHFeedHouseCellId"

@interface FHFeedHouseItemViewModel () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)UITableView *tableView;

@property(nonatomic, strong)FHExploreHouseItemData *houseItemsData;

@end

@implementation FHFeedHouseItemViewModel



-(instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        [self configTableView];
        
    }
    return self;
    
}

-(void)setHeaderView:(FHFeedHouseHeaderView *)headerView {
    
    _headerView = headerView;
    
}

-(void)setFooterView:(FHFeedHouseFooterView *)footerView {
    
    _footerView = footerView;
    [_footerView addTarget:self action:@selector(loadMoreBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateWithHouseData:(FHExploreHouseItemData *_Nullable)data {
    
//    if (data != self.houseItemsData) {
//        [self.cacheArray removeAllObjects];
//    }
    self.houseItemsData = data;

    [self.headerView updateTitle: self.houseItemsData.title];
    [self.footerView updateTitle: self.houseItemsData.loadmoreButton];
    [self.tableView reloadData];
    
}

-(void)configTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    id<FHHouseCellsBridge> bridge =  [[FHHouseBridgeManager sharedInstance] cellsBridge];
    Class cellClass = [bridge singleImageCellClass];
    [_tableView registerClass:cellClass forCellReuseIdentifier:kFHFeedHouseCellId];
}



-(void)loadMoreBtnDidClick:(UIControl *)control {
    
    if (self.houseItemsData.loadmoreOpenUrl.length > 0) {
        
        // logpb处理
        id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
        [contextBridge setTraceValue:@"mixlist_loadmore" forKey:@"origin_from"];

        NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];

        [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];
        
        NSURL *url =[NSURL URLWithString:self.houseItemsData.loadmoreOpenUrl];

        TTRouteUserInfo *userInfo = nil;
        NSMutableDictionary *param = @{}.mutableCopy;
        param[@"enter_from"] = @"maintab";
        param[@"enter_type"] = @"click";
        param[@"element_from"] = @"maintab_mixlist";
        param[@"search_id"] = searchId;
        param[@"origin_from"] = @"mixlist_loadmore";
        param[@"origin_search_id"] = searchId ? : @"be_null";

        if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
            param[@"category_name"] = @"new_list";

        }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
            param[@"category_name"] = @"old_list";

        }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
            param[@"category_name"] = @"rent_list";

        }
        NSDictionary *userDict = @{@"tracer":param};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:userDict];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)showNewHouseDetailPage:(NSIndexPath *)indexPath
{
    FHNewHouseItemModel *houseModel = self.houseItemsData.houseList[indexPath.row];

        // logpb处理
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:@"mix_list" forKey:@"origin_from"];
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?court_id=%@&house_type=%@",houseModel.houseId,[houseModel.houseType isKindOfClass:[NSString class]] ? houseModel.houseType: @"1"];
    
    TTRouteUserInfo *userInfo = nil;
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"house_type"] = @"new";
    param[@"log_pb"] = houseModel.logPb ? : @"be_null";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"enter_from"] = @"maintab";
    param[@"element_from"] = @"mix_list";
    param[@"rank"] = @(indexPath.row);
    
    param[@"origin_from"] = @"mix_list";
    param[@"origin_search_id"] = searchId ? : @"be_null";
    
    if (houseModel.logPb.count > 0) {
        
        param[@"search_id"] = houseModel.logPb[@"search_id"] ? : @"be_null";
    }
    if (houseModel.logPb) {
        
        param[@"log_pb"] = houseModel.logPb;
        
    }
    NSDictionary *userDict = @{@"tracer":param};
    userInfo = [[TTRouteUserInfo alloc]initWithInfo:userDict];
    if (strUrl.length  > 0) {
        
        NSURL *url =[NSURL URLWithString:strUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)showSecondHouseDetailPage:(NSIndexPath *)indexPath
{
    
    FHSearchHouseDataItemsModel *houseModel = self.houseItemsData.secondHouseList[indexPath.row];
        // logpb处理

    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:@"mix_list" forKey:@"origin_from"];
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@&house_type=%@",houseModel.hid,[houseModel.houseType isKindOfClass:[NSString class]] ? houseModel.houseType: @"2"];
    
    TTRouteUserInfo *userInfo = nil;
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"house_type"] = @"old";
    param[@"log_pb"] = houseModel.logPb ? : @"be_null";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"enter_from"] = @"maintab";
    param[@"element_from"] = @"mix_list";
    param[@"rank"] = @(indexPath.row);
    
    if (houseModel.logPb.count > 0) {
        
        param[@"search_id"] = houseModel.logPb[@"search_id"] ? : @"be_null";
    }
    param[@"origin_from"] = @"mix_list";
    param[@"origin_search_id"] = searchId ? : @"be_null";

    if (houseModel.logPb) {
        
        param[@"log_pb"] = houseModel.logPb;

    }
    NSDictionary *userDict = @{@"tracer":param};
    userInfo = [[TTRouteUserInfo alloc]initWithInfo:userDict];
    if (strUrl.length  > 0) {
        
        NSURL *url =[NSURL URLWithString:strUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)showRentHouseDetailPage:(NSIndexPath *)indexPath
{
    
    FHHouseRentDataItemsModel *houseModel = self.houseItemsData.rentHouseList[indexPath.row];
    
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:@"mix_list" forKey:@"origin_from"];
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://rent_detail?house_id=%@&house_type=%@",houseModel.id,[houseModel.houseType isKindOfClass:[NSString class]] ? houseModel.houseType: @"3"];
    
    TTRouteUserInfo *userInfo = nil;
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"house_type"] = @"rent";
    param[@"log_pb"] = houseModel.logPb ? : @"be_null";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"enter_from"] = @"maintab";
    param[@"element_from"] = @"mix_list";
    param[@"rank"] = @(indexPath.row);
    
    if (houseModel.logPb.count > 0) {
        
        param[@"search_id"] = houseModel.logPb[@"search_id"] ? : @"be_null";
    }
    param[@"origin_from"] = @"mix_list";
    param[@"origin_search_id"] = searchId ? : @"be_null";
    
    if (houseModel.logPb) {
        
        param[@"log_pb"] = houseModel.logPb;
        
    }
    NSDictionary *userDict = @{@"tracer":param};
    userInfo = [[TTRouteUserInfo alloc]initWithInfo:userDict];
    if (strUrl.length  > 0) {
        
        NSURL *url =[NSURL URLWithString:strUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}


-(void)addHouseShowLog {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        
        for (NSInteger index = 0; index < self.houseItemsData.houseList.count; index++) {
            
            FHNewHouseItemModel *model = self.houseItemsData.houseList[index];
            if (![[FHFeedHouseCellHelper sharedInstance].houseCache objectForKey:model.houseId]) {
                
                [self addNewHouseShowLogWithIndex:index model:model];
                [[FHFeedHouseCellHelper sharedInstance] addHouseCache:model.houseId];
            }
            
        }
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        for (NSInteger index = 0; index < self.houseItemsData.secondHouseList.count; index++) {
            
            FHSearchHouseDataItemsModel *model = self.houseItemsData.secondHouseList[index];
            if (![[FHFeedHouseCellHelper sharedInstance].houseCache objectForKey:model.hid]) {

                [self addSecondHouseShowLogWithIndex:index model:model];
                [[FHFeedHouseCellHelper sharedInstance] addHouseCache:model.hid];
            }
            
        }

    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        
        for (NSInteger index = 0; index < self.houseItemsData.rentHouseList.count; index++) {
            
            FHHouseRentDataItemsModel *model = self.houseItemsData.rentHouseList[index];
            if (![[FHFeedHouseCellHelper sharedInstance].houseCache objectForKey:model.id]) {

                [self addRentHouseShowLogWithIndex:index model:model];
                [[FHFeedHouseCellHelper sharedInstance] addHouseCache:model.id];
            }
            
        }
    }
    
}

-(void)addNewHouseShowLogWithIndex:(NSInteger )index model:(FHNewHouseItemModel *)model {

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] = @"new";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"element_type"] = @"mix_list";
    param[@"group_id"] = model.houseId;
    param[@"impr_id"] = model.imprId;
    param[@"search_id"] = model.searchId;

    param[@"rank"] = @(index);
    
    param[@"origin_from"] = @"mix_list";
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    param[@"origin_search_id"] = searchId ? : @"be_null";
    param[@"log_pb"] = model.logPb ? : @"be_null";

    [FHUserTracker writeEvent:@"house_show" params:param];
    
}

-(void)addSecondHouseShowLogWithIndex:(NSInteger )index model:(FHSearchHouseDataItemsModel *)model {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] = @"old";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"element_type"] = @"mix_list";
    param[@"group_id"] = model.hid;
    param[@"impr_id"] = model.imprId;
    param[@"search_id"] = model.searchId;
    param[@"rank"] = @(index);
    
    param[@"origin_from"] = @"mix_list";
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    param[@"origin_search_id"] = searchId ? : @"be_null";
    param[@"log_pb"] = model.logPb ? : @"be_null";

    [FHUserTracker writeEvent:@"house_show" params:param];
}


-(void)addRentHouseShowLogWithIndex:(NSInteger )index model:(FHHouseRentDataItemsModel *)model {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] = @"rent";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"element_type"] = @"mix_list";
    param[@"group_id"] = model.id;
    param[@"impr_id"] = model.imprId;
    param[@"search_id"] = model.searchId;
    param[@"rank"] = @(index);
    
    param[@"origin_from"] = @"mix_list";
    NSString *searchId = self.houseItemsData.searchId ? : self.houseItemsData.logPb[@"search_id"];
    param[@"origin_search_id"] = searchId ? : @"be_null";
    param[@"log_pb"] = model.logPb ? : @"be_null";

    [FHUserTracker writeEvent:@"house_show" params:param];
    
}

#pragma mark - tableView dataSource & delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        if (self.houseItemsData.houseList.count < 1) {
            return 0;
        }
        return 1;
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        if (self.houseItemsData.secondHouseList.count < 1) {
            return 0;
        }
        return 1;
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        if (self.houseItemsData.rentHouseList.count < 1) {
            return 0;
        }
        return 1;
        
    }
    return 0;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        
        return self.houseItemsData.houseList.count;
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        return self.houseItemsData.secondHouseList.count;
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        
        return self.houseItemsData.rentHouseList.count;
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse || self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse || self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        if (indexPath.row == 0) {

            return 91;
        }
        
        if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
            
            return indexPath.row == self.houseItemsData.houseList.count - 1 ? 125 : 105;
            
        }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
            
            FHSearchHouseDataItemsModel *item = self.houseItemsData.secondHouseList[indexPath.row];
            CGFloat reasonHeight = [item showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
            
            return (indexPath.row == self.houseItemsData.secondHouseList.count - 1 ? 125 : 105)+reasonHeight;
            
        }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
            
            return indexPath.row == self.houseItemsData.rentHouseList.count - 1 ? 125 : 105;
            
        }
        
        return 105;
        
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHFeedHouseCellId];
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        
        if (self.houseItemsData.houseList.count > 0 && indexPath.row < self.houseItemsData.houseList.count) {
            
            FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == self.houseItemsData.houseList.count - 1);
//            SEL sel = @selector(updateWithNewHouseModel:isFirstCell:isLastCell:);
//            if ([cell respondsToSelector:sel]) {
//                [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithNewHouseModel:model isFirstCell:isFirstCell isLastCell:isLastCell];
//            }
            if ([cell isKindOfClass:[FHSingleImageInfoCell class]]) {
                FHSingleImageInfoCellModel *infoCellModel = [FHSingleImageInfoCellModel new];
                infoCellModel.houseModel = model;
                [(FHSingleImageInfoCell *)cell updateWithHouseCellModel:infoCellModel andIsFirst:isFirstCell andIsLast:isLastCell];
            }
        }
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {
            
            FHSearchHouseDataItemsModel *item = self.houseItemsData.secondHouseList[indexPath.row];
            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == self.houseItemsData.secondHouseList.count - 1);
            if ([cell isKindOfClass:[FHSingleImageInfoCell class]]) {
                FHSingleImageInfoCellModel *infoCellModel = [FHSingleImageInfoCellModel new];
                infoCellModel.secondModel = item;
                [(FHSingleImageInfoCell *)cell updateWithHouseCellModel:infoCellModel andIsFirst:isFirstCell andIsLast:isLastCell];
//                [(FHSingleImageInfoCell *)cell refreshTopMargin: 20];
//                [(FHSingleImageInfoCell *)cell refreshBottomMargin:isLastCell ? 20 : 0];
            }
//            [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithSecondHouseModel:item isFirstCell:isFirstCell isLastCell:isLastCell];
            
        }
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        
        FHHouseRentDataItemsModel *item = self.houseItemsData.rentHouseList[indexPath.row];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.houseItemsData.secondHouseList.count - 1);
//        [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithRentHouseModel:item isFirstCell:isFirstCell isLastCell:isLastCell];
        if ([cell isKindOfClass:[FHSingleImageInfoCell class]]) {
            FHSingleImageInfoCellModel *infoCellModel = [FHSingleImageInfoCellModel new];
            infoCellModel.rentModel = item;
            [(FHSingleImageInfoCell *)cell updateWithHouseCellModel:infoCellModel andIsFirst:isFirstCell andIsLast:isLastCell];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        
        if (self.houseItemsData.houseList.count > 0 && indexPath.row < self.houseItemsData.houseList.count) {
            
            [self showNewHouseDetailPage:indexPath];
        }
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {
            
            [self showSecondHouseDetailPage:indexPath];

        }
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeRentHouse) {
        
        if (self.houseItemsData.rentHouseList.count > 0 && indexPath.row < self.houseItemsData.rentHouseList.count) {
            
            [self showRentHouseDetailPage:indexPath];
            
        }
    }
    
}


@end
