//
//  TTRWenda.m
//  Article
//
//  Created by 延晋 张 on 2017/11/7.
//

#import "TTRWenda.h"
#import <TTRexxar/TTRJSBForwarding.h>

@implementation TTRWenda

- (void)deleteAnswerDraftWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSString *qid = [param tt_stringValueForKey:@"qid"];
}

@end
