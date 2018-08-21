//
//  TTDebugConsoleManager.h
//  Article
//
//  Created by gaohaidong on 6/24/16.
//
//

#import <Foundation/Foundation.h>

@interface TTDebugConsoleManager : NSObject

+ (instancetype)sharedTTDebugConsoleManager;
- (void)processCommand:(NSString *)command;

@end
