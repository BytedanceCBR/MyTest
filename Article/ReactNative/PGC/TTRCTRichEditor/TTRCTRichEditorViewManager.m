//
//  TTRCTRichEditorViewManager.m
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#import <Foundation/Foundation.h>
#import "TTRCTRichEditorViewManager.h"
#import "RCTUIManager.h"

@implementation TTRCTRichEditorViewManager

#pragma mark - react methods
RCT_EXPORT_MODULE(RCTRichEditor)

- (UIView *)view {
    TTRCTRichEditorView * richEditorView = [[TTRCTRichEditorView alloc] init];
    richEditorView.delegate = self;
    return richEditorView;
}

// 执行js
RCT_EXPORT_METHOD(evaluateJavascript:(nonnull NSNumber *)reactTag args:(NSString *) js) {
    [self addUIBlock:reactTag block:^(TTRCTRichEditorView * view) {
        [view evaluateJavascript:js];
    }];
}

// 关闭键盘
RCT_EXPORT_METHOD(hideKeyboard:(nonnull NSNumber *)reactTag) {
    [self addUIBlock:reactTag block:^(TTRCTRichEditorView * view) {
        [view hideKeyboard];
    }];
    // 处理editor view以外的键盘
    // 后期把这个接口迁移出view manager
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bridge.uiManager rootViewForReactTag:reactTag withCompletion:^(UIView * view) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (view) {
                    [view endEditing:YES];
                }
            });
        }];
    });
}

// 开启键盘
RCT_EXPORT_METHOD(showKeyboard:(nonnull NSNumber *)reactTag) {
    [self addUIBlock:reactTag block:^(TTRCTRichEditorView * view) {
        [view showKeyboard];
    }];
}

// 发送事件给RN
- (void)emitToRN:(NSString *)eventName params:(id)params {
    if (!eventName) {
        return;
    }
    [self.bridge.eventDispatcher sendAppEventWithName:eventName body:params];
}

- (void)addUIBlock:(NSNumber *)reactTag
             block:(void(^)(TTRCTRichEditorView * view))block {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, TTRCTRichEditorView *> *viewRegistry) {
        TTRCTRichEditorView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[TTRCTRichEditorView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting TTRCTRichEditorView, got: %@", view);
        } else {
            block(view);
        }
    }];
}

#pragma mark - RCTRichEditorViewDelegate
- (void)on:(NSString *)eventName data:(id)data {
    [self emitToRN:eventName params:data];
}

@end
