//
//  TTPersonalHomeErrorView.h
//  Article
//
//  Created by wangdi on 2017/4/12.
//
//

#import "SSThemed.h"

typedef enum {
    ErrorTypeNone,
    ErrorTypeNetWorkError,
    ErrorTypeClosureError,
    ErrorTypeClosureFollowError,
    ErrorTypeDataError
}ErrorType;

@interface TTPersonalHomeNavView: SSThemedView

@property (nonatomic, copy) void (^backBlock)();

@end

@interface TTPersonalHomeErrorView : SSThemedView

@property (nonatomic, assign) ErrorType errorType;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, copy) NSString *errorString;
@property (nonatomic, copy) void (^backBlock)();
@property (nonatomic, copy) void (^retryConnectionNetworkBlock)();

@end
