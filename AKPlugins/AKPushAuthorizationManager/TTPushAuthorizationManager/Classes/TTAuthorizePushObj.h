//
//  TTAuthorizePushObj.h
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeBaseObj.h"
#import "TTGuideDispatchManager.h"

/*
 推送权限
 */
@interface TTAuthorizePushObj : TTAuthorizeBaseObj <TTGuideProtocol>

- (TTAuthorizeHintView *)authorizeHintViewWithTitle:(NSString *)title
                                            message:(NSString *)message
                                              image:(id)imageObject
                                      okButtonTitle:(NSString *)okButtonTitle
                                            okBlock:(void (^)())okBlock
                                        cancelBlock:(void (^)())cancelBlock;
/*
 推荐频道
 一次主动刷新后（下拉/点底tab&顶部刷新按钮）
 */
- (void)showAlertAtActionFeedRefreshWithCompletion:(dispatch_block_t)completionHandler sysAuthFlag:(NSInteger)flag;

/*
 弹窗控制策略
 */
- (void)filterAuthorizeStrategyWithCompletionHandler:(dispatch_block_t)completionHandler sysAuthFlag:(NSInteger)flag;

@end
