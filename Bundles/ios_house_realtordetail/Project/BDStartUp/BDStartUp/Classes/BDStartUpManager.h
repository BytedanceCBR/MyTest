//
//  BDStartUpManager.h
//  BDStartUp
//
//  Created by jialei on 2018/5/15.
//

#import <Foundation/Foundation.h>

@interface BDStartUpManager : NSObject

@property (nonatomic,copy) NSString *appID;
@property (nonatomic,copy) NSString *channel;
@property (nonatomic,copy) NSString *appName;
// 注册 Crashlytics 的key
@property (nonatomic,copy) NSString *apiKey;
// 微信分享
@property (nonatomic,copy) NSString *wxApp;

+ (instancetype) sharedInstance;

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;

@end

@protocol BDStartUpTaskProtocol <NSObject>

@required
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;

@optional
- (BOOL)startInBackground;

@end

