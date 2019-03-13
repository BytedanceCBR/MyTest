//
//  TTVPalyerTrafficAlert.h
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTFlowStatisticsManager.h"

@class TTVPlayerStateStore;
@interface TTVPalyerTrafficAlert : UIView<TTVPlayerViewTrafficView ,TTVPlayerContext>

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)setTrafficView:(UIView <TTVPlayerViewTrafficView> *)trafficView;
- (void)setTrafficVideoDuration:(NSInteger)duration videoSize:(NSInteger)videoSize inDetail:(BOOL)inDetail;
- (void)setContinuePlayBlock:(dispatch_block_t)continuePlayBlock;
- (void)handleTrafficAlert;
- (void)showFreeFlowTipView:(BOOL)isSubscribe didOverFlow:(BOOL)overFlow userInfo:(NSDictionary *)info;
@end

@interface TTVPlayerFreeFlowTipStatusManager: NSObject
+ (BOOL)shouldShowFreeFlowSubscribeTip;
+ (BOOL)shouldShowWillOverFlowTip:(CGFloat)videoSize;
+ (BOOL)shouldShowFreeFlowToastTip:(CGFloat)videoSize;
+ (BOOL)shouldShowFreeFlowLoadingTip;
+ (BOOL)shouldSwithToHDForFreeFlow;
+ (BOOL)shouldShowDidOverFlowTip;
+ (NSString *)getSubscribeTitleTextWithVideoSize:(CGFloat)videoSize;
+ (NSString *)getSubcribeButtonText;
@end
