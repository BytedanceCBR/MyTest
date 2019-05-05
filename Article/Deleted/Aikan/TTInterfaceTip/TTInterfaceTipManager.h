//
//  TTInterfaceTipManager.h
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import <UIKit/UIKit.h>
#import "TTInterfaceTipHeader.h"

@interface TTInterfaceTipBackgroundView : UIView
@end

@class TTInterfaceTipBaseModel;
@class TTInterfaceTipBaseView;
@interface TTInterfaceTipManager : NSObject

@property (nonatomic, assign)NSInteger currentTabBarIndex;
@property (nonatomic, weak, readonly)TTInterfaceTipBaseView *currentTipView;
@property (nonatomic, strong, readonly)TTInterfaceTipBackgroundView *backgroundView;

+ (TTInterfaceTipManager *)sharedInstance_tt;

/**
 
 通过自定义的Model来创建一个tipView
 baseModel将通过TTGuideDispatchManager来解决多个弹窗冲突的问题
 */
+ (void)appendTipWithModel:(TTInterfaceTipBaseModel *)model;


/**
 立刻展示一个弹窗，如果当前有非最高级的弹窗的话，会干掉该弹窗，否则等待

 @param model model
 */
+ (void)showInstanceTipWithModel:(TTInterfaceTipBaseModel *)model;

/**
 
 直接弹出弹窗，不走互斥TTDialogDirector逻辑
 */
+ (void)appendNonDirectorTipWithModel:(TTInterfaceTipBaseModel *)model;

/**
 
 使用一个baseModel通过identifier创建一个tipView
 
 */
+ (void)appendTipWithTipViewIdentifier:(NSString *)identifier;

+ (void)appendNightShiftTipViewIfNeed;

/**
 
 通过baseModel来立即显示tipView
 
 */
- (void)showWithModel:(TTInterfaceTipBaseModel *)model withDialogDirector:(BOOL)dialogDirector;

/**
 当tipView要退出的时候，通过调用这个方法告知Manager做一些清理的操作

 @param animate YES则使用默认的向下滑动的退出动画
 */
- (void)dismissViewWithDefaultAnimation:(NSNumber *)animate withView:(TTInterfaceTipBaseView *)baseView;

/**
 当下一次首页展示出来的时候，再进行弹窗的展示

 @param tipModel 需要进行展示的弹窗
 */
+ (void)setupShowAfterMainListDidShowWithTipModel:(TTInterfaceTipBaseModel *)tipModel;


+ (void)hideTipView;

+ (void)showTipView;

@end
