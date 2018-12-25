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

static const NSUInteger kFHHomeListHeaderBaseViewSection = 0;
static const NSUInteger kFHHomeListHouseBaseViewSection = 1;


@interface FHHomeMainTableViewDataSource () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation FHHomeMainTableViewDataSource

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kFHHomeListHeaderBaseViewSection) {
        return 1;
    }
    return 10;
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
        return [UITableViewCell new];
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
    return 35;
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
