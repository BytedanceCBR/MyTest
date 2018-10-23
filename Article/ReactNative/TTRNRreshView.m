//
//  TTRNRreshView.m
//  Pods
//
//  Created by yangning on 2017/6/26.
//
//

#import "TTRNRreshView.h"
#import "RCTUIManager.h"
#import "RCTScrollView.h"
#import <TTUIWidget/TTRefreshView.h>
#import "UIScrollView+Refresh.h"

NSString *const TTRNRefreshViewPullDownRefreshNotification = @"TTRNRefreshViewPullDownRefreshNotification";
NSString *const TTRNRefreshViewPullDownRefreshScrollView   = @"TTRNRefreshViewPullDownRefreshScrollView";

static NSString *const kTTRNRefreshViewDidBeginRefreshingEvent = @"TTRNRefreshViewDidBeginRefreshing";

@implementation TTRNRefreshView

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(configure:(nonnull NSNumber *)reactTag
                  options:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;
        
        NSString *normalText = [RCTConvert NSString:options[@"normalText"]] ?: @"下拉刷新";
        NSString *pullingText = [RCTConvert NSString:options[@"pullingText"]] ?: @"松开即可刷新";
        NSString *loadingText = [RCTConvert NSString:options[@"loadingText"]] ?: @"正在努力加载";
        NSString *noMoreText = [RCTConvert NSString:options[@"noMoreText"]] ?: @"暂无新数据";
        
        __weak UIScrollView *weakScrollView = scrollView;
        [scrollView addPullDownWithInitText:normalText
                                   pullText:pullingText
                                loadingText:loadingText
                                 noMoreText:noMoreText
                                   timeText:nil
                                lastTimeKey:nil
                              actionHandler:^{
                                  UIScrollView *strongScrollView = weakScrollView;
                                  [self.bridge.eventDispatcher sendDeviceEventWithName:kTTRNRefreshViewDidBeginRefreshingEvent
                                                                                  body:reactTag];
                                  if (strongScrollView) {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:TTRNRefreshViewPullDownRefreshNotification
                                                                                          object:nil
                                                                                        userInfo:@{ TTRNRefreshViewPullDownRefreshScrollView: strongScrollView }];
                                  }
                              }];
        scrollView.pullDownView.tag = [reactTag integerValue];
        
        callback(@[[NSNull null], reactTag]);
    }];
}

RCT_EXPORT_METHOD(beginRefreshing:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;
        
        TTRefreshView *refreshControl = (TTRefreshView *)[scrollView viewWithTag:[reactTag integerValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl triggerRefresh];
        });
    }];
}

RCT_EXPORT_METHOD(endRefreshing:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        
        UIView *view = viewRegistry[reactTag];
        if (!view) {
            RCTLogError(@"Cannot find view with tag #%@", reactTag);
            return;
        }
        
        UIScrollView *scrollView = ((RCTScrollView *)view).scrollView;
        
        TTRefreshView *refreshControl = (TTRefreshView *)[scrollView viewWithTag:[reactTag integerValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl stopAnimation:YES];
        });
    }];
}

@end
