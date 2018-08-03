
#import "TTDataSource.h"
#import "TTBaseCellEntity.h"
#import "TTBaseCell.h"

@implementation TTDataSource

- (TTBaseCellEntity *)cellEntity:(id)aItem indexPath:(NSIndexPath *)indexPath
{
    TTBaseCellEntity *entity = [[TTBaseCellEntity alloc] init];
    entity.cellClass = [TTBaseCell class];
    entity.heightOfCell = [TTBaseCell cellHeightWithEntity:entity indexPath:indexPath];
    return entity;
}

- (NSArray *)cellEntityArray:(NSArray *)items
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger index = 0;
    for (id item in items) {
        TTBaseCellEntity *entity = [self cellEntity:item indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (entity) {
            [array addObject:entity];
        }
        index++;
    }
    return array;
}


- (void)updateFirstPageDataArray:(NSArray *)dataArray
{
    if (self.isTableReloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFirstPageDataArray:dataArray];
        });
    }
    [self.dataList setArray:dataArray];
    NSArray *temp = [self cellEntityArray:dataArray];
    [self.cellDataArray setArray:temp];
    [self reloadTableView];
}

- (void)reloadTableView
{
    self.isTableReloading = YES;
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTableReloading = NO;
    });
}

- (NSMutableArray *)addItems:(NSArray *)items atIndex:(NSInteger)index
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (id item in items) {
        TTBaseCellEntity *entity = [self cellEntity:item indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (entity) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            [self.dataList insertObject:item atIndex:index];
            [self.cellDataArray insertObject:entity atIndex:index];
        }
        index++;
    }
    return indexPaths;
}

- (void)updateMorePageDataArray:(NSArray *)dataArray atIndex:(NSInteger)index
{
    if (self.isTableReloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateMorePageDataArray:dataArray atIndex:index];
        });
    }

    if ([dataArray isKindOfClass:[NSArray class]])
    {
        for (id item in dataArray) {
            TTBaseCellEntity *entity = [self cellEntity:item indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (entity) {
                [self.dataList addObject:entity];
                [self.cellDataArray addObject:entity];
            }
        }
        [self reloadTableView];
    }
}

- (void)updateMorePageDataArray:(NSArray *)dataArray
{
    [self updateMorePageDataArray:dataArray atIndex:self.cellDataArray.count];
}

- (void)removeCellAtIndexPath:(NSArray <NSIndexPath *> *)indexPaths animation:(UITableViewRowAnimation)animation
{
    if (indexPaths.count <= 0) {
        return;
    }
    if (self.isTableReloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeCellAtIndexPath:indexPaths animation:animation];
        });
    }
    NSInteger maxIndex = 0;
    NSInteger minIndex = 0;
    for (NSIndexPath *indexPath in indexPaths) {
        NSUInteger index = indexPath.row;
        [self.dataList removeObjectAtIndex:index];
        [self.cellDataArray removeObjectAtIndex:index];
        maxIndex = MAX(index, maxIndex);
        minIndex = MIN(minIndex, index);
    }

    if (maxIndex < self.dataList.count && minIndex >= 0) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)updateDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexs withDataArray:(NSArray *)dataArray
{
    if (self.isTableReloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDataAtIndexPaths:indexs withDataArray:dataArray];
        });
    }
    if ([indexs isKindOfClass:[NSArray class]] && [dataArray isKindOfClass:[NSArray class]] && indexs.count == dataArray.count) {
        NSMutableArray<NSIndexPath *> *reloadPaths = [NSMutableArray array];
        for (int i = 0; i < indexs.count; i++) {
            if ([indexs[i] isKindOfClass:[NSIndexPath class]]) {
                NSInteger index = [indexs[i] row];
                if (index < self.dataList.count && index < self.cellDataArray.count) {
                    TTBaseCellEntity *entity = [self cellEntity:dataArray[i] indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    if (entity) {
                        [self.dataList replaceObjectAtIndex:index withObject:entity];
                        [self.cellDataArray replaceObjectAtIndex:index withObject:entity];
                        
                        [reloadPaths addObject:indexs[i]];
                    }
                }
            }
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:reloadPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

@end
