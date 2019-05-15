//
//  ArticleExportPrefixBase.h
//  Article
//
//  Created by Zhang Leonardo on 13-7-14.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SSRobust.h"
#import "SSCommonLogic.h"
#import "UIImageAdditions.h"
#import "CommonURLSetting.h"
#import "ExploreLogicSetting.h"
#import "TTTrackerWrapper.h"
#import "TTThemeManager.h"
#import "NSNull+Addition.h"
#import "NSDictionary+TTAdditions.h"
#import "TTImageInfosModel.h"
#import "SSUserModel.h"
//#import "ForumPlugin.h"
#import "JSONModel.h"
#import "Masonry.h"
#import "UIViewAdditions.h"
#import "Log.h"
#import "TTMonitor.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceUIUtils.h"
#import "UIButton+TTAdditions.h"
#import "UITextView+TTAdditions.h"
#import "TTThemeConst.h"
#import <Crashlytics/Crashlytics.h>

#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTSandBoxHelper.h>

#import <libextobjc/extobjc.h>

// bugfix workaround:
// 用于修复 Xcode 9 上系统头文件里该符号未被标记 AVAILABLE 版本，导致在 iOS 7 设备上崩溃的问题
FOUNDATION_EXPORT NSString * const NSUserActivityTypeBrowsingWeb NS_AVAILABLE(10_10, 8_0);

#ifndef SSMinX
#define SSMinX(view) CGRectGetMinX(view.frame)
#endif

#ifndef SSMinY
#define SSMinY(view) CGRectGetMinY(view.frame)
#endif

#ifndef SSMaxX
#define SSMaxX(view) CGRectGetMaxX(view.frame)
#endif

#ifndef SSMaxY
#define SSMaxY(view) CGRectGetMaxY(view.frame)
#endif

#ifndef SSWidth
#define SSWidth(view) view.frame.size.width
#endif

#ifndef SSHeight
#define SSHeight(view) view.frame.size.height
#endif

#ifndef SSScreenWidth
#define SSScreenWidth [[UIScreen mainScreen] bounds].size.width
#endif

#ifndef SSScreenHeight
#define SSScreenHeight [[UIScreen mainScreen] bounds].size.height
#endif
