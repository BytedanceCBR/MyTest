//
//  NSObject+TTASafeInvocation.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 5/3/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "NSObject+TTASafeInvocation.h"



@implementation NSObject (tta_SafeInvocation)

- (id)tta_safePerformSelector:(SEL)aSelector withObjects:(NSArray *)args
{
    return [self tta_safeInvokeSelector:aSelector arguments:args];
}

- (id)tta_safePerformSelector:(SEL)aSelector withObject:(id)object withPrimitive:(void *)pointer
{
    if (!aSelector) {
        return nil;
    }
    
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArgs = [signature numberOfArguments] - 2;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target   = self;
    invocation.selector = aSelector;
    
    if (numberOfArgs >= 2) {
        [invocation setArgument:&object atIndex:2];
        
        if (pointer) {
            
            [invocation setArgument:pointer atIndex:3];
            
        } else {
            
            const char *pointerArgType = [invocation.methodSignature getArgumentTypeAtIndex:3];
            
#define CASE_PRIMITIVE_TYPE(ctype) (strcmp(pointerArgType, @encode(ctype)) == 0)
            
            if (CASE_PRIMITIVE_TYPE(BOOL)) {
                BOOL boolValue = NO;
                [invocation setArgument:&boolValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(char)) {
                char charValue = '0';
                [invocation setArgument:&charValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(unsigned char)) {
                unsigned char unsignedCharValue = '0';
                [invocation setArgument:&unsignedCharValue atIndex:3];
            }  else if (CASE_PRIMITIVE_TYPE(short)) {
                short shortValue = 0;
                [invocation setArgument:&shortValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(unsigned short)) {
                unsigned short unsignedShortValue = 0;
                [invocation setArgument:&unsignedShortValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(int)) {
                int intValue = 0;
                [invocation setArgument:&intValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(unsigned int)) {
                unsigned int unsignedIntValue = 0;
                [invocation setArgument:&unsignedIntValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(long)) {
                long longInt = 0;
                [invocation setArgument:&longInt atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(unsigned long)) {
                unsigned long unsignedLongValue = 0;
                [invocation setArgument:&unsignedLongValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(long long)) {
                long long longlongValue = 0;
                [invocation setArgument:&longlongValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(unsigned long long)) {
                unsigned long long unsignedLongLongValue = 0;
                [invocation setArgument:&unsignedLongLongValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(float)) {
                float floatValue = 0.0;
                [invocation setArgument:&floatValue atIndex:3];
            } else if (CASE_PRIMITIVE_TYPE(double)) {
                double doubleValue = 0.0;
                [invocation setArgument:&doubleValue atIndex:3];
            } else {
                NSLog(@"Unsupported primitive type");
            }
            
        }
    } else if (numberOfArgs >= 1) {
        
        if (!object && !pointer) {
            [invocation setArgument:&object atIndex:2];
        } else if (object) {
            [invocation setArgument:&object atIndex:2];
        } else if (pointer) {
            [invocation setArgument:pointer atIndex:2];
        }
    }
    
    [invocation invoke];
    
    // 获取返回值
    const char *type = signature.methodReturnType;
    if (!strcmp(type, @encode(void)) || signature.methodReturnLength == 0) {
        return nil;
    }
    
    id returnObject = nil;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnObject];
        return returnObject;
    }
    
    // 基本类型都转换为NSNumber
    void *buffer = (void *)malloc(signature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnObject = [self.class _tta_getValueFromPrimitivePointer:buffer objCEncode:type];
    free(buffer);
    
    return returnObject;
}

- (id)tta_safeInvokeSelector:(SEL)aSelector arguments:(NSArray *)args
{
    if (!aSelector) {
        return nil;
    }
    
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArgs = [signature numberOfArguments] - 2;
    if (numberOfArgs != [args count]) {
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target   = self;
    invocation.selector = aSelector;
    
    [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id argObject = obj;
        if (argObject) {
            [invocation setArgument:&argObject atIndex:2 + idx];
        }
    }];
    
    [invocation invoke];
    
    // 获取返回值
    const char *type = signature.methodReturnType;
    if (!strcmp(type, @encode(void)) || signature.methodReturnLength == 0) {
        return nil;
    }
    
    id returnObject = nil;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnObject];
        return returnObject;
    }
    
    // 基本类型都转换为NSNumber
    void *buffer = (void *)malloc(signature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnObject = [self.class _tta_getValueFromPrimitivePointer:buffer objCEncode:type];
    free(buffer);
    
    return returnObject;
}

- (id)tta_safePerformSelector:(SEL)aSelector withPrimitive:(void *)pointer withObjects:(NSArray *)args
{
    if (!aSelector) {
        return nil;
    }
    
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArgs = [signature numberOfArguments] - 2;
    NSInteger indexLocOfArgument = 2;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target   = self;
    invocation.selector = aSelector;
    
    if (numberOfArgs >= 1 && pointer) {
        [invocation setArgument:pointer atIndex:indexLocOfArgument];
        numberOfArgs--;
        indexLocOfArgument++;
    }
    
    for (NSInteger idx = 0; idx < MIN(numberOfArgs, [args count]); idx++) {
        id argObject = args[idx];
        if (argObject) {
            [invocation setArgument:&argObject atIndex:indexLocOfArgument + idx];
        }
    }
    
    [invocation invoke];
    
    // 获取返回值
    const char *type = signature.methodReturnType;
    if (!strcmp(type, @encode(void)) || signature.methodReturnLength == 0) {
        return nil;
    }
    
    id returnObject = nil;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnObject];
        return returnObject;
    }
    
    // 基本类型都转换为NSNumber
    void *buffer = (void *)malloc(signature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnObject = [self.class _tta_getValueFromPrimitivePointer:buffer objCEncode:type];
    free(buffer);
    
    return returnObject;
}

- (id)tta_safePerformSelector:(SEL)aSelector withPrimitive:(void *)pointer
{
    return [self tta_safePerformSelector:aSelector withPrimitive:pointer withPrimitive:NULL];
}

- (id)tta_safePerformSelector:(SEL)aSelector withPrimitive:(void *)pointer1 withPrimitive:(void *)pointer2
{
    if (!aSelector) {
        return nil;
    }
    
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArgs = [signature numberOfArguments] - 2;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target   = self;
    invocation.selector = aSelector;
    
    if (numberOfArgs >= 1) {
        [invocation setArgument:pointer1 atIndex:2];
    }
    
    if (numberOfArgs >= 2) {
        [invocation setArgument:pointer2 atIndex:3];
    }
    
    [invocation invoke];
    
    // 获取返回值
    const char *type = signature.methodReturnType;
    if (!strcmp(type, @encode(void)) || signature.methodReturnLength == 0) {
        return nil;
    }
    
    id returnObject = nil;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnObject];
        return returnObject;
    }
    
    // 基本类型都转换为NSNumber
    void *buffer = (void *)malloc(signature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnObject = [self.class _tta_getValueFromPrimitivePointer:buffer objCEncode:type];
    free(buffer);
    
    return returnObject;
}

+ (NSValue *)_tta_getValueFromPrimitivePointer:(void *)pointer
                                    objCEncode:(const char *)encodeType
{
#define CASE(ctype) \
if (strcmp(encodeType, @encode(ctype)) == 0) {  \
return @((*(ctype *)pointer));   \
}
    
    CASE(BOOL);
    CASE(char);
    CASE(unsigned char);
    CASE(short);
    CASE(unsigned short);
    CASE(int);
    CASE(unsigned int);
    CASE(long);
    CASE(unsigned long);
    CASE(long long);
    CASE(unsigned long long);
    CASE(float);
    CASE(double);
#undef CASE
    @try {
        return [NSValue valueWithBytes:pointer objCType:encodeType];
    } @catch (NSException *exception) {
        
    }
    return nil;
}

@end
