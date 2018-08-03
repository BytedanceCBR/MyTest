//
//  FRAPPDelegateHelper.h
//  Article
//
//  Created by ZhangLeonardo on 15/10/15.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"

@interface FRAPPDelegateHelper : NSObject<Singleton>

- (void)dosomethingWhenCurrentVersionFistLaunch;

+ (BOOL)isInThirdTab;

+ (BOOL)isConcernTabbar;

@end
