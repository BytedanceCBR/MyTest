//
//  FHHomeScrollBannerCell.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import <UIKit/UIKit.h>
#import "FHHomeBaseTableCell.h"
#import <FHHomeBannerView.h>
#import "FHConfigModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FHHomeScrollBannerView;
// 首页轮播banner
@interface FHHomeScrollBannerCell : FHHomeBaseTableCell

@property (nonatomic, strong)   FHHomeScrollBannerView       *bannerView;
+ (CGFloat)cellHeight;
-(void)updateWithModel:(FHConfigDataMainPageBannerOpDataModel *)model;

@end

@protocol FHBannerViewIndexProtocol <NSObject>

@optional
- (void)currentIndexChanged:(NSInteger)currentIndex;
- (void)clickBannerWithIndex:(NSInteger)currentIndex;

@end

@interface FHHomeScrollBannerView : UIView

@property (nonatomic, weak)     id<FHBannerViewIndexProtocol>      delegate;

- (void)setContent:(CGFloat)wid height:(CGFloat)hei;
- (void)setURLs:(NSArray *)urls;
- (void)removeTimer;
- (void)addTimer;

@end

// ScrollView
@interface FHBannerScrollView : UIScrollView

- (void)setContent:(CGFloat)wid height:(CGFloat)hei;

- (void)setLeftImage:(NSString *)url;

- (void)setMidImage:(NSString *)url;

- (void)setRightImage:(NSString *)url;
    
@end

// 指示器view
@interface FHBannerIndexView : UIView

- (void)setIndexCount:(NSInteger)count size:(CGFloat)size;
- (void)setCurrentIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
