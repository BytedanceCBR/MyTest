//
//  TTRNBridgeModule.h
//  Article
//
//  Created by Chen Hong on 16/7/15.
//
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#import "TTRNView.h"

#define kTTRNBridgeActiveRefreshListViewNotification @"kTTRNBridgeActiveRefreshListViewNotification"

#define kRNReportPageStatus @"kRNReportPageStatus"

@interface TTRNBridge : NSObject <RCTBridgeModule>

@property (nonatomic, weak, nullable) TTRNView *rnView;

- (void)invokeJSWithEventID:(NSString * _Nonnull)eventID parameters:(NSDictionary * _Nullable)params;

@end
