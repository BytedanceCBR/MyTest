//
//  SSDebugViewController.h
//  Article
//
//  Created by SunJiangting on 15-2-27.
//
//

#if INHOUSE

#import <UIKit/UIKit.h>
#import "SSDebugViewControllerBase.h"

typedef NS_OPTIONS(NSInteger, SSDebugItems) {
    SSDebugItemController    = 1,      // 高级调试框
};

typedef NS_OPTIONS(NSInteger, SSDebugSubitems) {
    SSDebugSubitemFlex          = 1 ,
    SSDebugSubitemForum         = 1 << 2,   //话题相关
    SSDebugSubitemLogging       = 1 << 3,   // 日志测试服务
    SSDebugSubitemFakeLocation  = 1 << 4,   // 允许模拟用户位置
    SSDebugSubitemCleanCache    = 1 << 5,   // 清空缓存测试
    SSDebugSubitemIPConfig      = 1 << 6,   // DNS/Ping相关测试
    SSDebugSubitemUserDefaults  = 1 << 7,   // UserDefaults 文件
    SSDebugSubitemAll           = (SSDebugSubitemFlex | SSDebugSubitemForum | SSDebugSubitemLogging | SSDebugSubitemFakeLocation | SSDebugSubitemCleanCache | SSDebugSubitemIPConfig    | SSDebugSubitemUserDefaults)
};

@interface SSDebugViewController : SSDebugViewControllerBase


+ (BOOL)supportTestImageSubject;

+ (BOOL)supportWKWebView;

+ (BOOL)supportDebugItem:(SSDebugItems)debugItem;
+ (BOOL)supportDebugSubitem:(SSDebugSubitems)debugItem;

@end

#endif
