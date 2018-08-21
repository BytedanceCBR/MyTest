//
//  JSONModel+Monitor.m
//  Article
//
//  Created by lizhuoli on 16/12/14.
//
//

#import <objc/runtime.h>
#import "JSONModel+Monitor.h"
#import "SSCommonLogic.h"

@implementation JSONModel (Monitor)

NSString * const kJSONModelException = @"kJSONModelException";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class instanceClass = [self class];
        Class classClass = object_getClass((id)self);
        
        MethodSwizzle(instanceClass, @selector(initWithString:error:), @selector(initWithString_swizzled:error:));
        MethodSwizzle(instanceClass, @selector(initWithString:usingEncoding:error:), @selector(initWithString_swizzled:usingEncoding:error:));
        MethodSwizzle(instanceClass, @selector(initWithDictionary:error:), @selector(initWithDictionary_swizzled:error:));
        MethodSwizzle(instanceClass, @selector(initWithData:error:), @selector(initWithData_swizzled:error:));
        MethodSwizzleForClass(classClass, @selector(arrayOfModelsFromDictionaries:error:), @selector(arrayOfModelsFromDictionaries_swizzled:error:));
        MethodSwizzleForClass(classClass, @selector(arrayOfModelsFromData:error:), @selector(arrayOfModelsFromData_swizzled:error:));
    });
}

#pragma mark - Method Swizzling

