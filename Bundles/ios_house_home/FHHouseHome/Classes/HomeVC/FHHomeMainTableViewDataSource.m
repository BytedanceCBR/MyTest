//
//  FHHomeMainTableViewDataSource.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeMainTableViewDataSource.h"
#import "FHHomeBaseTableCell.h"
#import "FHHomeCellHelper.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "FHPlaceHolderCell.h"
#import "FHEnvContext.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseRentModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseType.h"
#import "TTRoute.h"
#import "FHHomeConfigManager.h"

@interface FHHomeMainTableViewDataSource () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSMutableDictionary *traceRecordDict;
@end

@implementation FHHomeMainTableViewDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        [FHHomeCellHelper sharedInstance].headerType = FHHomeHeaderCellPositionTypeForFindHouse;
        self.traceRecordDict = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kFHHomeListHeaderBaseViewSection) {
        return 1;
    }
    if (self.showPlaceHolder) {
        return 10;
    }
    return _modelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFHHomeListHeaderBaseViewSection) {
        JSONModel *model = [[FHEnvContext sharedInstance] getConfigFromCache];
        if (!model) {
            model = [[FHEnvContext sharedInstance] readConfigFromLocal];
        }
        NSString *identifier = [FHHomeCellHelper configIdentifier:model];
        
        FHHomeBaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [FHHomeCellHelper configureHomeListCell:cell withJsonModel:model];
        return cell;
    }else
    {
        if (self.showPlaceHolder) {
            FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
            return cell;
        }
        //to do 房源cell
        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHSingleImageInfoCell class])];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.modelsArray.count - 1);
        if (indexPath.row < self.modelsArray.count) {
            JSONModel *model = self.modelsArray[indexPath.row];
            [cell updateHomeHouseCellModel:model andType:self.currentHouseType];
            [cell refreshTopMargin: 20];
            [cell refreshBottomMargin:0];
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFHHomeListHeaderBaseViewSection) {
        return [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    }
    
    if (self.showPlaceHolder) {
        return 105;
    }
    return 105;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FHHomeHouseDataItemsModel *cellModel = [_modelsArray objectAtIndex:indexPath.row];
     if (cellModel.idx && [self.traceRecordDict objectForKey:cellModel.idx] != nil)
     {
         return;
     }else
     {
         if (cellModel.idx) {
             [self.traceRecordDict setValue:@"" forKey:cellModel.idx];

             NSString *originFrom = [FHEnvContext sharedInstance].getCommonParams.originFrom ? : @"be_null";
             
             NSMutableDictionary *tracerDict = [NSMutableDictionary new];
             tracerDict[@"house_type"] = [self houseTypeString] ? : @"be_null";
             tracerDict[@"card_type"] = @"left_pic";
             tracerDict[@"page_type"] = [self pageTypeString];
             tracerDict[@"element_type"] = @"maintab_list";
             tracerDict[@"group_id"] = cellModel.idx ? : @"be_null";
             tracerDict[@"impr_id"] = cellModel.imprId ? : @"be_null";
             tracerDict[@"search_id"] = cellModel.searchId ? : @"";
             tracerDict[@"rank"] = @(indexPath.row);
             tracerDict[@"origin_from"] = [self pageTypeString];
             tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
             tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";
             
             [FHEnvContext recordEvent:tracerDict andEventKey:@"house_show"];
         }
     }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self jumpToDetailPage:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == kFHHomeListHeaderBaseViewSection) {
        return nil;
    }
    return self.categoryView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == kFHHomeListHeaderBaseViewSection) {
        return 0;
    }
    return kFHHomeHeaderViewSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - 详情页跳转
-(void)jumpToDetailPage:(NSIndexPath *)indexPath {
    
    if (self.modelsArray.count > indexPath.row) {
        FHHomeHouseDataItemsModel *theModel = self.modelsArray[indexPath.row];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"enter_from"] = [self pageTypeString];
        traceParam[@"element_from"] = @"be_null";
        traceParam[@"log_pb"] = theModel.logPb;
        traceParam[@"origin_from"] = [self pageTypeString];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        
        NSDictionary *dict = @{@"house_type":@(self.currentHouseType) ,
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *jumpUrl = nil;
        
        if (self.currentHouseType == FHHouseTypeSecondHandHouse) {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.idx]];
        }else if(self.currentHouseType == FHHouseTypeNewHouse)
        {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.idx]];
        }else if(self.currentHouseType == FHHouseTypeRentHouse)
        {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.idx]];
        }
        
        if (jumpUrl != nil) {
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
    
}

-(NSString *)pageTypeString {
    
    switch (self.currentHouseType) {
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)enterFromTypeString {
    
    switch (self.currentHouseType) {
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)houseTypeString {
    
    switch (self.currentHouseType) {
        case FHHouseTypeNewHouse:
            return @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old";
            break;
        case FHHouseTypeRentHouse:
            return @"rent";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)elementTypeString {
    
    return @"be_null";
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > MAIN_SCREENH_HEIGHT) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }else
    {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:NO];
    }
}

@end
