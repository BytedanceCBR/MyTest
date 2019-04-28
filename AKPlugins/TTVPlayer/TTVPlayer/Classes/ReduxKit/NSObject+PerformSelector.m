//
//  NSObject+PerformSelector.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import "NSObject+PerformSelector.h"

@implementation NSObject (PerformSelector)

#pragma tools
- (id)redux_performSelector:(SEL)aSelector withObjects:(NSArray *)objects {

    NSArray *parameters = [objects copy];
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = aSelector;
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    if (numberOfArguments > 2) {
        for (int i = 2; i < numberOfArguments; i++) {
            NSInteger idx = i - 2;
            id parameter = (parameters.count > idx) ? parameters[idx] : nil;
            [invocation setArgument:&parameter atIndex:i];
        }
    }
    [invocation retainArguments];
    [invocation invokeWithTarget:self];
    const char *type = methodSignature.methodReturnType;
    if (!strcmp(type, @encode(void)) || methodSignature.methodReturnLength == 0) {
        return nil;
    }
    id returnValue;
    if (!strcmp(type, @encode(id))) {
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    //    NSNumber, 基本类型都转换位NSNumber
    void *buffer = (void *)malloc(methodSignature.methodReturnLength);
    [invocation getReturnValue:buffer];
    returnValue = ST_CreateValueFromPrimitivePointer(buffer, type);
    free(buffer);
    return returnValue;
}

static NSValue *ST_CreateValueFromPrimitivePointer(void *pointer, const char *objCType) {
    
    // CASE marcro inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
#define CASE(ctype)                                                                                                                                  \
if (strcmp(objCType, @encode(ctype)) == 0) {                                                                                                     \
return @((*(ctype *)pointer));                                                                                                               \
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
        return [NSValue valueWithBytes:pointer objCType:objCType];
    }
    @catch (NSException *exception) {
    }
    return nil;
}

@end
