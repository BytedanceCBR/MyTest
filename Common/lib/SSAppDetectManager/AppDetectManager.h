//
//  AppDetectManager.h
//  Article
//
//  Created by Dianwei on 13-4-2.
//
//

#import <Foundation/Foundation.h>

#define kRecentAppStorageKey         @"kRecentAppStorageKey"

@interface AppDetectManager : NSObject

+ (AppDetectManager*)sharedManager;
- (void)startAppDetect;

@end
