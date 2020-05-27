//
//  TTDefaultResponsePreprocessor.m
//  Article
//
//  Created by Dai Dongpeng on 4/27/16.
//
//

#import "TTDefaultResponsePreprocessor.h"
#import "TTRouteSelectionManager.h"

@interface TTDefaultResponsePreprocessor ()

@property (nonatomic, assign, readwrite) BOOL needsRetry;
@property (nonatomic, assign, readwrite) BOOL alertHijack;
@property (nonatomic, strong, readwrite) TTHttpRequest *retryRequest;
@property (nonatomic, assign, readwrite) NSUInteger retryTimes;

@end

@implementation TTDefaultResponsePreprocessor

+ (NSObject<TTResponsePreProcessorProtocol> *)processor
{
    TTDefaultResponsePreprocessor *processor = [TTDefaultResponsePreprocessor new];
    
    return processor;
}

- (void)preprocessWithResponse:(TTHttpResponse *)response responseObject:(id *)responseObject error:(NSError **)error ForRequest:(TTHttpRequest *)request
{
    [[TTRouteSelectionManager sharedTTRouteSelectionManager] checkIfNeedDoRouteSelection:request error:error];
}

- (void)finishPreprocess
{

}

@end

