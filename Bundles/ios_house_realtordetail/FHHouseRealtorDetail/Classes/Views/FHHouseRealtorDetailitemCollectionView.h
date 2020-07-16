//
//  FHHouseRealtorDetailitemCollectionView.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"
typedef void(^kFHMultitemCollectionCellClickBlk)(NSInteger index);
typedef void(^kFHMultitemCollectionDisplayCellBlk)(NSInteger index);
typedef void(^cellRefreshComplete)(void);
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailitemCollectionView : UIView
@property (nonatomic, strong)   UICollectionView       *collectionContainer;

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight datas:(NSArray *)datas;
- (void)reloadData;
- (void)registerCell:(Class)cell forIdentifier:(NSString *)cellIdentifier;
- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@property (nonatomic, copy)     kFHMultitemCollectionCellClickBlk       clickBlk;
@property (nonatomic, copy)     kFHMultitemCollectionDisplayCellBlk       displayCellBlk;
@property (nonatomic, copy) cellRefreshComplete cellRefreshComplete;
@end

NS_ASSUME_NONNULL_END
