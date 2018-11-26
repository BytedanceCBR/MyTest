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
//        _detectionBiz = [[CJLiveDetectionBiz alloc] init];
//        _detectionBiz.delegate = self;
        
    }
    return self;
}

-(void)registerJSBridge:(TTRStaticPlugin *)plugin
{
    __weak typeof(self) wself = self;
    
    [plugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSMutableDictionary *dic = [wself viewController].dic;
        //  "page_type" = priceChangeHistory;
//        [dic setObject:@"priceChangeHistory" forKey:@"page_type"];
        [dic setObject:@(1) forKey:@"code"];
        callback(TTRJSBMsgSuccess,dic);
    } forMethodName:@"requestPageData"];
    
}

@end
