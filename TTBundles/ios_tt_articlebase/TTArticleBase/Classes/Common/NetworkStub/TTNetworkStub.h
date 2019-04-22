//
//  TTNetworkStub.h
//  Article
//
//  Created by 延晋 张 on 16/5/30.
//
//

#import <Foundation/Foundation.h>

@interface TTNetworkStub : NSObject

/**
 * 默认 Enabled:YES
 **/
+ (void)setEnabled:(BOOL)enabled;
+ (instancetype)sharedInstance;
- (void)setupStub:(NSString *)stubName withConfigArray:(NSArray *)configArray;
- (void)removeStub:(NSString *)stubName;
- (void)restoreAllStubs;

@end

