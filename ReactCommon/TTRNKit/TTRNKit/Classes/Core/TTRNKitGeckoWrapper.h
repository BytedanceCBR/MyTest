//
//  TTRNKitGeckoWrapper.h
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/9/4.
//

#import <Foundation/Foundation.h>
@class TTRNKit;

@interface TTRNKitGeckoWrapper : NSObject

//默认以geckoParams里指定的channel来拉取gecko资源
+ (void)syncWithGeckoParams:(NSDictionary *)geckoParams
                 completion:(void (^)(BOOL bundleUpdate, BOOL bundleIsLatest, NSArray *channels))completion;

//指定channel来拉取gecko资源
+ (void)syncWithGeckoParams:(NSDictionary *)geckoParams
                   channels:(NSArray *)channels
                 completion:(void (^)(BOOL bundleUpdate, BOOL bundleIsLatest, NSArray *channels))completion;

@end
