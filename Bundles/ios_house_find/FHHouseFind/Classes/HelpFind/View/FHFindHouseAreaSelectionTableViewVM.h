//
//  FHFindHouseAreaSelectionTableViewVM.h
//  ios_house_filter
//
//  Created by leo on 2018/12/9.
//

#import <Foundation/Foundation.h>
#import "FHFilterRedDotManagement.h"
NS_ASSUME_NONNULL_BEGIN
@class FHFilterNodeModel;
@class TransactionIndexPathSet;
@interface FHFindHouseAreaSelectionTableViewVM : NSObject<UITableViewDelegate, UITableViewDataSource, FHFilterRedDotManagementDelegate>

@property (nonatomic, strong) NSMutableArray<FHFilterNodeModel*> *nodes;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) FHFindHouseAreaSelectionTableViewVM* subSelectionTableViewVM;
@property (nonatomic, assign) BOOL isMultiChecked;
@property (nonatomic, assign) BOOL isLeaf;
@property (nonatomic, assign) BOOL shouldTraceScroll;
@property (nonatomic, assign) BOOL isShowHotDot;
@property (nonatomic, assign) BOOL isAllowLabelShift;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) TransactionIndexPathSet* transaction;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, copy) void (^didSelectedNode)(void);
@property (nonatomic, strong) NSSet<NSNumber *> *hiddenRows;  //需要隐藏的cell行

- (instancetype)initWithTableView:(UITableView*)tableView;

- (void)setNodes:(NSArray<FHFilterNodeModel *>*)nodes;
- (void)setSelectedNode:(FHFilterNodeModel*)model;
- (void)setSelectedIndexPath:(NSIndexPath*)indexPath;
- (void)setSelectedIndexPath:(NSIndexPath*)indexPath adjustTableViewOffset:(BOOL)adjustTableViewOffset;
- (NSSet<NSIndexPath*>*)selectedIndexPath;
- (NSArray<FHFilterNodeModel*>*)selectedNodes;
- (BOOL)hasSelection;
-(void)setConditions:(NSDictionary*)conditions;
- (void)cleanSelectedIndexPath;
-(void)activiteDueToSelectedNode;
-(void)resotreSelectedState;
-(void)commitSelectedState;
-(void)selectedTableCellAtIndex;
@end

NS_ASSUME_NONNULL_END
