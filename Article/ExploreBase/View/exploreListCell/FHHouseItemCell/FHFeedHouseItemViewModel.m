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
    self.tableView.tableHeaderView = _headerView;
}

-(void)setFooterView:(FHFeedHouseFooterView *)footerView {
    
    _footerView = footerView;
    self.tableView.tableFooterView = _footerView;
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

-(void)showHouseDetailPage:(FHSearchHouseDataItemsModel *)houseModel
{
    NSMutableString *strUrl;
    if ([houseModel.houseType isEqualToString:@"1"]) {
        strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?court_id=%@",houseModel.hid];

    } else if ([houseModel.houseType isEqualToString:@"2"]) {
        strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@",houseModel.hid];

    } else if ([houseModel.houseType isEqualToString:@"4"]) {
        strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?neighborhood_id=%@",houseModel.hid];
    }

//    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?neighborhood_id=%@&card_type=no_pic&enter_from=mapfind&element_from=half_category&rank=0",houseModel.hid];
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
    
    if (self.houseItemsData.houseItemList.count < 1) {
        return 0;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.houseItemsData.houseItemList.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHFeedHouseCellId];
    
    SEL sel = @selector(updateWithModel:isLastCell:);
    if ([cell respondsToSelector:sel]) {
        if (self.houseItemsData.houseItemList.count > 0 && indexPath.row < self.houseItemsData.houseItemList.count) {
            
            FHSearchHouseDataItemsModel *item = self.houseItemsData.houseItemList[indexPath.row];
            BOOL isLastCell = (indexPath.row == self.houseItemsData.houseItemList.count - 1);
            [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithModel:item isLastCell:isLastCell];
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
    if (self.houseItemsData.houseItemList.count > 0 && indexPath.row < self.houseItemsData.houseItemList.count) {

        FHSearchHouseDataItemsModel *model = self.houseItemsData.houseItemList[indexPath.row];
        [self showHouseDetailPage:model];
    }
}


@end
