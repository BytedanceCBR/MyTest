//
//  FHMapSearchHouseListViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHBaseViewController.h"
#import "FHMapSearchHouseListViewModel.h"
#import "FHMapSearchPolyInfoModel.h"
#import "FHHouseListBaseItemModel.h"

@class FHSearchHouseDataModel;
@class FHSearchHouseDataItemsModel;
@class FHMapSearchBubbleModel;
@class FHHouseRentDataItemsModel;
NS_ASSUME_NONNULL_BEGIN


@interface FHMapSearchHouseListViewController : FHBaseViewController

@property(nonatomic , strong) FHMapSearchHouseListViewModel *viewModel;
@property(nonatomic , copy)   void (^willSwipeDownDismiss)(CGFloat duration,FHMapSearchBubbleModel *fromBubble);
@property(nonatomic , copy)   void (^didSwipeDownDismiss)(FHMapSearchBubbleModel *fromBubble);
@property(nonatomic , copy)   void (^moveToTop)(); //滑动到顶部
@property(nonatomic , copy)   void (^moveDock)(); //滑动到一半
@property(nonatomic , copy)   void (^showHouseDetailBlock)(FHHouseListBaseItemModel *model , NSInteger rank , FHMapSearchBubbleModel *fromBubble);
@property(nonatomic , copy)   void (^showRentHouseDetailBlock)(FHHouseListBaseItemModel *model , NSInteger rank , FHMapSearchBubbleModel *fromBubble);
@property(nonatomic , copy)   void (^showNeighborhoodDetailBlock)(FHMapSearchDataListModel *model , FHMapSearchBubbleModel *fromBubble);
@property(nonatomic , copy)   void (^movingBlock)(CGFloat top);
-(void)showNeighborHouses:(FHMapSearchDataListModel *)neighbor bubble:(FHMapSearchBubbleModel *)bubble;
-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor  bubble:(FHMapSearchBubbleModel *)bubble;

-(void)resetScrollViewInsetsAndOffsets;

-(CGFloat)initialTop;

-(CGFloat)minTop;

-(BOOL)canMoveup;

-(void)moveTop:(CGFloat)top;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
