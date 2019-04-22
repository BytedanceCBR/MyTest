//
//  TTAppStoreStarManager.h
//  Article
//
//  Created by Zichao Xu on 2017/10/15.
//

#import <Foundation/Foundation.h>

extern NSString * const TTAppStoreStarManagerShowNotice;
extern NSString * const TTAppStoreStarManagerAdvancedDebugKey;

/*
 * appStore评分引导
 */
@interface TTAppStoreStarManager : NSObject

+ (instancetype)sharedInstance;

/*
 * 是否满足显示条件
 */

- (BOOL)meetOpenCondition;

/*
 * 展示和消失引导图
 */
- (void)showView;
- (void)showViewFromNotice:(NSNotification *)notice;
- (void)dismissView;
- (void)setDismissFinishedBlock:(dispatch_block_t)block;

/*
 * 跳转到AppStore
 */
- (void)openAppInAppleStore;

/*
 * Settings开关控制
 * 是否是有效命中的AB测用户
 * 每次打开的间隔时间
 * 是否打开了绿色通道
 */
- (void)setValidUser:(BOOL)valid
    showTimeInterval:(double)timeInterVal
      isGreenChannel:(BOOL)isGreen;

/*
 * 高级调试打开
 */
- (BOOL)advancedDebug;
- (void)setAdvancedDebug:(BOOL)on;

@end
