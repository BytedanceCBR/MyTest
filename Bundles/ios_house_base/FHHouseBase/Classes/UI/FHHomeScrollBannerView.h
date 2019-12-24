//
//  FHHomeScrollBannerView.h
//  FHHouseBase
//
//  Created by 张静 on 2019/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat kFHScrollBannerTopMargin = 15;
static CGFloat kFHScrollBannerLeftRightMargin = 15;
static CGFloat kFHScrollBannerHeight = 80; // 轮播图的高度

@protocol FHBannerViewIndexProtocol <NSObject>

@optional
- (void)currentIndexChanged:(NSInteger)currentIndex;
- (void)clickBannerWithIndex:(NSInteger)currentIndex;
@optional
- (void)currentIndexWillChange:(NSInteger)currentIndex toIndex:(NSInteger)toIndex fraction:(float)fraction;

@end

@interface FHHomeScrollBannerView : UIView

@property (nonatomic, weak)     id<FHBannerViewIndexProtocol>      delegate;

- (void)setContent:(CGFloat)wid height:(CGFloat)hei;
- (void)setURLs:(NSArray *)urls;
- (void)removeTimer;
- (void)addTimer;
// 暂停-重启定时器
- (void)pauseTimer;
- (void)resetTimer;

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