static void MethodSwizzle(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static void MethodSwizzleForClass(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Swizzled Method

- (instancetype)initWithString_swizzled:(NSString*)string error:(JSONModelError**)err
{
    Class class = [self class];
    __autoreleasing JSONModelError *error;
    if (!err) {
        err = &error;
    }
    
    @try {
        self = [self initWithString_swizzled:string error:err];
    } @catch (NSException *exception) {
        *err = [JSONModelError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
        
        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && string) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return self;
}

- (instancetype)initWithString_swizzled:(NSString *)string usingEncoding:(NSStringEncoding)encoding error:(JSONModelError**)err
{
    Class class = [self class];
    __autoreleasing JSONModelError *error;
    if (!err) {
        err = &error;
    }
    
    @try {
        self = [self initWithString_swizzled:string usingEncoding:encoding error:err];
    } @catch (NSException *exception) {
        *err = [JSONModelError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }

        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && string) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return self;
}

- (instancetype)initWithDictionary_swizzled:(NSDictionary*)dict error:(NSError **)err
{
    Class class = [self class];
    __autoreleasing NSError *error;
    if (!err) {
        err = &error;
    }
    
    @try {
        self = [self initWithDictionary_swizzled:dict error:err];
    } @catch (NSException *exception) {
        *err = [NSError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
        
        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && dict) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return self;
}

- (instancetype)initWithData_swizzled:(NSData *)data error:(NSError **)err
{
    Class class = [self class];
    __autoreleasing NSError *error;
    if (!err) {
        err = &error;
    }
    
    @try {
        self = [self initWithData_swizzled:data error:err];
    } @catch (NSException *exception) {
        *err = [NSError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
        
        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && data) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return self;
}

+ (NSMutableArray*)arrayOfModelsFromDictionaries_swizzled:(NSArray*)array error:(NSError**)err
{
    Class class = [self class];
    __autoreleasing NSError *error;
    if (!err) {
        err = &error;
    }
    
    id result = nil;
    @try {
        result = [class arrayOfModelsFromDictionaries_swizzled:array error:err];
    } @catch (NSException *exception) {
        *err = [NSError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }

        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && array) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return result;
}

+ (NSMutableArray*)arrayOfModelsFromData_swizzled:(NSData*)data error:(NSError**)err
{
    Class class = [self class];
    __autoreleasing NSError *error;
    if (!err) {
        err = &error;
    }
    
    id result = nil;
    @try {
        result = [class arrayOfModelsFromData_swizzled:data error:err];
    } @catch (NSException *exception) {
        *err = [NSError errorWithDomain:JSONModelErrorDomain code:-1 userInfo:@{kJSONModelException : exception}];
        // swicher to turn on monitor
        if ([SSCommonLogic enableJSONModelMonitor]) {
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelException:exception];
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
        
        return nil;
    }
    
    if ([SSCommonLogic enableJSONModelMonitor]) {
        if (*err && data) {
            // ignore nil input
            NSString *className = NSStringFromClass(class);
            NSString *cmdName = NSStringFromSelector(_cmd);
            NSDictionary *errDict = [JSONModel dictionaryOfJSONModelError:*err];
            [JSONModel trackErrorWithClassName:className cmdName:cmdName errorDictionary:errDict];
        }
    }
    
    return result;
}

#pragma mark - JSONModel Error type convert

static NSString* stringOfJSONModelErrorType(kJSONModelErrorTypes errorType)
{
    switch (errorType) {
        case kJSONModelErrorInvalidData:
            return @"Invalid Data";
            break;
        case kJSONModelErrorBadResponse:
            return @"Bad Response";
            break;
        case kJSONModelErrorBadJSON:
            return @"Bad JSON";
            break;
        case kJSONModelErrorModelIsInvalid:
            return @"Model Is Invalid";
            break;
        case kJSONModelErrorNilInput:
            return @"Nil Input";
            break;
        default:
            return @"Unknown";
            break;
    }
}

#pragma makr - Exception to Dictionary
+ (NSDictionary *)dictionaryOfJSONModelException:(NSException *)exception
{
    // catch JSONModel throws exception(for programmer mistake)
    NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithCapacity:2];
    errDict[@"error_name"] = exception.name;
    errDict[@"error_description"] = exception.reason;
    
    return errDict;
}

#pragma mark - Error to Dictionary
+ (NSDictionary *)dictionaryOfJSONModelError:(NSError *)err
{
    if (!err || ![err.domain isEqualToString:JSONModelErrorDomain]) return nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    // JSONModelError has more error info
    if ([err isKindOfClass:[JSONModelError class]]) {
        JSONModelError *jsonErr = (JSONModelError *)err;
        NSHTTPURLResponse *response = jsonErr.httpResponse;
        if (response) {
            NSDictionary *allHeaderFields = response.allHeaderFields;
            NSInteger statusCode = response.statusCode;
            
            dict[@"response_status_code"] = @(statusCode);
            dict[@"response_header"] = allHeaderFields;
        }
    }
    
    NSDictionary *userInfo = err.userInfo;
    
    // Error name
    int errorCode = (int)err.code;
    NSString* errorName = stringOfJSONModelErrorType(errorCode);
    dict[@"error_name"] = errorName;
    // Error description
    NSString *errorDescription = userInfo[NSLocalizedDescriptionKey];
    if (errorDescription) {
        dict[@"error_description"] = errorDescription;
    }
    // Missing keys
    if (userInfo[kJSONModelMissingKeys]) {
        dict[@"missing_keys"] = userInfo[kJSONModelMissingKeys];
    }
    // Type mismatch
    if (userInfo[kJSONModelTypeMismatch]) {
        dict[@"type_missmatch"] = userInfo[kJSONModelTypeMismatch];
    }
    // Nested model error keypath
    if (userInfo[kJSONModelKeyPath]) {
        dict[@"nested_error_keypath"] = userInfo[kJSONModelKeyPath];
    }
    
    return dict;
}

#pragma mark - Send Log

+ (void)trackErrorWithClassName:(NSString *)class cmdName:(NSString *)cmd errorDictionary:(NSDictionary *)errDict
{
    if (!errDict) return;
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:errDict];
    
    extraDic[@"init_class"] = class;
    extraDic[@"init_cmd"] = cmd;

#if DEBUG
    TLS_LOG(@"Debug - JSONModel Error:\n%@", extraDic);
#else
    [[TTMonitor shareManager] trackService:@"jsonmodel_error" status:1 extra:extraDic];
#endif
}

@end
