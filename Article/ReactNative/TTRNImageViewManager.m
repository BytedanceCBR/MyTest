//
//  TTRNImageViewManager.m
//  Article
//
//  Created by Chen Hong on 2016/10/25.
//
//

#import "TTRNImageViewManager.h"
#import "TTRNImageView.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "UIView+React.h"

@implementation TTRNImageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNImageView *imageView = [[TTRNImageView alloc] init];
    return imageView;
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, RCTResizeMode)

//RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)reactTag)
//{
//    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, TTRNWebView *> *viewRegistry) {
//        TTRNWebView *view = viewRegistry[reactTag];
//        if (![view isKindOfClass:[TTRNWebView class]]) {
//            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
//        } else {
//            [view goBack];
//        }
//    }];
//}
//
@end
