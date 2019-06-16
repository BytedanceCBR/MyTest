//
//  TTFeedDislikeConfig.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/20.
//

#import <Foundation/Foundation.h>

/// 新版 disklie 的远程配置项。参见：http://settings.byted.org/static/main/index.html#/app_settings/item_detail?id=725
@interface TTFeedDislikeConfig : NSObject

+ (BOOL)enableModernStyle;

+ (NSArray<NSDictionary *> *)reportOptions;

+ (NSDictionary *)textStrings;

@end
