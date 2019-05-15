//
//  TTCommonBridgeManager.h
//  TTRNKit
//
//  Created by renpeng on 2018/7/17.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeDelegate.h>
@class RCTBridge;
@class TTRNKit;
@class TTRNkitJSExceptionDelegate;

@interface TTCommonBridgeInfo : NSObject

@property (nonatomic, copy) NSString *channel;
@property (nonatomic, strong) RCTBridge *bridge;
@property (nonatomic, strong) id<RCTBridgeDelegate> bridgeDelegate; //retain delegate;
@property (nonatomic, strong) NSURL *bundleUrl;
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, assign) BOOL jsDidLoad;

- (void)enqueueJSDidLoadCompleiton:(dispatch_block_t)completion;

@end

@interface TTCommonBridgeManager : NSObject
+ (NSString *)bundleIdentifierForGeckoParams:(NSDictionary *)geckoParams
                                     channel:(NSString *)channel;

+ (TTCommonBridgeInfo *)webBridgeInfoWithManager:(TTRNKit *)manager
                                         channel:(NSString *)channel;

+ (TTCommonBridgeInfo *)bridgeWithGeckoParams:(NSDictionary *)geckoParams
                                      manager:(TTRNKit *)manager
                                      channel:(NSString *)channel;

+ (TTRNkitJSExceptionDelegate *)getExceptionDelegateForRNBridge:(id)bridge;

+ (void)removeBridgeForChannel:(NSString *)channel geckoParams:(NSDictionary *)geckoParams;
@end
