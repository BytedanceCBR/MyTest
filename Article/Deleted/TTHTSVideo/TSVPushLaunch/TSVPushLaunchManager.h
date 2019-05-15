//
//  TSVPushLaunchManager.h
//  Article
//
//  Created by dingjinlu on 2017/12/18.
//

#import <Foundation/Foundation.h>

@interface TSVPushLaunchManager : NSObject

@property (nonatomic, assign) BOOL shouldAutoRefresh;

+ (instancetype)sharedManager;

- (void)launchIntoTSVTabIfNeedWithURL:(NSString *)openURL;

@end
