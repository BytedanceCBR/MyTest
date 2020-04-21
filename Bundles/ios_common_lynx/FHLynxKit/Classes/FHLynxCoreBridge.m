//
//  FHLynxCoreBridge.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxCoreBridge.h"
#import <CoreGraphics/CGBase.h>
#import "TTRoute.h"

@implementation FHLynxCoreBridge

+ (NSString *)name {
    return @"BDLynxCoreBridge";
}

+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"openSchema" : NSStringFromSelector(@selector(openSchema:)),
    };
}

- (void)openSchema:(NSString *)schema {
    
    void (^invokBlock)(void) = ^() {
        NSURL *openUrl =  [NSURL URLWithString:schema];
          if(openUrl)
          {
              [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:nil];
          }
//        [BDLUtils openSchema:schema];
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

@end
