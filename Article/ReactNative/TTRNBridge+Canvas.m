//
//  TTRNBridge+Canvas.m
//  Article
//
//  Created by yin on 2016/12/18.
//
//

#import "TTRNBridge+Canvas.h"
#import "SSSimpleCache.h"

@implementation TTRNBridge (Canvas)

/**
 *  调用json文件
 *
 */
RCT_EXPORT_METHOD(init_canvas:(RCTResponseSenderBlock)callback)
{
    NSString* jsonUrl = @"http://canvas.pstatp.com/origin/canvas.json";
    if ([[SSSimpleCache sharedCache] isCacheExist:jsonUrl]) {
        NSData* jsonData = [[SSSimpleCache sharedCache] dataForUrl:jsonUrl];
        NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        callback(@[@"success",jsonStr]);
    }
}

@end
