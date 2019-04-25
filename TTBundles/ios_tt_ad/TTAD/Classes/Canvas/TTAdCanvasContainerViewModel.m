//
//  TTAdCanvasContainerViewModel.m
//  Article
//
//  Created by carl on 2017/7/16.
//
//

#import "TTAdCanvasContainerViewModel.h"

#import "SSWebViewController.h"
#import "TTAdCanvasVC.h"
#import "TTAdCanvasViewController.h"
#import "TTNetworkManager.h"

@interface TTAdCanvasContainerViewModel ()
@property (nonatomic, strong) TTRouteParamObj *paramObj;
@property (nonatomic, copy) NSString *layout_url;
@end

@implementation TTAdCanvasContainerViewModel

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        NSDictionary *queryParams = paramObj.queryParams;
        self.openDetailViewStyle = [queryParams[@"open_style"] integerValue];
        self.layout_url = queryParams[@"layout_url"];
        self.detailViewModel = [[TTAdCanvasViewModel alloc] initWithCondition:queryParams];
        self.detailViewModel.openStrategy = TTAdCanvasOpenAnimationPush;
    }
    return self;
}

- (SSViewControllerBase<TTAdCanvasViewController> *)detailViewController {
    SSViewControllerBase<TTAdCanvasViewController> *detailViewController = nil;
    switch (self.openDetailViewStyle) {
        case TTAdCnavasDetailViewStyleRN:
            detailViewController = [[TTAdCanvasViewController alloc] initWithViewModel:self.detailViewModel];
            break;
        case TTAdCnavasDetailViewStyleNative:
            detailViewController = [[TTAdCanvasVC alloc] initWithViewModel:self.detailViewModel];
            break;
        case TTAdCnavasDetailViewStyleWeb:
            detailViewController = (SSViewControllerBase<TTAdCanvasViewController> *)[[SSWebViewController alloc] initWithRouteParamObj:self.paramObj];
        default:
            break;
    }
    return detailViewController;
}

- (void)fetchCanvasInfomationWithComplete:(void(^)())completion  {
    NSString *urlString = self.layout_url;
    if (isEmptyString(urlString)) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        __strong typeof(self) strongSelf = weakSelf;
        if (obj) {
            NSData *data = (NSData *)obj;
            NSError *jsonError;
            NSDictionary *layoutDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            strongSelf.detailViewModel.layoutInfo = layoutDict;
            if (completion) {
                completion();
            }
        }
    }];
}

@end
