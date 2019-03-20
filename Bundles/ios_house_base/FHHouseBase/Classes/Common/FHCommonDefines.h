//
//  FHCommonDefines.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/20.
//

#ifndef FHCommonDefines_h
#define FHCommonDefines_h

#define NO_EMPTY_STR(str) ([str isKindOfClass:[NSString class]] && str.length > 0)
#define SCREEN_WIDTH   CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define HOR_MARGIN      20
#define ONE_PIXEL      1.0/[[UIScreen mainScreen]scale]

#ifndef IS_EMPTY_STRING
#define IS_EMPTY_STRING(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

#endif /* FHCommonDefines_h */
