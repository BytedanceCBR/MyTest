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
#define HOR_MARIN      20

#endif /* FHCommonDefines_h */
