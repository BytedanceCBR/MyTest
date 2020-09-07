//
//  FHHouseSaleInputView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import <UIKit/UIKit.h>
#import "FHPriceValuationItemView.h"
#import "FHHouseSaleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseSaleInputViewDelegate <NSObject>

@optional

- (void)goToNeighborhoodSearch;

- (void)evaluate;

- (void)chooseFloor;

@end

@interface FHHouseSaleInputView : UIView

@property(nonatomic, strong) FHHouseSaleScrollView *scrollView;
@property(nonatomic, strong) FHPriceValuationItemView *neiborhoodItemView;
@property(nonatomic, strong) FHPriceValuationItemView *floorItemView;
@property(nonatomic, strong) FHPriceValuationItemView *areaItemView;
@property(nonatomic, strong) FHPriceValuationItemView *nameItemView;
@property(nonatomic, strong) FHPriceValuationItemView *phoneItemView;
@property(nonatomic , weak) id<FHHouseSaleInputViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight;

@end

NS_ASSUME_NONNULL_END
