//
//  WDCommonURLSetting.h
//  Article
//
//  Created by xuzichao on 2017/5/22.
//
//

@interface WDCommonURLSetting : NSObject

+ (NSString *)baseURL;
+ (NSString*)searchWebURLString;

//单例配置
+ (instancetype)sharedInstance;
- (void)setDomainBaseURL:(NSString *)baseUrl;

@end
