//
//  TTContactsGuideViewModel.h
//  Article
//  同步通讯录，添加好友弹窗
//
//  Created by Zuopeng Liu on 7/24/16.
//
//

#import "SSThemed.h"
#import "TTGuideDispatchManager.h"




@interface TTContactsGuideViewHelper : NSObject <TTGuideProtocol>

/**
 * 此次应用启动之后是否弹出过通讯录弹窗，用于避免重复弹窗压盖问题
 * @return
 */
+ (BOOL)hasGuideViewDisplayedAfterLaunching;

/**
 * 上传通讯录
 * @param fromAddFriendViewController 是否来自添加好友页
 */
+ (void)uploadContactsFromAddFriendViewController:(BOOL)fromAddFriendViewController;

/**
 * 上传通讯录
 * @param fromAddFriendViewController 是否来自添加好友页
 * @param showTips 授权失败是否弹窗
 */
+ (void)uploadContactsFromAddFriendViewController:(BOOL)fromAddFriendViewController showTipsIfDenied:(BOOL)showTips;

- (void)showWithContext:(id)context;

- (void)hideInstantlyMe;

@end
