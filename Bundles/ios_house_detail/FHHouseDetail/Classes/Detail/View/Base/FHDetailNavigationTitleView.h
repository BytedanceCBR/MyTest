//
//  FHDetailNavigationTitleView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNavigationTitleView : UIView


@property(nonatomic , strong) UICollectionView *colletionView;

@property (nonatomic, strong)   NSArray <NSString *>       *titleNames;
@property (nonatomic, strong)   NSArray <NSNumber *>       *titleNums;

@property (nonatomic, assign)   NSInteger       selectIndex;// 选中的索引

@property(nonatomic, copy) void (^currentIndexBlock)(NSInteger currentIndex);

@property (nonatomic, strong) UIView *seperatorLine;

- (void)reloadData;
@end

@interface FHDetailNavigationTitleCell : UICollectionViewCell

@property (nonatomic, strong)   UILabel        *titleLabel;

@end

NS_ASSUME_NONNULL_END
