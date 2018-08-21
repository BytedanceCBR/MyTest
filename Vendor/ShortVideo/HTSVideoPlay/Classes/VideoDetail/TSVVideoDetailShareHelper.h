//
//  TSVVideoDetailShareHelper.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2017/11/29.
//

#import <Foundation/Foundation.h>

@class TTShortVideoModel;

@interface TSVVideoDetailShareHelper : NSObject

+ (void)handleForwardUGCVideoWithModel:(TTShortVideoModel *)model;
//+ (void)handleSaveVideoWithModel:(TTShortVideoModel *)model;
+ (NSDictionary *)repostParamsWithShortVideoModel:(TTShortVideoModel *)model;
@end
