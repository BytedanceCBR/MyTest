//
//  TTVURLService.h
//  Article
//
//  Created by liuty on 2017/1/4.
//
//

#import <Foundation/Foundation.h>

//https://wiki.bytedance.net/pages/viewpage.action?pageId=55939299

@interface TTVURLService : NSObject
+ (NSString *)URLString:(NSString *)URLStr appendCommonParams:(NSDictionary *)commonParams;
+ (void)setHost:(NSString *)host;
+ (void)setCommonParameters:(NSDictionary *)commonParameters;
+ (void)setToutiaoVideoUserKey:(NSString *)toutiaoVideoUserKey;
+ (void)setToutiaoVideoSecretKey:(NSString *)toutiaoVideoSecretKey;
+ (NSString *)urlWithVideoId:(NSString *)videoId;
+ (NSString *)urlForV1WithVideoId:(NSString *)videoId;
+ (NSString *)urlForV1WithVideoId:(NSString *)videoId businessToken:(NSString *)businessToken;
+ (NSString *)urlForV2WithPlayerAuthToken:(NSString *)playerAuthToken businessToken:(NSString *)businessToken playerV2URL:(NSString *)playerV2URL;
@end

