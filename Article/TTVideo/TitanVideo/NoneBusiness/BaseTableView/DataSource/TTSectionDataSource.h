

#import "TTDeleteDataSource.h"
#import "TTSectionEntity.h"
#import "TTSectionViewEntity.h"

@protocol TTSectionDataSourceDelegate <NSObject>

@optional

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

@end


//数据源是二维数组
@interface TTSectionDataSource : TTDeleteDataSource

@property (nonatomic, weak) NSObject <TTDataSourceDelegate, TTSectionDataSourceDelegate,TTBaseCellAction> *delegate;

/**
 更新所有的数据,请用
 */

- (void)updateFirstPageDataArray:(NSArray *)dataArray;//dataArray中是array(item 为 TTSectionEntity)类型的对象,
/**
 往一个section里插入数据
*/
- (void)insertMoreDataInSection:(NSInteger)section withArray:(NSArray *)dataArray;//dataArray中是非array类型的对象.

/**
 更新一个section的数据
 */
- (void)updateDataInSection:(NSInteger)section withArray:(NSArray *)array;
/**
 * 更新tableview中指定cell的数据
 */

- (void)updateDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexs withDataArray:(NSArray *)dataArray;

/**
 删除数据
 */
- (void)removeDataAtIndexPath:(NSIndexPath *)indexPath;

/**
 删除一系列数据
 */
- (void)removeDataInSection:(NSInteger)section beginRow:(NSInteger)beginRow endRow:(NSInteger)endRow;

/**
 *  子类重写
 */
- (TTSectionViewEntity *)sectionViewEntity:(id)item section:(NSInteger)section;

- (TTBaseCellEntity *)cellEntity:(id)aItem indexPath:(NSIndexPath *)indexPath;

@end
