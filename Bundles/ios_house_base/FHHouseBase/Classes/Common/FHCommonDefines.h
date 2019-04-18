//
//  FHCommonDefines.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/20.
//

#ifndef FHCommonDefines_h
#define FHCommonDefines_h

#define NO_EMPTY_STR(str) ([str isKindOfClass:[NSString class]] && str.length > 0)
#define SCREEN_WIDTH      CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT     CGRectGetHeight([[UIScreen mainScreen] bounds])
#define HOR_MARGIN        20
#define ONE_PIXEL         (1.0/[[UIScreen mainScreen]scale])

#define SYS_IMG(name)     [UIImage imageNamed:name]

#ifndef IS_EMPTY_STRING
#define IS_EMPTY_STRING(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
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
