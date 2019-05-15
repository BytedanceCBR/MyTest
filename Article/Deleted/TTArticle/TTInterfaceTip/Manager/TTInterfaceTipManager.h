//
//  TTInterfaceTipManager.h
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import <UIKit/UIKit.h>
#import "TTInterfaceTipHeader.h"

@class TTInterfaceTipBaseModel;

@interface TTInterfaceTipManager : NSObject

@property (nonatomic, assign)NSInteger currentTabBarIndex;

+ (TTInterfaceTipManager *)sharedInstance_tt;

/**
 
 通过自定义的Model来创建一个tipView
 baseModel将通过TTGuideDispatchManager来解决多个弹窗冲突的问题
 */
+ (void)appendTipWithModel:(TTInterfaceTipBaseModel *)model;

/**
 
 使用一个baseModel通过identifier创建一个tipView
 
 */
+ (void)appendTipWithTipViewIdentifier:(NSString *)identifier;

+ (void)appendNightShiftTipViewIfNeed;
/**
 
 通过baseModel来立即显示tipView
 
 */
- (void)showWithModel:(TTInterfaceTipBaseModel *)model;

/**
 当tipView要退出的时候，通过调用这个方法告知Manager做一些清理的操作

 @param animate YES则使用默认的向下滑动的退出动画
 */
- (void)dismissViewWithDefaultAnimation:(NSNumber *)animate;
@end
