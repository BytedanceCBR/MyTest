//
//  FHHomeTableViewDelegate.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeTableViewDelegate.h"
#import "FHHomeBaseTableCell.h"
#import "FHHomeCellHelper.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FHHomeScrollBannerCell.h"
#import "FHHomeEntrancesCell.h"
#import "UIColor+Theme.h"
#import "FHHomeEntranceContainerCell.h"

@interface FHHomeTableViewDelegate()
{
}

@end

@implementation FHHomeTableViewDelegate

- (instancetype)initWithModels:(NSArray <JSONModel *>*)modelsArray
{
    if (self = [super init]) {
        _modelsArray = modelsArray;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modelsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSONModel *model = [_modelsArray objectAtIndex:indexPath.row];
    NSString *identifier = [FHHomeCellHelper configIdentifier:model];
    
    FHHomeBaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [FHHomeCellHelper configureCell:cell withJsonModel:model];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSONModel *model = [_modelsArray objectAtIndex:indexPath.row];
    NSString *identifier = [FHHomeCellHelper configIdentifier:model];
    if ([identifier isEqualToString:@"FHHomeScrollBannerCell"]) {
        // 单独计算行高
        return [FHHomeScrollBannerCell cellHeight];
    }
    
//    if ([identifier isEqualToString:@"FHHomeEntrancesCell"]) {
//        return [FHHomeEntrancesCell cellHeightForModel:model];
//    }
    if ([identifier isEqualToString:@"FHHomeEntranceContainerCell"]) {
        return [FHHomeEntranceContainerCell cellHeightForModel:model];
    }
    
//    [tableView fd_heightForCellWithIdentifier:identifier cacheByKey:identifier configuration:^(FHHomeBaseTableCell *cell) {
//        [FHHomeCellHelper configureCell:cell withJsonModel:model];
//    }];
//    return [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
