//
//  TTAccountBaseModel.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountBaseModel.h"
#import "TTAccountDefine.h"
#import "NSString+TTAccountUtils.h"



#pragma mark - TTABaseReqModel

@implementation TTABaseReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    return self;
}
@end


#pragma mark - TTABaseRespModel

@interface TTABaseRespModel ()
@property (nonatomic, strong) NSNumber *ttaCreateTimeStamp;
@end
@implementation TTABaseRespModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:NSStringFromSelector(@selector(ttaCreateTimeStamp))])
        return YES;
    return NO;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.ttaCreateTimeStamp = @([[NSDate date] timeIntervalSince1970]);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (!dict) return nil;
    if ((self = [self init])) {
        if (![self tta_modelSetWithDictionary:dict]) {
            NSError *error = [NSError errorWithDomain:@"TTAccountModellingErrorDomain" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"JSON to Model 错误"}];
            if (*err) {
                *err = error;
            }
            return nil;
        }
    }
    return self;
}

- (BOOL)isRespSuccess
{
    NSString *formattedMsg = [self.message lowercaseString];
    return [formattedMsg tta_containsString:@"success"];
}

- (BOOL)isServerError
{
    NSString *formattedMsg = [self.message lowercaseString];
    return [formattedMsg tta_containsString:@"exception"];
}

- (BOOL)isClientError
{
    NSString *formattedMsg = [self.message lowercaseString];
    return [formattedMsg tta_containsString:@"error"];
}

- (BOOL)isOtherRespError
{
    return (![self isClientError] &&
            ![self isServerError] &&
            ![self isRespSuccess] &&
            ([self.message length] > 0));
}

- (NSInteger)errorCode
{
    if ([self isRespSuccess]) {
        return TTAccountSuccess;
    }
    if ([self isServerError]) {
        return TTAccountErrCodeServerException;
    }
    if ([self isClientError]) {
        return TTAccountErrCodeClientParamsInvalid;
    }
    
    NSNumber *dataErrNumber = [self errcodeInData];
    if (dataErrNumber && [dataErrNumber respondsToSelector:@selector(integerValue)]) {
        return [dataErrNumber integerValue];
    }
    
    return TTAccountErrCodeUnknown;
}

- (NSNumber *)errcodeInData
{
    if ([self valueForKey:@"data"]) {
        if ([[self valueForKey:@"data"] valueForKey:@"error_code"]) {
            NSNumber *errcodeNumber = [[self valueForKey:@"data"] valueForKey:@"error_code"];
            if ([errcodeNumber isKindOfClass:[NSNumber class]]) {
                return errcodeNumber;
            }
        }
        
        if ([[self valueForKey:@"data"] valueForKey:@"code"]) {
            NSNumber *errcodeNumber = [[self valueForKey:@"data"] valueForKey:@"code"];
            if ([errcodeNumber isKindOfClass:[NSNumber class]]) {
                return errcodeNumber;
            }
        }
    }
    return nil;
}

- (NSString *)errorDescription
{
    if ([self valueForKey:@"error_description"]) {
        NSString *errDesp = [self valueForKey:@"error_description"];
        if ([errDesp isKindOfClass:[NSString class]]) {
            return errDesp;
        }
    }
    
    if ([[self valueForKey:@"data"] valueForKey:@"error_description"]) {
        NSString *errDesp = [self valueForKey:@"error_description"];
        if ([errDesp isKindOfClass:[NSString class]]) {
            return errDesp;
        }
    }
    return nil;
}

- (NSDictionary *)toDictionary
{
    return [self tta_modelToJSONObject];
}
@end



#pragma mark - TTADataRespModel

@implementation TTADataRespModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (!dict) return nil;
    if ((self = [super init])) {
        if (![self tta_modelSetWithDictionary:dict]) {
            NSError *error = [NSError errorWithDomain:@"TTAccountModellingErrorDomain" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"JSON to Model 错误"}];
            if (*err) {
                *err = error;
            }
            return nil;
        }
    }
    return self;
}

- (NSNumber *)errcode
{
    if ([self respondsToSelector:@selector(code)]) {
        NSNumber *codeNumber = [self valueForKey:@"code"];
        if ([codeNumber isKindOfClass:[NSNumber class]]) {
            return codeNumber;
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(error_code)]) {
        NSNumber *codeNumber = [self valueForKey:@"error_code"];
        if ([codeNumber isKindOfClass:[NSNumber class]]) {
            return codeNumber;
        }
    }
#pragma clang diagnostic pop
    
    return nil;
}

- (NSString *)errmsg
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(error_description)]) {
        NSString *msgString = [self valueForKey:@"error_description"];
        if ([msgString isKindOfClass:[NSString class]]) {
            return msgString;
        }
    }
#pragma clang diagnostic pop
    return nil;
}

- (NSDictionary *)toDictionary
{
    return [self tta_modelToJSONObject];
}
@end
