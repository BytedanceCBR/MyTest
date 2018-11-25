//
//  FHHomeTableViewDelegate.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeTableViewDelegate.h"
#import "FHHomeBaseTableCell.h"
#import "FHHomeCellHelper.h"
#import <UITableView+FDTemplateLayoutCell.h>

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
    CGFloat height = [tableView fd_heightForCellWithIdentifier:identifier cacheByKey:identifier configuration:^(FHHomeBaseTableCell *cell) {
        [FHHomeCellHelper configureCell:cell withJsonModel:model];
    }];
    NSLog(@"cell height = %f",height);
    return [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
}

@end
