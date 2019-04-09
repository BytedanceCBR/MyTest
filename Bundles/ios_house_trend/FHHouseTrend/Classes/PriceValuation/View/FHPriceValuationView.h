//
//  FHPriceValuationView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import <UIKit/UIKit.h>
#import "FHPriceValuationItemView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHPriceValuationViewDelegate <NSObject>

- (void)goToNeighborhoodSearch;

- (void)evaluate;

- (void)goToUserProtocol;

- (void)chooseFloor;

@end

@interface FHPriceValuationView : UIView

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) FHPriceValuationItemView *neiborhoodItemView;
@property(nonatomic, strong) FHPriceValuationItemView *areaItemView;
@property(nonatomic, strong) FHPriceValuationItemView *floorItemView;
@property(nonatomic , weak) id<FHPriceValuationViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight;
- (void)setEvaluateBtnEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
