//
//  TTFreeFlowTipManager.h
//  Article
//
//  Created by wangdi on 2017/7/7.
//
//

#import <Foundation/Foundation.h>

@interface TTVFreeFlowTipManager : NSObject

+ (instancetype)sharedInstance;

- (void)showHomeFlowAlert;

- (BOOL)shouldShowPullRefreshTip;

+ (BOOL)shouldShowFreeFlowSubscribeTip;
+ (BOOL)shouldShowWillOverFlowTip:(CGFloat)videoSize;
+ (BOOL)shouldShowFreeFlowToastTip:(CGFloat)videoSize;
+ (BOOL)shouldShowFreeFlowLoadingTip;
//+ (BOOL)shouldSwithToHDForFreeFlow;
+ (BOOL)shouldShowDidOverFlowTip;
+ (NSString *)getSubscribeTitleTextWithVideoSize:(CGFloat)videoSize;
+ (NSString *)getSubcribeButtonText;

@end
