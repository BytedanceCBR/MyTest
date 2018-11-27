//
//  FHWebviewViewModel.m
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import "FHWebviewViewModel.h"
#import <TTRStaticPlugin.h>
#import <TTNetworkManager.h>
#import "FHWebviewViewController.h"

@interface FHWebviewViewModel()

@property(nonatomic , weak)  FHWebviewViewController *viewController;

@end

@implementation FHWebviewViewModel

-(instancetype)initWithViewController:(FHWebviewViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

-(void)registerJSBridge:(TTRStaticPlugin *)plugin jsParamDic:(NSDictionary *)param
{
    [param enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull methodName, NSDictionary*  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([methodName length] > 0) {
            NSMutableDictionary *callBackData = [NSMutableDictionary dictionaryWithDictionary:obj];
            [plugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
                [callBackData setObject:@(1) forKey:@"code"];
                [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull temObj, BOOL * _Nonnull stop) {
                    [callBackData setObject:temObj forKey:key];
                }];
                callback(TTRJSBMsgSuccess, callBackData);
            } forMethodName:methodName];
        }
    }];
}

@end
