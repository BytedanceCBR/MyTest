

#import <Foundation/Foundation.h>
#import "TTBaseCellAction.h"
@class TTBaseCellEntity;
@protocol TTDataSourceDelegate <NSObject>
@optional

- (void)tableView:(UITableView *)tableView deleteRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectRowWithCellEntity:(id)entity;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (void)configCellEntity:(TTBaseCellEntity *)cellEntity;

#pragma mark ============= scroll delegate =============
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

@interface TTBaseDataSource : NSObject<UITableViewDataSource ,UITableViewDelegate>

// 传入的数据
@property (nonatomic, readonly) NSMutableArray *dataList;
@property (nonatomic, assign) BOOL hasMore;
//经过处理的数据.
@property (nonatomic, readonly) NSMutableArray  *cellDataArray;
@property (nonatomic, weak) NSObject <TTDataSourceDelegate,TTBaseCellAction> *delegate;
@property (nonatomic, weak) UITableView         *tableView;

/**
 标示tableView正在reloadData ,不允许修改数组数据
 */
@property (nonatomic, assign)BOOL               isTableReloading;
- (void)updateFirstPageDataArray:(NSArray *)dataArray;

/*
 * 在table最后插入cell 并有插入动画
 */
- (void)updateMorePageDataArray:(NSArray *)dataArray;

/*
 * 更新tableview中指定行的数据，并且可以带动画
 */
- (void)updateDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexs withDataArray:(NSArray *)dataArray;

@end

