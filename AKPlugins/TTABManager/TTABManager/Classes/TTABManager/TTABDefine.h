//
//  TTABDefine.h
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/24.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TTABDefine_h
#define TTABDefine_h

#ifndef isEmptyString_forABManager
#define isEmptyString_forABManager(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

/**
 *  版本比较
 */
typedef NS_ENUM(NSUInteger, TTABVersionCompareType) {
    /**
     *  左边的版本号小于右边的版本号
     */
    TTABVersionCompareTypeLessThan,
    /**
     *  左边的版本号等于右边的版本号
     */
    TTABVersionCompareTypeEqualTo,
    /**
     *  左边的版本号大于右边的版本号
     */
    TTABVersionCompareTypeGreateThan
};


#endif
