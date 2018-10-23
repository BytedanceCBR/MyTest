//
//  TSVDetailRouteHelper.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/18.
//

#import <Foundation/Foundation.h>
#import <TTRoute/TTRoute.h>

/**
 *  这个类处理从小视频详情页跳转到别的页面没有转场动画的问题，处理方案如下
 *  首先在AWEVideoDetailViewController viewDidLoad方法里注册下动画类，然后在本类中添加支持跳转的scheme，然后调本类的openURL方法
 */

@interface TSVDetailRouteHelper : NSObject

+ (void)registerCustomPushAnimationFromVCClass:(Class)fromVCClass;
+ (BOOL)openURLByPushViewController:(NSURL *)url;
+ (BOOL)openURLByPushViewController:(NSURL *)url userInfo:(TTRouteUserInfo *)userInfo;

@end
