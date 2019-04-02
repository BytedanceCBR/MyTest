//
//  FHHomeScrollBannerCell.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"
#import <FHHomeBannerView.h>

NS_ASSUME_NONNULL_BEGIN

// 首页轮播banner
@interface FHHomeScrollBannerCell : FHHomeBaseTableCell

+ (CGFloat)cellHeight;

@end

@interface FHHomeScrollBannerView : UIView

@end

@interface FHBannerScrollView : UIScrollView

@end

// 指示器view
@interface FHBannerIndexView : UIView

- (void)setIndexCount:(NSInteger)count size:(CGFloat)size;
- (void)setCurrentIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
