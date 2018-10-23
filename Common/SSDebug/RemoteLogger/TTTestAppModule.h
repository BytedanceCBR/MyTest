//
//  TTTestAppModule.h
//  Article
//
//  Created by carl on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "TTTestModule.h"

@interface TTTestAppModule : NSObject

@end

@interface TTTestAppModule (TTConfig) <TTTestModule>
+ (void)configWith:(NSDictionary *)info;
@end
