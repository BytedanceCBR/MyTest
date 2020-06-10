//
//  FHLoginTipView.h
//  FHHouseBase
//
//  Created by liuyu on 2020/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger , FHLoginTipViewtType) {
    FHLoginTipViewtTypeMain = 1, //首页
    FHLoginTipViewtTypeNeighborhood = 2 ,//社区
};
@interface FHLoginTipView : UIView
+ (instancetype)showLoginTipViewInView:(UIView *)bacView navbarHeight:(CGFloat)navbarHeight withTracerDic:(NSDictionary *)tracerDic;
@property (strong, nonatomic) NSDictionary *traceDict;
@property (assign, nonatomic) CGFloat navbarHeight;
@property (strong, nonatomic) NSTimer *showTimer;
///问题类型
@property (nonatomic, assign) FHLoginTipViewtType type;
- (void)pauseTimer;
- (void)startTimer;
- (void)loginTipViewDsappear;
@end

NS_ASSUME_NONNULL_END
