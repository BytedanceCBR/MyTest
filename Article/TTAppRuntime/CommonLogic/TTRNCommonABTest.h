//
//  TTRNCommonABTest.h
//  Article
//
//  Created by liuzuopeng on 9/18/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TTRNPageEnabledType) {
    kTTRNPageEnabledTypeAll      = 1 << 0, // 优先级最低，其他页面没有单独控制，就使用该字段控制【default】
    kTTRNPageEnabledTypeProfile  = 1 << 1,
    kTTRNPageEnabledTypeConcern  = 1 << 2, // 关心页
};

@interface TTRNCommonABTest : NSObject
+ (void)setRNEnabledOfPage:(TTRNPageEnabledType)pageType forValue:(BOOL)supported;
+ (BOOL)RNEnabledOfPage:(TTRNPageEnabledType)pageType;
+ (BOOL)RNEnabledDefault;
@end
