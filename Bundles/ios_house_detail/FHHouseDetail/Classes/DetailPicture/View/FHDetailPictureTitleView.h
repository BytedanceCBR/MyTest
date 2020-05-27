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

/// 如果是true，说明是图片列表页使用，需要重新layout titlelabel 以及 color
@property (nonatomic, assign) BOOL usedInPictureList;

@property (nonatomic, strong) UIView *seperatorLine;

- (void)reloadData;
@end

@interface FHDetailPictureTitleCell : UICollectionViewCell

@property (nonatomic, strong)   UILabel        *titleLabel;

@end

NS_ASSUME_NONNULL_END
