//
//  FHMapSearchHouseListViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHBaseViewController.h"
#import "FHMapSearchHouseListViewModel.h"

@class FHSearchHouseDataModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHMapSearchHouseListViewController : FHBaseViewController

@property(nonatomic , strong) FHMapSearchHouseListViewModel *viewModel;
@property(nonatomic , copy)   void (^willSwipDownDismiss)(CGFloat duration);
@property(nonatomic , copy)   void (^didSwipDownDismiss)();
@property(nonatomic , copy)   void (^moveToTop)(); //滑动到顶部
@property(nonatomic , copy)   void (^moveDock)(); //滑动到一半

-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor;

-(CGFloat)minTop;

-(BOOL)canMoveup;

-(void)moveTop:(CGFloat)top;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
