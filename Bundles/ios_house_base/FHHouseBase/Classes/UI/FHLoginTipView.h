//
//  FHLoginTipView.h
//  FHHouseBase
//
//  Created by liuyu on 2020/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginTipView : UIView
+ (void)showLoginTipViewInView:(UIView *)bacView navbarHeight:(CGFloat)navbarHeight withTracerDic:(NSDictionary *)tracerDic;
@property (strong, nonatomic) NSDictionary *traceDict;
@property (assign, nonatomic) CGFloat navbarHeight;
@end

NS_ASSUME_NONNULL_END
