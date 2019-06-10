//
//  TTStartupUIGroup.h
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupGroup.h"

@interface TTStartupUIGroup : TTStartupGroup

typedef NS_ENUM(NSUInteger, TTUIStartupType) {
    TTUIStartupTypeMainUI = 0, //主UI
    TTUIStartupTypeIntroduceView,//登录引导页面
//    TTUIStartupTypeWebview,//首页展示头条wap站
    TTUIStartupTypeWendaCell,//问答频道和推荐频道Cell的互相注册
//    TTUIStartupTypeSFActivityUI, // 春节活动相关
};

+ (TTStartupUIGroup *)UIGroup;
+ (TTStartupUIGroup *)webviewGroup;

@end
