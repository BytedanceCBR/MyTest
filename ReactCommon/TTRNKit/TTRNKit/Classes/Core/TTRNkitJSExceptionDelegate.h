//
//  TTRNkitJSExceptionDelegate.h
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/9/4.
//

#import <Foundation/Foundation.h>
#import "TTRNKit.h"

@interface TTRNkitJSExceptionDelegate : NSObject <TTRNKitObserverProtocol>

@property (nonatomic, copy, readonly) NSString *channel;
@property (nonatomic, copy, readonly) NSString *bundleIdentifier;
@property (nonatomic, assign) BOOL fallBack;

+ (BOOL)fallBackForChannel:(NSString *)channel;
+ (void)setFallBackForChannelsInPersistence:(NSArray *)channels;
- (instancetype)initWithChannel:(NSString *)channel bundleIdentifier:(NSString *)identifier;

@end
