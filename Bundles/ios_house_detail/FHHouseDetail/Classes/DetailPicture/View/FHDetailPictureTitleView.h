//
//  FHDetailPictureTitleView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailPictureTitleView : UIView

@property(nonatomic , strong) UICollectionView *colletionView;

@property (nonatomic, strong)   NSArray       *titleNames;
@property (nonatomic, strong)   NSArray       *titleNums;

@property (nonatomic, assign)   NSInteger       selectIndex;// 选中的索引

@property(nonatomic, copy) void (^currentIndexBlock)(NSInteger currentIndex);

@end

@interface FHDetailPictureTitleCell : UICollectionViewCell

@property (nonatomic, strong)   UILabel        *titleLabel;
@property (nonatomic, assign)   BOOL       hasSelected;

@end

NS_ASSUME_NONNULL_END
