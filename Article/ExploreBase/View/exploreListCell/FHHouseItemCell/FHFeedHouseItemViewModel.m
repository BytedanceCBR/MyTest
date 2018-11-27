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

#define kFHFeedHouseCellId @"kFHFeedHouseCellId"

@interface FHFeedHouseItemViewModel () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)UITableView *tableView;

@property(nonatomic, strong)FHExploreHouseItemData *houseItemsData;

@property(nonatomic, strong)NSMutableArray *cacheArray;

@end

@implementation FHFeedHouseItemViewModel

-(NSMutableArray *)cacheArray {
    
    if (!_cacheArray) {
        _cacheArray = @[].mutableCopy;
    }
    return _cacheArray;
}

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
    
    if (data != self.houseItemsData) {
        [self.cacheArray removeAllObjects];
    }
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
        
        NSString *searchId = self.houseItemsData.logPb[@"search_id"];
        [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];

        NSURL *url =[NSURL URLWithString:self.houseItemsData.loadmoreOpenUrl];
        TTRouteUserInfo *userInfo = nil;
//        if (neighborModel.logPb) {
//            NSString *groupId = neighborModel.logPb.groupId;
//            NSString *imprId = neighborModel.logPb.imprId;
//            NSString *searchId = neighborModel.logPb.searchId;
//            if (groupId) {
//                [strUrl appendFormat:@"&group_id=%@",groupId];
//            }
//            if (imprId) {
//                [strUrl appendFormat:@"&impr_id=%@",imprId];
//            }
//            if (searchId) {
//                [strUrl appendFormat:@"&search_id=%@",searchId];
//            }
//            NSDictionary *dict = @{@"log_pb":[neighborModel.logPb toDictionary]};
//            userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
//        }
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)showNewHouseDetailPage:(FHNewHouseItemModel *)houseModel
{
        // logpb处理
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:@"mix_list" forKey:@"origin_from"];
    NSString *searchId = self.houseItemsData.logPb[@"search_id"];
    [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];

    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?court_id=%@",houseModel.houseId];

    TTRouteUserInfo *userInfo = nil;
//    if (houseModel.logPb) {
//        NSString *groupId = neighborModel.logPb.groupId;
//        NSString *imprId = neighborModel.logPb.imprId;
//        NSString *searchId = neighborModel.logPb.searchId;
//        if (groupId) {
//            [strUrl appendFormat:@"&group_id=%@",groupId];
//        }
//        if (imprId) {
//            [strUrl appendFormat:@"&impr_id=%@",imprId];
//        }
//        if (searchId) {
//            [strUrl appendFormat:@"&search_id=%@",searchId];
//        }
//        NSDictionary *dict = @{@"log_pb":[neighborModel.logPb toDictionary]};
//        userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
//    }
//    if (self.configModel.originFrom) {
//        [strUrl appendFormat:@"&origin_from=%@",_configModel.originFrom];
//    }
//    if (_configModel.originSearchId) {
//        [strUrl appendFormat:@"&origin_search_id=%@",_configModel.originSearchId];
//    }
    if (strUrl.length  > 0) {
        
        NSURL *url =[NSURL URLWithString:strUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)showSecondHouseDetailPage:(FHSearchHouseDataItemsModel *)houseModel
{
        // logpb处理
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:@"mix_list" forKey:@"origin_from"];
    NSString *searchId = self.houseItemsData.logPb[@"search_id"];
    [contextBridge setTraceValue:(searchId ? : @"be_null") forKey:@"origin_search_id"];

    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@",houseModel.hid];
    
    TTRouteUserInfo *userInfo = nil;
    //    if (houseModel.logPb) {
    //        NSString *groupId = neighborModel.logPb.groupId;
    //        NSString *imprId = neighborModel.logPb.imprId;
    //        NSString *searchId = neighborModel.logPb.searchId;
    //        if (groupId) {
    //            [strUrl appendFormat:@"&group_id=%@",groupId];
    //        }
    //        if (imprId) {
    //            [strUrl appendFormat:@"&impr_id=%@",imprId];
    //        }
    //        if (searchId) {
    //            [strUrl appendFormat:@"&search_id=%@",searchId];
    //        }
    //        NSDictionary *dict = @{@"log_pb":[neighborModel.logPb toDictionary]};
    //        userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
    //    }
    //    if (self.configModel.originFrom) {
    //        [strUrl appendFormat:@"&origin_from=%@",_configModel.originFrom];
    //    }
    //    if (_configModel.originSearchId) {
    //        [strUrl appendFormat:@"&origin_search_id=%@",_configModel.originSearchId];
    //    }
    if (strUrl.length  > 0) {
        
        NSURL *url =[NSURL URLWithString:strUrl];
        [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)addHouseShowLogWithIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {
        
        param[@"house_type"] = @"new";
        FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
        // logpb处理
        param[@"log_pb"] = model.logPb ? : @"be_null";
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        param[@"house_type"] = @"old";
        FHSearchHouseDataItemsModel *model = self.houseItemsData.secondHouseList[indexPath.row];
        // logpb处理
        param[@"log_pb"] = model.logPb ? : @"be_null";
    }
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"maintab";
    param[@"element_type"] = @"mix_list";
    param[@"rank"] = @(indexPath.row);

    param[@"origin_from"] = @"mix_list";
    NSString *searchId = self.houseItemsData.logPb[@"search_id"];
    param[@"origin_search_id"] = searchId ? : @"be_null";

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
        
    }
    return 0;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {

        return self.houseItemsData.houseList.count;
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {

        return self.houseItemsData.secondHouseList.count;
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse || self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        if (indexPath.row == 0) {
            
            return 85;
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
            SEL sel = @selector(updateWithNewHouseModel:isFirstCell:isLastCell:);
            if ([cell respondsToSelector:sel]) {
                [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithNewHouseModel:model isFirstCell:isFirstCell isLastCell:isLastCell];
            }
        }
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {

        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {
            
            FHSearchHouseDataItemsModel *item = self.houseItemsData.secondHouseList[indexPath.row];
            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == self.houseItemsData.secondHouseList.count - 1);
            [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithSecondHouseModel:item isFirstCell:isFirstCell isLastCell:isLastCell];
            
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.houseItemsData.houseType.integerValue == FHHouseTypeNewHouse) {

        FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
        if (![self.cacheArray containsObject:model.houseId]) {
            
            [self.cacheArray addObject:model.houseId];
            [self addHouseShowLogWithIndexPath:indexPath];
        }
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {
        
        FHSearchHouseDataItemsModel *model = self.houseItemsData.secondHouseList[indexPath.row];
        if (![self.cacheArray containsObject:model.hid]) {

            [self.cacheArray addObject:model.hid];
            [self addHouseShowLogWithIndexPath:indexPath];
        }
    }
    
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
            
            FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
            [self showNewHouseDetailPage:model];

        }
        
    }else if (self.houseItemsData.houseType.integerValue == FHHouseTypeSecondHandHouse) {

        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {
            
            FHSearchHouseDataItemsModel *model = self.houseItemsData.secondHouseList[indexPath.row];
            [self showSecondHouseDetailPage:model];

        }
    }
    
}


@end
