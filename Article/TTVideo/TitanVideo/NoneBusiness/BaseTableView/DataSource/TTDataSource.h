
#import "TTBaseDataSource.h"

@interface TTDataSource : TTBaseDataSource

/*
 * 生成 cellEntity，必须重载
 */
- (TTBaseCellEntity *)cellEntity:(id)aItem indexPath:(NSIndexPath *)indexPath;
/*
 * 在table index位置插入cell 并有插入动画
 */
- (void)updateMorePageDataArray:(NSArray *)dataArray atIndex:(NSInteger)index;

/**
 *  在table index处删除cell，并有删除动画
 */
- (void)removeCellAtIndexPath:(NSArray <NSIndexPath *> *)indexPaths animation:(UITableViewRowAnimation)animation;
@end
