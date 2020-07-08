//
//  WKWebView+AssistantProtect.m
//  FHWebView
//
//  Created by 春晖 on 2020/5/14.
//

#import "WKWebView+AssistantProtect.h"
#import <objc/runtime.h>
#import <ByteDanceKit/NSString+BTDAdditions.h>



void * wkprotect = &wkprotect;

@implementation WKWebView (AssistantProtect)

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self addProtect];
    });
}


+(void)addProtect
{            
    NSString *contentView = [@"V0tDb250ZW50Vmlldw==" btd_base64DecodedString];
    Class contentViewClass =  NSClassFromString(contentView);//@"WKContentView"
    SEL sel = NSSelectorFromString(@"webSelectionAssistant");
    
    BOOL find = NO;
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(contentViewClass, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        SEL csel = method_getName(methodList[i]);
        if (csel == sel) {
            find = YES;
            break;
        }
    }
    
    if (!find) {
        class_addMethod(contentViewClass, sel, (IMP)webSelectionAssistant, "@16@0:8");
    }
          
}

id webSelectionAssistant()
{
    return nil;
}

@end



