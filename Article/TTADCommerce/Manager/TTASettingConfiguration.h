//
//  TTASettingConfiguration.h
//  Article
//
//  Created by yin on 2018/1/23.
//

#import <Foundation/Foundation.h>

extern BOOL ttas_isVideoScrollPlayEnable(void);

extern BOOL ttas_isAutoPlayVideoPreloadEnable(void);

extern NSInteger ttas_autoPlayVideoPreloadResolution(void);

extern NSInteger ttas_isSplashSDKEnable(void);

@interface TTASettingConfiguration : NSObject

+ (void)setAdConfiguration:(NSDictionary *)dictionary;

+ (NSDictionary *)adConfiguration;

+ (id)valueForSettingKey:(NSString *)key defaultValue:(id)defaultValue;

@end
