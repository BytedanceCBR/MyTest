//
//  JSBridgeWebViewDelegate.m
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import "SSJSBridgeWebViewDelegate.h"
#import "SSWeakObject.h"

@interface SSJSBridgeWebViewDelegate()
@property(nonatomic, weak)NSObject<YSWebViewDelegate> *mainDelegate;
@end

@implementation SSJSBridgeWebViewDelegate

+ (instancetype)JSBridgeWebViewDelegateWithMainDelegate:(NSObject<YSWebViewDelegate> *)tMainDelegate
{
    SSJSBridgeWebViewDelegate *result = [[self alloc] init];
    result.mainDelegate = tMainDelegate;
    return result;
}

- (instancetype)init
{
    self.delegates = [NSMutableArray array];
    return self;
}


- (void)forwardInvocation:(NSInvocation *)invocation
{
    BOOL hasReturn = ![[NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding] isEqualToString:@"v"];
    
    if([_mainDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:_mainDelegate];
        if(hasReturn)
        {
            return;
        }
    }
    
    // if has return value, use its first delegate as its return value
    for(SSWeakObject *weakObject in _delegates)
    {
        if([weakObject.content respondsToSelector:invocation.selector])
        {
            [invocation invokeWithTarget:weakObject.content];
            if(hasReturn)
            {
                break;
            }
        }
    }
    
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = NO;
    if([_mainDelegate respondsToSelector:aSelector])
    {
        result = YES;
    }
    else
    {
        for(SSWeakObject *weakObject in _delegates)
        {
            result = [weakObject.content respondsToSelector:aSelector];
            if(result)
            {
                break;
            }
        }
    }
    
    return result;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = [[_mainDelegate class] instanceMethodSignatureForSelector:sel];
    if(!signature)
    {
        for(SSWeakObject *weakObject in _delegates)
        {
            signature = [[weakObject.content class] instanceMethodSignatureForSelector:sel];
            if(signature)
            {
                break;
            }
        }
    }
    
    //添加一个默认返回 防止crash
    //同NSObject+MultiDelegates
    if (!signature) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    
    return signature;
}

@end
