//
//  TTWeChatShare+TTService.m
//  News
//
//  Created by Sunhaiyuan on 2018/2/4.
//
#import "TTWeChatShare.h"
#import "TTShareImageUtil.h"
#import "SSCommonLogic.h"
#import "TTWeChatShare+TTService.h"
#import "TTWeChatShare.h"
#import <WXApi.h>
#import <WXApiObject.h>

#define TTServiceDelegateKey @"TTServiceDelegateKey"

@implementation TTWeChatShare (TTService)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        
        SEL originalSel = @selector(onResp:);
        SEL swizzeledSel = @selector(toSwizzled_onResp:);
        
        Method originalMethod = class_getInstanceMethod(cls, originalSel);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzeledSel);
        
        BOOL success = class_addMethod(cls, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(cls, swizzeledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)toSwizzled_onResp:(BaseReq *)resp {
    
    [self toSwizzled_onResp:resp];
    
    if ([SSCommonLogic enableWXShareCallback]) {
        if (self.ttServiceDelegate && [self.ttServiceDelegate respondsToSelector:@selector(weChatShare:oldSharedWithError:customCallbackUserInfo:)]) {
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            
            [userInfo setValue:[resp valueForKey:@"errCode"] forKey:@"WXCode"];
            
            NSMutableDictionary *callBackInfo = [NSMutableDictionary dictionary];
            
            [callBackInfo setValue:@(YES) forKey:@"from_swzziled"];
            
            NSError *error = [NSError errorWithDomain:TTWeChatShareErrorDomain code:kTTWeChatShareErrorTypeOther userInfo:[userInfo copy]];
            
            //走ttServiceDelegate回调
            [self.ttServiceDelegate weChatShare:self oldSharedWithError:error customCallbackUserInfo:callBackInfo];
        }
    }
}

#pragma mark - property
- (id<TTWeChatShareTTServiceDelegate>)ttServiceDelegate {
    return objc_getAssociatedObject(self, @selector(ttServiceDelegate));
}

- (void)setTtServiceDelegate:(id<TTWeChatShareTTServiceDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(ttServiceDelegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}


@end

