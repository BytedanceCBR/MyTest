//
//  TTShareManager.h
//  Pods
//
//  Created by 延晋 张 on 16/6/1.
//
//  不使用默认展示样式的

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTActivityPanelControllerProtocol.h"

@class TTShareManager;

@protocol TTShareManagerDelegate <NSObject>

@optional

- (void)shareManager:(TTShareManager *)shareManager
        clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController;

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc;

@end

@interface TTShareManager : NSObject

@property (nonatomic, strong) UIImage *defaultShareImage;
@property (nonatomic, strong) NSString *weiboShareRedirectURI;

@property (nonatomic, weak) id<TTShareManagerDelegate> delegate;

/* 使用本库展示并分享，三步曲：
 1、注册外部自定义分享类型Activities，不额外注册，就是仅使用本库支持分享类型
 2、检查分享内容有效性（包括检查分享应用有效性）
 3、调用展示方法，传入分享内容，交给本库完成展示和后续分享
 */

/*!
 *  @brief 添加自定义的Activities
 *
 *  @param activities 添加自定义的Activities,符合TTActivityProtocol协议的对象
 */
+ (void)addUserDefinedActivitiesFromArray:(NSArray *)activities;

+ (void)addUserDefinedActivity:(id <TTActivityProtocol>)activity;

/*!
 *  @brief  判断分享内容是否可用-至少有一种分享渠道
 *
 *  @param contentArray 要分享的各个渠道内容，每个对象均需遵循TTActivityContentItemProtocol协议
 *
 *  @return YES OR NO
 */
+ (BOOL)checkContentIsValid:(NSArray *)contentArray;

- (void)displayActivitySheetWithContent:(NSArray *)contentArray;

- (void)displayForwardSharePanelWithContent:(NSArray *)contentArray;

- (void)shareToActivity:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController;

- (void)setPanelClassName:(NSString *)panelClassName;

- (void)updateBizTraceExtraInfo:(NSDictionary *)extraInfo activity:(id <TTActivityProtocol>)activity;

@end
