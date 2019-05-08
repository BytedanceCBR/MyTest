//
//  SSAvatarView+VerifyIcon.h
//  Article
//
//  Created by lizhuoli on 17/1/22.
//
//

#import "SSAvatarView.h"
#import <TTVerifyKit/TTVerifyIconImageView.h>
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import "TTAvatarDecoratorView.h"

@interface SSAvatarView (VerifyIcon)

@property (nonatomic, strong, readonly) TTVerifyIconImageView *verifyView;
@property (nonatomic, strong, readonly) TTAvatarDecoratorView *decoratorView;

/**
 *
 *  功能：设置V的大小
 *
 *  @param avatarLength 头像边长，UE给的iPhone 6标准
 *
 *  @param sizeBlock 根据头像适配规则适配V的大小，其中standardSize是iPhone 6标准下根据avatarLength得到的V的大小
 *
 */
- (void)setupVerifyViewForLength:(CGFloat)avatarLength
             adaptationSizeBlock:(CGSize (^)(CGSize standardSize))sizeBlock;

/**
 *
 *  功能：设置V的大小以及位置
 *
 *  @param avatarLength 头像边长，UE给的iPhone 6标准
 *
 *  @param sizeBlock 根据头像的适配规则适配V的大小，其中standardSize是iPhone 6标准下根据avatarLength得到的V的大小
 *
 *  @param offsetBlock 调整v的位置
 *
 */
- (void)setupVerifyViewForLength:(CGFloat)avatarLength
             adaptationSizeBlock:(CGSize (^)(CGSize standardSize))sizeBlock
           adaptationOffsetBlock:(UIOffset (^)(UIOffset standardOffset))offsetBlock;

/**
 *
 *  功能：展示V
 *
 *  @param verifyInfo 用户认证信息，userauthinfo
 *
 */
- (void)showVerifyViewWithVerifyInfo:(NSString *)verifyInfo DEPRECATED_MSG_ATTRIBUTE("请使用showOrHideVerifyViewWithVerifyInfo:decoratorInfo:sureQueryWithID:userID方法替代");

/**
 NOTICE:明确不会使用uid兜底佩饰的场景
 
 @param decoratorInfo              用户认证信息，userauthinfo
 @param dURL                    佩饰url
 */
- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo;

- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo sureQueryWithID:(BOOL)query userID:(NSString *)userID;


/**
 *
 *  功能：根据是否需要展示加V信息来展示，是否展示收敛在内部
 *
 *  @param verifyInfo       用户认证信息，userauthinfo
 *  @param decoratorInfo     佩饰url
 *  @param sureQueryWithID  【此参数起强调作用】新业务根据自己的页面是否需要userID查询佩饰兜底的策略来传参
 *                          避免新业务顺手传入uid给服务端带来压力
 *  @param userID           用户ID，如果启动兜底策略，用uid去查询对应的佩饰图
 *  @param disableNightCover 禁止夜间
 *
 *  之所以把佩饰的逻辑加在这个方法，是因为避免以后新业务遗忘佩饰，而加V是肯定不会忘记的。。
 *  因为以后的新场景是否需要兜底无法确定，同时也没法保证之后所有人都知道当前约定的【提供佩饰url字段的接口不需要兜底策略】
 *  使用sureQueryWithID这个参数来强调业务端确认是否需要兜底。
 */
- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo sureQueryWithID:(BOOL)query userID:(NSString *)userID disableNightCover:(BOOL)disableNightCover;
/** 隐藏V */
- (void)hideVerifyView DEPRECATED_MSG_ATTRIBUTE("即将废弃，请勿使用");

/**
 当frame变化或其他需要刷新佩饰的时候调用
 */
- (void)refreshDecoratorView;

@end
