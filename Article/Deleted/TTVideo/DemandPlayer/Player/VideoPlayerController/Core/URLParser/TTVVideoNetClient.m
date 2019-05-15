//
//  TTVVideoNetClient.m
//  Article
//
//  Created by guikunzhi on 2017/10/17.
//

#import "TTVVideoNetClient.h"
#import "TTNetworkManager.h"

@interface TTVVideoNetClient()

@property (nonatomic, strong) TTHttpTask *httpTask;

@end

@implementation TTVVideoNetClient

- (void)configTaskWithURL:(NSURL *)url completion:(void (^)(id _Nullable jsonObject, NSError * _Nullable error))completionHandler {
    [self configTaskWithURL:url params:nil completion:completionHandler];
}

- (void)configTaskWithURL:(NSURL *)url params:(NSDictionary *)params completion:(void (^)(id _Nullable jsonObject, NSError * _Nullable error))completionHandler {
    self.httpTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:[url absoluteString]
                                                                     params:params
                                                                     method:@"GET"
                                                           needCommonParams:YES
                                                                   callback:^(NSError *error, id jsonObj) {
                                                                       completionHandler(jsonObj,error);
                                                                   }];
}

- (void)cancel {
    [self.httpTask cancel];
}

- (void)resume {
    [self.httpTask resume];
}

- (void)invalidAndCancel {
    [self.httpTask cancel];
    self.httpTask = nil;
}

@end
