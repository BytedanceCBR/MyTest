//
//  FHUGCShortVideoListViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHUGCShortVideoListController.h"
#import "FHBaseCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoListViewModel : NSObject

@property(nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) NSInteger refer;
@property(nonatomic, assign) BOOL isShowing;

- (instancetype)initWithCollectionView:(FHBaseCollectionView *)collectionView controller:(FHUGCShortVideoListController *)viewController;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status;

@end

NS_ASSUME_NONNULL_END
