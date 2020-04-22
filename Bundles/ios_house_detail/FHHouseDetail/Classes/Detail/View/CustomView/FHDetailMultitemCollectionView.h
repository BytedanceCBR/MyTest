//
//  FHDetailMultitemCollectionCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

typedef void(^kFHMultitemCollectionCellClickBlk)(NSInteger index);
typedef void(^kFHMultitemCollectionDisplayCellBlk)(NSInteger index);
typedef void(^kFHMultitemCollectionCellItemClickBlk)(NSInteger index, UIView *itemView, FHDetailBaseCollectionCell* cell);

NS_ASSUME_NONNULL_BEGIN

// 横向滚动列表
@interface FHDetailMultitemCollectionView : UIView

// 需要的初始化方法
/*
 UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
 flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
 flowLayout.itemSize = CGSizeMake(156, 190);
 flowLayout.minimumLineSpacing = 10;
 flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 */
@property (nonatomic, strong)   UICollectionView       *collectionContainer;

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight cellIdentifier:(NSString *)cellIdentifier cellCls:(Class)cls datas:(NSArray *)datas;
- (void)reloadData;

@property (nonatomic, copy)     kFHMultitemCollectionCellClickBlk       clickBlk;
@property (nonatomic, copy)     kFHMultitemCollectionCellItemClickBlk   itemClickBlk;
@property (nonatomic, copy)     kFHMultitemCollectionDisplayCellBlk     displayCellBlk;

@property (nonatomic, strong)   NSMutableDictionary *subHouseShowCache;
@property (nonatomic, assign)   BOOL isNewHouseFloorPan;
@end

NS_ASSUME_NONNULL_END
