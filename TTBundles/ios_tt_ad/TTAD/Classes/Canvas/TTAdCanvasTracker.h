//
//  TTAdCanvasTracker.h
//  Article
//
//  Created by carl on 2017/5/17.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"
#import "TTAdCanvasDefine.h"

//https://wiki.bytedance.net/pages/viewpage.action?pageId=78250184
//沉浸式广告打点统计

@interface TTAdCanvasTracker : NSObject
+ (instancetype)tracker:(id<TTAd>)model;
+ (void)trackerWithModel:(id<TTAd>) model tag:(NSString*)tag label:(NSString*)label extra:(NSDictionary*)extra;

- (void)trackCanvasRN:(NSDictionary *)dict;
- (void)trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict;

- (void)wap_load;
- (void)wap_loadfinish;
- (void)wap_loadfail;
- (void)wap_staypage;

- (void)native_page;
- (void)trackLeave;

@end


