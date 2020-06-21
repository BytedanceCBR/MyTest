//
//  FHCommonDefines.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/20.
//

#ifndef FHCommonDefines_h
#define FHCommonDefines_h

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define NO_EMPTY_STR(str) ([str isKindOfClass:[NSString class]] && str.length > 0)
#define SCREEN_WIDTH      CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT     CGRectGetHeight([[UIScreen mainScreen] bounds])
#define SCREEN_SCALE      [[UIScreen mainScreen]scale]
#define HOR_MARGIN        20
#define HOR_MARGIN_NEW        15
#define ONE_PIXEL         (1.0/[[UIScreen mainScreen]scale])

#define SYS_IMG(name)     [UIImage imageNamed:name]

#ifndef IS_EMPTY_STRING
#define IS_EMPTY_STRING(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif


#define SAFE_AREA   UIEdgeInsets safeInsets = UIEdgeInsetsZero; \
    if (@available(iOS 11.0 , *)) { \
        safeInsets = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets]; \
    }

#ifndef WeakSelf
#define WeakSelf __weak typeof(self) wself = self
#endif
#ifndef StrongSelf
#define StrongSelf __strong typeof(wself) self = wself
#endif

#pragma mark - log

#if DEBUG

#define LLLog(fmt, ...) NSLog((@"LLLog %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define ZJLog(fmt, ...) NSLog((@"ZJLog %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define XFLog(fmt, ...) NSLog((@"XFLog %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SMLog(fmt, ...) NSLog((@"SMLog %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CHLog(fmt, ...) NSLog((@"CHLog %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define LLLog(fmt, ...)
#define ZJLog(fmt, ...)
#define XFLog(fmt, ...)
#define SMLog(fmt, ...)
#define CHLog(fmt, ...)

#endif


#endif /* FHCommonDefines_h */
