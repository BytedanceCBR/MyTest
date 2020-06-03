//
//  FHLoginTipView.h
//  FHHouseBase
//
//  Created by liuyu on 2020/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginTipView : UIView
+ (instancetype)showLoginTipViewInView:(UIView *)bacView navbarHeight:(CGFloat)navbarHeight withTracerDic:(NSDictionary *)tracerDic;
@property (strong, nonatomic) NSDictionary *traceDict;
@property (assign, nonatomic) CGFloat navbarHeight;
@property (strong, nonatomic) NSTimer *showTimer;
- (void)loginTipViewDsappear;
@end

NS_ASSUME_NONNULL_END
