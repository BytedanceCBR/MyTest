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

@interface FHHomeMainTableViewDataSource () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation FHHomeMainTableViewDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        [FHHomeCellHelper sharedInstance].headerType = FHHomeHeaderCellPositionTypeForFindHouse;
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
            model = [[FHEnvContext sharedInstance] getConfigFromLocal];
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
            [cell refreshBottomMargin:isLastCell ? 20 : 0];
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFHHomeListHeaderBaseViewSection) {
        NSLog(@"header height = %f",[[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType]);
        return [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    }
    
    if (self.showPlaceHolder) {
        return 105;
    }
    /*
    JSONModel *model = [_modelsArray objectAtIndex:indexPath.row];
    NSString *identifier = [FHHomeCellHelper configIdentifier:model];
    [tableView fd_heightForCellWithIdentifier:identifier cacheByKey:identifier configuration:^(FHHomeBaseTableCell *cell) {
        [FHHomeCellHelper configureHomeListCell:cell withJsonModel:model];
    }];
    return [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
     */
    return 105;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    JSONModel *model = [_modelsArray objectAtIndex:indexPath.row];
//    [FHHomeCellHelper handleCellShowLogWithModel:model];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

@end
