//
//  FHMapSearchHouseListViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHBaseViewController.h"
#import "FHMapSearchHouseListViewModel.h"

@class FHSearchHouseDataModel;
@class FHSearchHouseDataItemsModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHMapSearchHouseListViewController : FHBaseViewController

@property(nonatomic , strong) FHMapSearchHouseListViewModel *viewModel;
@property(nonatomic , copy)   void (^willSwipeDownDismiss)(CGFloat duration);
@property(nonatomic , copy)   void (^didSwipeDownDismiss)();
@property(nonatomic , copy)   void (^moveToTop)(); //滑动到顶部
@property(nonatomic , copy)   void (^moveDock)(); //滑动到一半
@property(nonatomic , copy)   void (^showHouseDetailBlock)(FHSearchHouseDataItemsModel *model , NSInteger rank);
@property(nonatomic , copy)   void (^showNeighborhoodDetailBlock)(FHMapSearchDataListModel *model);
@property(nonatomic , copy)   void (^movingBlock)(CGFloat top);

-(void)showNeighborHouses:(FHMapSearchDataListModel *)neighbor;
-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor;

-(void)resetScrollViewInsetsAndOffsets;

-(CGFloat)initialTop;

-(CGFloat)minTop;

-(BOOL)canMoveup;

-(void)moveTop:(CGFloat)top;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END