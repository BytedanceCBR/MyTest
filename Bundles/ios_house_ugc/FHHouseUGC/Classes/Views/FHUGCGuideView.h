//
//  FHUGCGuideView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/19.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FHUGCGuideViewType) {
    FHUGCGuideViewTypeSecondTab = 0,
    FHUGCGuideViewTypeSearch,
    FHUGCGuideViewTypeDetail,
};

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCGuideView : UIView

- (instancetype)initWithFrame:(CGRect)frame andType:(FHUGCGuideViewType)type;

- (void)show:(UIView *)parentView dismissDelayTime:(NSTimeInterval)delayTime;

- (void)hide;

//仅仅是详情页需要传入 关注按钮 距离顶部的距离
@property(nonatomic, assign) CGFloat focusBtnTopY;
@property(nonatomic, copy) void(^clickBlock)(void);

@end

NS_ASSUME_NONNULL_END
