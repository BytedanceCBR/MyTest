//
//  TTUserFollowJSONModels.m
//  Article
//
//  Created by 徐霜晴 on 16/12/15.
//
//

#import "TTBlockApiModels.h"
#import "TTURLDomainHelper.h"

@implementation TTBlockStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void) reset
{
    self.desc = nil;
    self.errorCode = 0;
    self.blockUserID = nil;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"error_code" : @"errorCode",
                           @"description" : @"desc",
                           @"block_user_id" : @"blockUserID"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end

@implementation TTBlockResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
}
@end

@implementation TTBlockRequestModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
        self._uri = @"/user/block/create";
        self._response = @"TTBlockResponseModel";
    }
    return self;
}

- (NSDictionary *)_requestParams {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_block_user_id forKey:@"block_user_id"];
    return params;
}

@end

@implementation  TTUnBlockRequestModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
        self._uri = @"/user/block/cancel";
        self._response = @"TTBlockResponseModel";
    }
    return self;
}

- (NSDictionary *)_requestParams {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_block_user_id forKey:@"block_user_id"];
    return params;
}

@end

@implementation TTBlockUserListRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
        self._uri = @"/user/block/list";
        self._response = @"TTBlockUserListResponseModel";
    }
    
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:@(_offset) forKey:@"offset"];
    [params setValue:@(_count) forKey:@"count"];
    return params;
}

@end

@implementation TTBlockUserListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
}
@end
