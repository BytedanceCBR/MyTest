//
//  TTVisitorRequestModel.m
//  Article
//
//  Created by it-test on 8/22/16.
//
//

#import "TTVisitorRequestModel.h"
#import "CommonURLSetting.h"
#import "TTVisitorModel.h"
#import "FriendDataManager.h"

@implementation TTVisitorRequestModel
- (instancetype)init {
    if ((self = [super init])) {
        self._host = [CommonURLSetting baseURL];
        self._uri = [FriendDataURLSetting visitorHistoryURLString];
        self._method = @"GET";
        self._response = @"TTVisitorModel";
        
        [self initDefaultParams];
    }
    return self;
}

- (void)initDefaultParams {
    _user_id = nil;
    _cursor  = nil;
    _count   = @(50);
}

- (NSDictionary *)_requestParams {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    if (_user_id) [dict setValue:_user_id forKey:@"user_id"];
    if (_cursor)  [dict setValue:_cursor forKey:@"cursor"];
    if (_count)   [dict setValue:_count forKey:@"count"];
    return dict;
}
@end
