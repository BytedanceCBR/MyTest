//
//  UIViewController+BanTip.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/3/27.
//
//  因为很多页面需要禁掉应用内push弹窗和im消息提示弹窗，所以做一个统一处理

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(BanTip)

/// 禁掉所有的tip弹窗
/// @param isBan  YES - 禁止弹出 NO - 恢复之前的状态
- (void)banTip:(BOOL)isBan;

/// 禁掉IM消息提示气泡弹窗
/// @param isBan  YES - 禁止弹出 NO - 恢复之前的状态
- (void)banFHMessageTipBubble:(BOOL)isBan;

/// 禁掉应用内远程推送弹窗
/// @param isBan  YES - 禁止弹出 NO - 恢复之前的状态
- (void)banInAppRemotePushTip:(BOOL)isBan;

@end

NS_ASSUME_NONNULL_END
