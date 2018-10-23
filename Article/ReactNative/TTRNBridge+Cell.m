//
//  TTRNBridge+Cell.m
//  Article
//
//  Created by Chen Hong on 16/8/15.
//
//

#import "TTRNBridge+Cell.h"
#import "ExploreMixListDefine.h"

@implementation TTRNBridge (Cell)

/**
 *  panelClose
 */
RCT_EXPORT_METHOD(panelClose) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListCloseWebCellNotification object:self.rnView userInfo:@{@"action": @"close"}];
}

RCT_EXPORT_METHOD(panelDislike) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListCloseWebCellNotification object:self.rnView userInfo:nil];
}

/**
 *  feed cell显示不感兴趣菜单
 *  dict: {"x":x, "y":y}
 */
RCT_EXPORT_METHOD(showDislike:(NSDictionary *)dict callback:(RCTResponseSenderBlock)callback) {
    self.dislikeCallback = callback;
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListShowDislikeNotification object:self.rnView userInfo:dict];
}

#pragma mark - dislike菜单点确认
- (void)dislikeConfirmed {
    if (self.dislikeCallback) {
        self.dislikeCallback(@[@{@"code": @1}]);
        self.dislikeCallback = nil;
    }
}

@end
