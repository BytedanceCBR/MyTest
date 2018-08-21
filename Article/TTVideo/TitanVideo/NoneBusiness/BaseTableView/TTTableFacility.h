
#import <Foundation/Foundation.h>
#import "TTBaseDataSource.h"
#import "TTTableViewModel.h"
#import "TTTableConfigure.h"
#import "TTViewProtocol.h"
#import "TTBaseCellDelegate.h"
#import "TTSectionDataSource.h"

@interface TTTableFacility : NSObject
@property (nonatomic ,readonly) TTTableViewModel *viewModel;
- (instancetype)initWithTableView:(UITableView *)table
                   tableConfigure:(TTTableConfigure *)configure
                    tableDelegate:(NSObject<TTDataSourceDelegate, TTSectionDataSourceDelegate,TTBaseCellAction> *)delegate;
- (void)loadLocal:(void(^)(TTTableViewModel *viewModel))finished;
- (void)refreshDataWithParameter:(TTApiParameter *)parameter finished:(void(^)(TTTableViewModel *viewModel))finished error:(void(^)(NSError *error))errorBlock;
- (void)loadMoreWithMoreParameter:(TTApiParameter *)moreParameter finished:(void(^)(TTTableViewModel *viewModel))finished error:(void(^)(NSError *error))errorBlock;
- (void)refreshTableWithData:(id)object;
- (void)layoutTableViewCell;
- (void)removeCellAtIndexPath:(NSArray<NSIndexPath *> *)indexPaths animation:(UITableViewRowAnimation)animation;
@end
