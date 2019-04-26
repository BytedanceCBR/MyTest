//
//  FHVideoMiniSliderView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoMiniSliderView : UIView

@property(nonatomic, assign)CGFloat cacheProgress;
@property(nonatomic, assign)CGFloat watchedProgress;
@property(nonatomic, assign)BOOL isVerticle;

@end

NS_ASSUME_NONNULL_END
