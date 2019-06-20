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

@end

NS_ASSUME_NONNULL_END
