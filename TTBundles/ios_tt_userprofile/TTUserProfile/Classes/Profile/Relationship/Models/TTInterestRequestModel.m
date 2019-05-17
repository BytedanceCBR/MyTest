//
//  TTInterestRequestModel.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTInterestRequestModel.h"
#import "CommonURLSetting.h"
#import "TTInterestResponseModel.h"



@implementation TTInterestRequestModel
- (instancetype)init {
    if ((self = [super init])) {
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/2/user/concern_list/";
        self._method = @"GET";
        self._response = @"TTInterestResponseModel";
        
        [self initDefaultParams];
    }
    return self;
}

- (void)initDefaultParams {
    _user_id = nil;
    _offset  = @(0);
}

- (NSDictionary *)_requestParams {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    if (_user_id) [dict setValue:_user_id forKey:@"user_id"];
    if (_offset)  [dict setValue:_offset forKey:@"offset"];
    return dict;
}
@end
