//
//  TTWebviewAntiHijackServerConfig.h
//  Article
//
//  Created by gaohaidong on 8/22/16.
//
//

#import <Foundation/Foundation.h>

@interface TTWebviewAntiHijackServerConfig : NSObject

@property (atomic, readonly) BOOL isEnabled;

+ (TTWebviewAntiHijackServerConfig *)sharedTTWebviewAntiHijackServerConfig;

- (void)updateServerConfig:(NSDictionary *)serverData;

- (BOOL)isInBlackList:(NSURL *)url;

@end
