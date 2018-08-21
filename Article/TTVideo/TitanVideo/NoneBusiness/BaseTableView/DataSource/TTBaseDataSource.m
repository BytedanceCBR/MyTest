

#import "TTDataSource.h"
#import "TTBaseCell.h"
#import "TTBaseCellEntity.h"
@interface TTBaseDataSource ()
{
    NSMutableArray *_cellDataArray;
    NSMutableArray *_dataList;
}
@end
@implementation TTBaseDataSource

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (NSMutableArray *)cellDataArray
{
    if (!_cellDataArray) {
        _cellDataArray = [[NSMutableArray alloc] init];
    }
    return _cellDataArray;
}

- (NSString *)cellIdentifierWithEntity:(TTBaseCellEntity *)listCellEntity withIndexPath:(NSIndexPath *)indexPath
{
    if (listCellEntity)
    {
        return [NSStringFromClass(listCellEntity.cellClass) stringByAppendingFormat:@"%@",NSStringFromClass([self class])];
    }
    return @"defaultIndentifier";
}

- (TTBaseCellEntity *)cellEntityWithIndexPath:(NSIndexPath *)path
{
    return [self.cellDataArray objectAtIndex:path.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = nil;
    TTBaseCellEntity *entity = [self cellEntityWithIndexPath:indexPath];
    CellIdentifier = [self cellIdentifierWithEntity:entity withIndexPath:indexPath];
    
    TTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.indexPath = indexPath;
    [cell willBeginReuse];
    if (cell == nil) {
        cell = [[entity.cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.indexPath = indexPath;
    }

    if ([cell isKindOfClass:[TTBaseCell class]]) {
        [cell fillContent:entity indexPath:indexPath];
        cell.action_delegate = self.delegate;
    }
    
    if (!cell) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nocell"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTBaseCellEntity *entity = [self cellEntityWithIndexPath:indexPath];
    return entity.heightOfCell;
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
            [self.delegate tableView:tableView didSelectRowWithCellEntity:[self.cellDataArray objectAtIndex:indexPath.row]];
        }

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return @"";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark ============= scrollView delegate =============
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)updateFirstPageDataArray:(NSArray *)dataArray
{
    
}

- (void)updateMorePageDataArray:(NSArray *)dataArray
{
    
}

- (void)updateDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexs withDataArray:(NSArray *)dataArray
{
    
}

@end

