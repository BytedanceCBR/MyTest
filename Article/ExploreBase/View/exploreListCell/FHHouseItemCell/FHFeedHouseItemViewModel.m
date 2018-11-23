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

#pragma mark - tableView dataSource & delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([self.houseItemsData.houseType isEqualToString:@"1"]) {
        if (self.houseItemsData.houseList.count < 1) {
            return 0;
        }
        return 1;

    }else if ([self.houseItemsData.houseType isEqualToString:@"2"]) {
        if (self.houseItemsData.secondHouseList.count < 1) {
            return 0;
        }
        return 1;

    }
    return 0;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([self.houseItemsData.houseType isEqualToString:@"1"]) {

        return self.houseItemsData.houseList.count;

    }else if ([self.houseItemsData.houseType isEqualToString:@"2"]) {

        return self.houseItemsData.secondHouseList.count;

    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.houseItemsData.houseType isEqualToString:@"1"] || [self.houseItemsData.houseType isEqualToString:@"2"]) {
        if (indexPath.row == 0) {

            return 85;
        }
        return 105;

    }
    return 0;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHFeedHouseCellId];
    if ([self.houseItemsData.houseType isEqualToString:@"1"]) {

        if (self.houseItemsData.houseList.count > 0 && indexPath.row < self.houseItemsData.houseList.count) {

            FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == self.houseItemsData.houseList.count - 1);
            SEL sel = @selector(updateWithNewHouseModel:isFirstCell:isLastCell:);
            if ([cell respondsToSelector:sel]) {
                [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithNewHouseModel:model isFirstCell:isFirstCell isLastCell:isLastCell];
            }
        }

    }else if ([self.houseItemsData.houseType isEqualToString:@"2"]) {

        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {

            FHSearchHouseDataItemsModel *item = self.houseItemsData.secondHouseList[indexPath.row];
            BOOL isFirstCell = (indexPath.row == 0);
            BOOL isLastCell = (indexPath.row == self.houseItemsData.secondHouseList.count - 1);
            [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithSecondHouseModel:item isFirstCell:isFirstCell isLastCell:isLastCell];

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
    if ([self.houseItemsData.houseType isEqualToString:@"1"]) {

        if (self.houseItemsData.houseList.count > 0 && indexPath.row < self.houseItemsData.houseList.count) {

            FHNewHouseItemModel *model = self.houseItemsData.houseList[indexPath.row];
            [self showNewHouseDetailPage:model];

        }

    }else if ([self.houseItemsData.houseType isEqualToString:@"2"]) {

        if (self.houseItemsData.secondHouseList.count > 0 && indexPath.row < self.houseItemsData.secondHouseList.count) {

            FHSearchHouseDataItemsModel *model = self.houseItemsData.secondHouseList[indexPath.row];
            [self showSecondHouseDetailPage:model];

        }
    }

}


@end
