//
//  TTTestCommonLogicModule.h
//  Article
//
//  Created by carl on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "TTTestModule.h"

@interface TTTestCommonLogicModule : NSObject
+ (instancetype)shareModule;
@end

@interface TTTestCommonLogicModule (TTConfig) <TTTestModule>
+ (void)configWith:(NSDictionary *)info;
@end
