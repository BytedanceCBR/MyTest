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
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHSingleImageInfoCellModel.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseRentModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseType.h"
#import "TTRoute.h"
#import "FHHomeConfigManager.h"
#import "TTArticleCategoryManager.h"
#import <FHErrorView.h>
#import <TTDeviceHelper.h>

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
    
    if (self.showNoDataErrorView)
    {
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
        
        if (self.showNoDataErrorView) {
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            
            [noDataErrorView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImageName:@"group-9"
                                    showRetry:NO];
            
            return cellError;
        }
        
        
        if (self.showPlaceHolder) {
            FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
            return cell;
        }
        
        //to do 房源cell
        FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHHouseBaseItemCell class])];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.modelsArray.count - 1);
        if (indexPath.row < self.modelsArray.count) {
            JSONModel *model = self.modelsArray[indexPath.row];
            [cell refreshTopMargin: 20];
            [cell updateHomeHouseCellModel:model andType:self.currentHouseType];            
        }
        return cell;
    }
}

- (CGFloat)getHeightShowNoData
{
    if([TTDeviceHelper isScreenWidthLarge320])
    {
        return [UIScreen mainScreen].bounds.size.height * 0.45;
    }else
    {
        return [UIScreen mainScreen].bounds.size.height * 0.65;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFHHomeListHeaderBaseViewSection) {
        [FHHomeCellHelper sharedInstance].headerType = FHHomeHeaderCellPositionTypeForFindHouse;
        return [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    }
    
    if (self.showNoDataErrorView)
    {
        return [self getHeightShowNoData];
    }
    
    if (self.showPlaceHolder) {
        return 105;
    }
    
    return 105;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_modelsArray.count <= indexPath.row) {
        return;
    }
    FHHomeHouseDataItemsModel *cellModel = [_modelsArray objectAtIndex:indexPath.row];
     if (cellModel.idx && ![self.traceRecordDict objectForKey:cellModel.idx])
     {
         if (cellModel.idx && self.isHasFindHouseCategory) {
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
             [tracerDict removeObjectForKey:@"element_from"];
             [FHEnvContext recordEvent:tracerDict andEventKey:@"house_show"];
         }
     }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {
        [self jumpToDetailPage:indexPath];
    }
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
        traceParam[@"log_pb"] = theModel.logPb;
        traceParam[@"origin_from"] = [self pageTypeString];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        traceParam[@"element_from"] = @"maintab_list";
        traceParam[@"enter_from"] = @"maintab";
        
        NSInteger houseType = 0;
        if ([theModel.houseType isKindOfClass:[NSString class]]) {
            houseType = [theModel.houseType integerValue];
        }
        
        if (houseType != 0) {
            if (houseType != self.currentHouseType) {
                return;
            }
        }else
        {
            houseType = self.currentHouseType;
        }
        
        
        NSDictionary *dict = @{@"house_type":@(houseType),
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *jumpUrl = nil;
        
        if (houseType == FHHouseTypeSecondHandHouse) {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.idx]];
        }else if(houseType == FHHouseTypeNewHouse)
        {
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.idx]];
        }else if(houseType == FHHouseTypeRentHouse)
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

- (void)resetTraceCahce
{
    [self.traceRecordDict removeAllObjects];
}
@end
