//
//  SubscribeEntryGetRemoteDataOperation.m
//  Article
//
//  Created by Huaqing Luo on 20/11/14.
//
//

#import "SubscribeEntryGetRemoteDataOperation.h"
#import "ExploreFetchListDefines.h"
#import "NetworkUtilities.h"
#import "ExploreEntry.h"
#import "ListDataHeader.h"
#import "CommonURLSetting.h"
#import "TTNetworkManager.h"

@interface SubscribeEntryGetRemoteDataOperation()

@property(nonatomic, strong, readonly)NSString * urlString;
@property(nonatomic, strong, readonly)NSMutableDictionary * paramDict;

@end

@implementation SubscribeEntryGetRemoteDataOperation

@synthesize urlString = _urlString;
@synthesize paramDict = _paramDict;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL result = TTNetworkConnected();
            return result;
        };
    }
    
    return self;
}

- (NSString *)urlString
{
    if (!_urlString) {
        _urlString = [CommonURLSetting subscribeURLString];
    }
    
    return _urlString;
}

- (NSMutableDictionary *)paramDict
{
    if (!_paramDict)
    {
        _paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.lastRequestVersion, @"version", @(self.requestType), @"req_type", @(self.hasNewUpdatesIndicator), @"has_tip_new", nil];
    }
    else
    {
        [_paramDict setObject:self.lastRequestVersion forKey:@"version"];
        [_paramDict setObject:@(self.requestType) forKey:@"req_type"];
        [_paramDict setObject:@(self.hasNewUpdatesIndicator) forKey:@"has_tip_new"];
    }
    
    return _paramDict;
}

- (void)execute:(id)operationContext
{
    self.hasFinished = YES;
//    self.hasFinished = NO;
//    if (!self.shouldExecuteBlock(operationContext))
//    {
//        self.hasFinished = YES;
//        return;
//    }
//    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
//    if ([operationContext isKindOfClass:[NSDictionary class]]) {
//        userInfo = [[NSMutableDictionary alloc] initWithDictionary:operationContext];
//    }
//    WeakSelf;
//    [[TTNetworkManager shareInstance] requestForJSONWithURL:self.urlString params:self.paramDict method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//        StrongSelf;
//        if (!error) {
//            [userInfo setValue:jsonObj forKey:kExploreFetchListResponseRemoteDataKey];
//        }
//        [self notifyWithData:nil error:error userInfo:userInfo];
//        self.hasFinished = YES;
//    }];
}

@end
