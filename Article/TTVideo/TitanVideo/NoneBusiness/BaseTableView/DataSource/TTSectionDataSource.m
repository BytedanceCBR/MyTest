
#import "TTSectionDataSource.h"
#import "TTBaseCellEntity.h"
#import "TTBaseCell.h"
#import "TTSectionView.h"
@implementation TTSectionDataSource
@dynamic delegate;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.editingStyle = UITableViewCellEditingStyleNone;
    }
    return self;
}
- (TTSectionEntity *)sectionCellEntityWithSection:(NSInteger)section
{
    TTSectionEntity *entity = [self.cellDataArray objectAtIndex:section];
    if ([entity isKindOfClass:[TTSectionEntity class]]) {
        return entity;
    }
    return nil;
}

#pragma mark - UITableViewDataSource

- (TTBaseCellEntity *)cellEntityWithIndexPath:(NSIndexPath *)path
{
    return [[self sectionCellEntityWithSection:path.section].items objectAtIndex:path.row];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TTSectionViewEntity *entity = [self sectionCellEntityWithSection:section].sectionData;
    TTSectionView *view = [[entity.sectionClass alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, entity.heightOfSection)];
    view.cellEntity = entity;
    [view renderView];
    [view fillContent];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.cellDataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self sectionCellEntityWithSection:section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self sectionCellEntityWithSection:section].sectionData.heightOfSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return [self sectionCellEntityWithSection:section].sectionData.heightOfFooter;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self sectionCellEntityWithSection:section].sectionData.headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [self sectionCellEntityWithSection:section].sectionData.footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTSectionEntity *entity = [self sectionCellEntityWithSection:indexPath.section];
    TTBaseCellEntity *cellEntity = [entity.items objectAtIndex:indexPath.row];
    return cellEntity.heightOfCell;
}

#pragma mark - super

- (TTBaseCellEntity *)cellEntity:(id)aItem indexPath:(NSIndexPath *)indexPath
{
    if ([aItem isKindOfClass:[TTBaseCellEntity class]]) {
        return aItem;
    }
    return nil;
}

- (TTSectionViewEntity *)sectionViewEntity:(id)item section:(NSInteger)section
{
    if ([item isKindOfClass:[TTSectionViewEntity class]]) {
        return item;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowWithCellEntity:)]) {
        if ([[self.cellDataArray objectAtIndex:0] isKindOfClass:[NSArray class]]) {
            NSArray *array = [self.cellDataArray objectAtIndex:indexPath.section];
            [self.delegate tableView:tableView didSelectRowWithCellEntity:[array objectAtIndex:indexPath.section]];
        }
        else
        {
            if ([[self.cellDataArray objectAtIndex:0] isKindOfClass:[TTSectionEntity class]]) {
                TTSectionEntity *section = [self.cellDataArray objectAtIndex:indexPath.section];
                [self.delegate tableView:tableView didSelectRowWithCellEntity:[section.items objectAtIndex:indexPath.row]];
            }

        }
        
    }
}

- (void)reloadTableView
{
    self.isTableReloading = YES;
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTableReloading = NO;
    });
}

- (void)updateFirstPageDataArray:(NSArray *)dataArray{

    if (self.isTableReloading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFirstPageDataArray:dataArray];
        });
    }

    [self.dataList removeAllObjects];
    [self.cellDataArray removeAllObjects];
    
    [dataArray enumerateObjectsUsingBlock:^(TTSectionEntity *entity, NSUInteger section, BOOL *stop) {
        if ([entity isKindOfClass:[TTSectionEntity class]]) {
            [self.dataList addObject:entity];
            entity.sectionData = [self sectionViewEntity:entity.sectionData section:section];
            NSMutableArray *array = [NSMutableArray array];
            [entity.items enumerateObjectsUsingBlock:^(id obj, NSUInteger row, BOOL *aStop) {
                TTBaseCellEntity *aEntity = [self cellEntity:obj indexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                [array addObject:aEntity];
            }];
            entity.items = array;
            [self.cellDataArray addObject:entity];
        }
        else
        {
//                NSLog(@"数据格式不对,必需是NBSectionCellEntity");
        }
    }];

}
- (void)updateDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexs withDataArray:(NSArray *)dataArray{
    
}

- (void)updateMorePageDataArray:(NSArray *)dataArray
{
    
}

- (void)updateMorePageDataArray:(NSArray *)dataArray atIndex:(NSInteger)index{
    
}

- (void)removeCellAtIndexPath:(NSArray<NSIndexPath *> *)indexPaths animation:(UITableViewRowAnimation)animation
{
    
}

#pragma mark - action

- (NSMutableArray *)addItems:(NSArray *)items atIndex:(NSInteger)index section:(NSInteger)section
{
    NSMutableArray *sectionArray0 = [self.cellDataArray objectAtIndex:section];
    NSMutableArray *sectionArray1 = [self.dataList objectAtIndex:section];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (id item in items) {
        TTBaseCellEntity *entity = [self cellEntity:item indexPath:[NSIndexPath indexPathForRow:index inSection:section]];
        if (entity) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            [sectionArray1 insertObject:item atIndex:index];
            [sectionArray0 insertObject:entity atIndex:index];
        }
        index++;
    }
    return indexPaths;
}

- (void)insertMoreDataInSection:(NSInteger)section withArray:(NSArray *)dataArray{
    if ([dataArray isKindOfClass:[NSArray class]])
    {
        NSArray *array = [self.cellDataArray objectAtIndex:section];
        NSInteger index = [array count];
        
        NSArray *indexPaths = [self addItems:dataArray atIndex:index section:section];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)updateDataInSection:(NSInteger)section withArray:(NSArray *)array{
    NSMutableArray *array0 = [self.cellDataArray objectAtIndex:section];
    NSMutableArray *array1 = [self.dataList objectAtIndex:section];
    [array0 removeAllObjects];
    [array1 removeAllObjects];
    [self insertMoreDataInSection:section withArray:array];
}

- (void)removeDataAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *array0 = [self.dataList objectAtIndex:indexPath.section];
    NSMutableArray *array1 = [self.cellDataArray objectAtIndex:indexPath.section];
    
    NSUInteger index = indexPath.row;
    if (index < array0.count && index < array1.count) {
        [array0 removeObjectAtIndex:index];
        [array1 removeObjectAtIndex:index];
        [self.tableView beginUpdates];
        if (indexPath) {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (void)removeDataInSection:(NSInteger)section beginRow:(NSInteger)beginRow endRow:(NSInteger)endRow{
    if (beginRow < 0 || beginRow >= endRow) {
        return;
    }
    NSMutableArray *array0 = [self.dataList objectAtIndex:section];
    NSMutableArray *array1 = [self.cellDataArray objectAtIndex:section];
    if (endRow >= array0.count || endRow >= array1.count) {
        return;
    }
    NSRange range = NSMakeRange(0, 0);
    range.location = beginRow;
    range.length = endRow - beginRow + 1;
    [array0 removeObjectsInRange:range];
    [array1 removeObjectsInRange:range];
    
    [self.tableView beginUpdates];
    NSMutableArray *mtArray = [NSMutableArray array];
    for (NSInteger i = beginRow; i <= endRow; i ++) {

        [mtArray addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView deleteRowsAtIndexPaths:mtArray withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

@end
